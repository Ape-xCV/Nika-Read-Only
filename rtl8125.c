/*
 * QEMU RTL8125 (2.5GbE Realtek NIC) emulation
 *
 * Emulates an RTL8125B (XID 0x641, RTL_GIGA_MAC_VER_63) or RTL8125A
 * (XID 0x609, RTL_GIGA_MAC_VER_61) well enough for the Linux r8169
 * driver (+ realtek PHY driver) to probe, link up and pass traffic,
 * including TSO/checksum offload via the net_tx_pkt infrastructure.
 * Register layout reverse-engineered from the Linux r8169 driver
 * sources.
 *
 * SPDX-License-Identifier: GPL-2.0-or-later
 */

#include "qemu/osdep.h"
#include "qemu/log.h"
#include "qemu/module.h"
#include "hw/pci/pci.h"
#include "hw/pci/pci_device.h"
#include "hw/pci/msi.h"
#include "hw/pci/pcie.h"
#include "hw/core/qdev-properties.h"
#include "migration/vmstate.h"
#include "system/system.h"
#include "net/net.h"
#include "net/eth.h"
#include "qom/object.h"
#include "net_tx_pkt.h"

#define TYPE_RTL8125 "rtl8125"
OBJECT_DECLARE_TYPE(RTL8125State, RTL8125Class, RTL8125)

#define RTL8125_MMIO_SIZE   0x10000

#define RTL8125A_XID        0x609   /* -> RTL_GIGA_MAC_VER_61 */
#define RTL8125B_XID        0x641   /* -> RTL_GIGA_MAC_VER_63 */

/* MMIO registers */
#define REG_MAC0            0x00
#define REG_MAR0            0x08
#define REG_COUNTER_LOW     0x10
#define REG_COUNTER_HIGH    0x14
#define REG_TXDESC_LOW      0x20
#define REG_TXDESC_HIGH     0x24
#define REG_INT_CFG0        0x34
#define REG_CHIPCMD         0x37
#define REG_INTRMASK_8125   0x38
#define REG_INTRSTATUS_8125 0x3c
#define REG_TXCONFIG        0x40
#define REG_RXCONFIG        0x44
#define REG_CFG9346         0x50
#define REG_PHYAR           0x60
#define REG_CSIDR           0x64
#define REG_CSIAR           0x68
#define REG_PHYSTATUS       0x6c
#define REG_ERIDR           0x70
#define REG_ERIAR           0x74
#define REG_EPHYAR          0x80
#define REG_TXPOLL_8125     0x90
#define REG_OCPDR           0xb0
#define REG_GPHY_OCP        0xb8
#define REG_MCU             0xd3
#define REG_INTRMITIGATE    0xe2
#define REG_RXDESC_LOW      0xe4
#define REG_RXDESC_HIGH     0xe8
#define REG_MAC0_BKP        0x19e0
#define REG_SW_TAIL_PTR0    0x2800
#define REG_HW_CLO_PTR0     0x2802

/* ChipCmd bits */
#define CMD_STOP_REQ        0x80
#define CMD_RESET           0x10
#define CMD_RX_ENB          0x08
#define CMD_TX_ENB          0x04

/*
 * Interrupt status bits. With INT_CFG0 bit 0 clear the chip uses the
 * legacy layout (mainline r8169); with it set, the "ISR v2" layout used
 * by Realtek's vendor and Windows drivers.
 */
#define INT_SYSERR          0x8000
#define INT_TIMEOUT         0x4000  /* HW-timer / interrupt-moderation interrupt */
#define INT_LINKCHG         0x0020
#define INT_RXOVERFLOW      0x0010
#define INT_TXERR           0x0008
#define INT_TXOK            0x0004
#define INT_RXERR           0x0002
#define INT_RXOK            0x0001

#define INT_V2_ROK_Q0       (1u << 0)
#define INT_V2_TOK_Q0       (1u << 16)
#define INT_V2_LINKCHG      (1u << 21)

/* RxConfig bits */
#define RX_ACCEPT_ERR       0x20
#define RX_ACCEPT_RUNT      0x10
#define RX_ACCEPT_BROADCAST 0x08
#define RX_ACCEPT_MULTICAST 0x04
#define RX_ACCEPT_MYPHYS    0x02
#define RX_ACCEPT_ALLPHYS   0x01
#define RX_ACCEPT_MASK      0x3f

/* MCU (0xd3) bits */
#define MCU_NOW_IS_OOB      0x80
#define MCU_RXTX_EMPTY      0x30
#define MCU_LINK_LIST_RDY   0x02

/* Descriptor bits */
#define DESC_OWN            0x80000000
#define DESC_RING_END       0x40000000
#define DESC_FIRST_FRAG     0x20000000
#define DESC_LAST_FRAG      0x10000000

/* RX descriptor V3 (32-byte) bits, selected by RxConfig bit 24 */
#define RXCFG_DESC_V3       (1u << 24)
#define DESC_V3_FIRST_FRAG  (1u << 25)
#define DESC_V3_LAST_FRAG   (1u << 24)

/* TX opts2 bits (csum v2) */
#define TX2_IPV4_CS         (1u << 29)
#define TX2_TCP_CS          (1u << 30)
#define TX2_UDP_CS          (1u << 31)
#define TX2_VLAN_TAG        (1u << 17)
#define TX2_MSS_SHIFT       18
#define TX2_MSS_MASK        0x7ff

/* TX opts1 bits (csum/GSO v2) */
#define TX1_GTSENV4         (1u << 26)
#define TX1_GTSENV6         (1u << 25)

#define OCP_FLAG            0x80000000

/* PHY OCP register addresses (clause-22 regs map at 0xa400 + reg * 2) */
#define PHY_OCP_STD_BASE    0xa400
#define PHY_OCP_BMCR        0xa400
#define PHY_OCP_BMSR        0xa402
#define PHY_OCP_PHYSID1     0xa404
#define PHY_OCP_PHYSID2     0xa406
#define PHY_OCP_ADVERTISE   0xa408
#define PHY_OCP_LPA         0xa40a
#define PHY_OCP_CTRL1000    0xa412
#define PHY_OCP_STAT1000    0xa414
#define PHY_OCP_MMD_DATA    0xa41c
#define PHY_OCP_ESTATUS     0xa41e
#define PHY_OCP_PHYSR       0xa434
#define PHY_OCP_AN_10GBT_CTRL 0xa5d4
#define PHY_OCP_AN_10GBT_STAT 0xa5d6
#define PHY_OCP_PMA_SPEED   0xa616

#define BMCR_RESET          0x8000
#define BMCR_SPEED100       0x2000
#define BMCR_ANENABLE       0x1000
#define BMCR_PDOWN          0x0800
#define BMCR_ANRESTART      0x0200
#define BMCR_FULLDPLX       0x0100
#define BMCR_SPEED1000      0x0040

#define BMSR_LSTATUS        0x0004
#define BMSR_ANEGCOMPLETE   0x0020

/* ADVERTISE (0xa408) bits */
#define ADV_100FULL         0x0100
#define ADV_100HALF         0x0080
#define ADV_10FULL          0x0040

/* CTRL1000 (0xa412) / AN_10GBT_CTRL (0xa5d4) bits */
#define ADV_1000FULL        0x0200
#define ADV_2500FULL        0x0080

/* PHY ID: matches "Realtek Internal NBASE-T PHY" (RTL8125 internal) */
#define RTL8125_PHYID1      0x001c
#define RTL8125_PHYID2      0xc840

/* upper bound per doorbell, matches the 16-bit tail-pointer space */
#define TX_BUDGET_LIMIT     65536
#define DESC_SIZE           16
#define RTL8125_MAX_TX_FRAGS 64

struct RTL8125Class {
    PCIDeviceClass parent_class;

    uint32_t xid;
};

struct RTL8125State {
    PCIDevice parent_obj;

    NICState *nic;
    NICConf conf;
    MemoryRegion mmio;

    uint8_t regs[256];
    uint8_t mac_bkp[6];

    uint16_t phy_ocp[0x8000];
    uint16_t mac_ocp[0x8000];
    uint16_t phy_page[0x10000];  /* PHY-OCP paged regs (0xa436 addr / 0xa438 data) */
    uint16_t phy_page_sel;       /* current 0xa436 latch */

    uint16_t ephy[0x80];
    uint32_t eri[0x400];
    uint32_t csi[0x400];

    uint32_t intr_status;
    uint32_t intr_mask;
    bool intr_level;

    uint32_t gphy_latch;
    uint32_t ephy_latch;
    uint32_t eriar_latch;
    uint32_t csiar_latch;
    uint32_t phyar_latch;
    uint32_t eridr;
    uint32_t csidr;
    uint32_t mac_ocp_last;

    uint32_t tx_idx;
    uint32_t rx_idx;
    uint16_t tx_tail;
    uint16_t tx_clo;

    struct NetTxPkt *tx_pkt;
    uint32_t tx_first_opts1;
    uint32_t tx_first_opts2;
    bool tx_in_packet;
    bool tx_skip;
};

/* ------------------------------------------------------------------ */
/* Interrupts                                                          */

static void rtl8125_update_irq(RTL8125State *s)
{
    PCIDevice *d = PCI_DEVICE(s);
    bool level = (s->intr_status & s->intr_mask) != 0;

    if (msi_enabled(d)) {
        /*
         * Fire MSI whenever an unmasked interrupt is pending, not only on the
         * 0->1 edge. MSI is a one-shot message, so an edge-only model coalesces
         * back-to-back events (e.g. several RX completions) into a single
         * message; the driver services the first and never gets re-interrupted
         * for the rest -> it misses later RX frames (the 2015 NDIS driver lost
         * the DHCP ACK this way and fell back to APIPA). update_irq is only
         * called on a raise or on guest ISR/IMR writes, so this stays one
         * message per event, not a storm.
         */
        if (level) {
            msi_notify(d, 0);
        }
    } else {
        pci_set_irq(d, level);
    }
    s->intr_level = level;
}

static void rtl8125_set_intr(RTL8125State *s, uint32_t bits)
{
    s->intr_status |= bits;
    rtl8125_update_irq(s);
}

static bool rtl8125_isr_v2(RTL8125State *s)
{
    return s->regs[REG_INT_CFG0] & 0x1;
}

static void rtl8125_intr_rx(RTL8125State *s, bool overflow)
{
    if (rtl8125_isr_v2(s)) {
        rtl8125_set_intr(s, INT_V2_ROK_Q0);
    } else {
        /*
         * Also raise the TimeOut (timer) interrupt. With interrupt moderation
         * the NDIS driver (rt640x64.sys) masks ROK and takes RX/TX completions
         * via the HW-timer interrupt (bit14); firing it on activity emulates the
         * coalescing timer so the driver actually services the ring.
         */
        rtl8125_set_intr(s, (overflow ? INT_RXOVERFLOW : INT_RXOK) | INT_TIMEOUT);
    }
}

static void rtl8125_intr_tx(RTL8125State *s)
{
    if (rtl8125_isr_v2(s)) {
        rtl8125_set_intr(s, INT_V2_TOK_Q0);
    } else {
        rtl8125_set_intr(s, INT_TXOK | INT_TIMEOUT);
    }
}

static void rtl8125_intr_link(RTL8125State *s)
{
    rtl8125_set_intr(s, rtl8125_isr_v2(s) ? INT_V2_LINKCHG : INT_LINKCHG);
}

/* ------------------------------------------------------------------ */
/* PHY (GPHY OCP space)                                                */

static void rtl8125_phy_reset(RTL8125State *s)
{
    memset(s->phy_ocp, 0, sizeof(s->phy_ocp));
    memset(s->phy_page, 0, sizeof(s->phy_page));
    s->phy_page_sel = 0;
    s->phy_ocp[PHY_OCP_BMCR >> 1] = 0x1040;     /* aneg enable, full dup */
    s->phy_ocp[PHY_OCP_ADVERTISE >> 1] = 0x05e1;
    s->phy_ocp[PHY_OCP_CTRL1000 >> 1] = 0x0200;
}

static bool rtl8125_link_up(RTL8125State *s)
{
    return !qemu_get_queue(s->nic)->link_down &&
           !(s->phy_ocp[PHY_OCP_BMCR >> 1] & BMCR_PDOWN);
}

/*
 * Resolve speed (in Mbps) and duplex the way a real PHY would: from the
 * forced BMCR setting, or from the guest's advertisement (the emulated
 * link partner advertises everything, so the guest's highest mode wins).
 */
static uint32_t rtl8125_link_speed(RTL8125State *s, bool *full_duplex)
{
    uint16_t bmcr = s->phy_ocp[PHY_OCP_BMCR >> 1];
    uint16_t adv = s->phy_ocp[PHY_OCP_ADVERTISE >> 1];

    if (!(bmcr & BMCR_ANENABLE)) {
        *full_duplex = bmcr & BMCR_FULLDPLX;
        if (bmcr & BMCR_SPEED1000) {
            return 1000;
        }
        return (bmcr & BMCR_SPEED100) ? 100 : 10;
    }

    if (s->phy_ocp[PHY_OCP_AN_10GBT_CTRL >> 1] & ADV_2500FULL) {
        *full_duplex = true;
        return 2500;
    }
    if (s->phy_ocp[PHY_OCP_CTRL1000 >> 1] & ADV_1000FULL) {
        *full_duplex = true;
        return 1000;
    }
    if (adv & (ADV_100FULL | ADV_100HALF)) {
        *full_duplex = adv & ADV_100FULL;
        return 100;
    }
    *full_duplex = adv & ADV_10FULL;
    return 10;
}

static uint16_t rtl8125_phy_ocp_read(RTL8125State *s, uint16_t reg)
{
    bool up = rtl8125_link_up(s);
    bool fdx;
    uint32_t speed;
    uint16_t val;

    switch (reg) {
    case PHY_OCP_BMCR:
        return s->phy_ocp[reg >> 1] & ~(BMCR_RESET | BMCR_ANRESTART);
    case PHY_OCP_BMSR:
        /* 100/10 capable, extended status, aneg capable */
        val = 0x7800 | 0x0100 | 0x0008;
        if (up) {
            val |= BMSR_LSTATUS | BMSR_ANEGCOMPLETE;
        }
        return val;
    case PHY_OCP_PHYSID1:
        return RTL8125_PHYID1;
    case PHY_OCP_PHYSID2:
        return RTL8125_PHYID2;
    case PHY_OCP_LPA:
        /* aneg ack | pause | 100F/100H/10F/10H | csma */
        return up ? 0xc5e1 : 0x0001;
    case PHY_OCP_STAT1000:
        /* master, local+remote rx ok, LP 1000FULL */
        return up ? 0x7800 : 0;
    case PHY_OCP_ESTATUS:
        /* 1000T full/half */
        return 0x3000;
    case PHY_OCP_PHYSR:
        if (!up) {
            return 0;
        }
        speed = rtl8125_link_speed(s, &fdx);
        val = fdx ? 0x0008 : 0;
        switch (speed) {
        case 2500:
            val |= 0x0210 | 0x0800;     /* 2.5G, master */
            break;
        case 1000:
            val |= 0x0020 | 0x0800;     /* 1G, master */
            break;
        case 100:
            val |= 0x0010;
            break;
        default:
            break;
        }
        return val;
    case PHY_OCP_AN_10GBT_STAT:
        /* link partner 2.5G capable */
        return up ? 0x0020 : 0;
    case PHY_OCP_PMA_SPEED:
        /* 2.5G able; checked by realtek PHY driver matching */
        return 0x2000 | 0x0060;
    case PHY_OCP_MMD_DATA:
        /*
         * Internal PHYs return 0 on MMD reads over C22; the realtek PHY
         * driver relies on this to identify the internal NBASE-T PHY.
         */
        return 0;
    case 0xa438:
        /* PHY-OCP paged data window: return the register latched by 0xa436. */
        return s->phy_page[s->phy_page_sel];
    default:
        return s->phy_ocp[reg >> 1];
    }
}

static void rtl8125_phy_ocp_write(RTL8125State *s, uint16_t reg, uint16_t val)
{
    if (reg == PHY_OCP_BMCR) {
        bool was_up = rtl8125_link_up(s);

        if (val & BMCR_RESET) {
            val = (val | BMCR_ANENABLE) & ~BMCR_PDOWN;
        }
        val &= ~(BMCR_RESET | BMCR_ANRESTART);
        s->phy_ocp[reg >> 1] = val;

        /* renegotiation or power state change: notify the MAC */
        if (rtl8125_link_up(s) != was_up || (val & BMCR_ANENABLE)) {
            rtl8125_intr_link(s);
        }
        if (rtl8125_link_up(s) && !was_up) {
            qemu_flush_queued_packets(qemu_get_queue(s->nic));
        }
        return;
    }
    /*
     * PHY-OCP 0xb87a bit0 is write-1-to-clear / self-clearing on real hardware.
     * The Realtek driver's V4 ESD self-test (RtTestPhyOcpRegV4) writes it set
     * and then re-reads expecting 0; if the bit persists, the test reports a PHY
     * fault and the driver issues a full HW reset. Persisting it produced a
     * periodic SOFT-RESET loop that made the WHQL driver laggy/unusable. Drop
     * bit0 on write so the read-back is 0 and the ESD test passes.
     */
    if (reg == 0xb87a) {
        val &= ~0x1u;
    }
    /*
     * PHY MCU patch-request handshake. The driver's set_phy_mcu_patch_request
     * AND clear_phy_mcu_patch_request (rt640x64.sys @0x140020d.. / 0x140029.. )
     * both write 0xb820 bit4 (set vs clear) and then poll 0xb800 for bit6 == 1
     * (`and $0x40,%bx; jne exit`). So the MCU acks EITHER request edge by raising
     * 0xb800 bit6 -- it is NOT a mirror of bit4. Raise bit6 on any 0xb820 write;
     * it is cleared only on PHY reset. (Mirroring bit4 made the clear poll spin
     * 1000x and reset the adapter mid PHY-ramcode load.)
     */
    if (reg == 0xb820) {
        s->phy_ocp[0xb800 >> 1] |= 0x0040;
    }
    /*
     * PHY-OCP paged indirect access: 0xa436 latches a register address, 0xa438
     * is the data window into it. The driver streams PHY MCU ramcode as
     * {0xa436=addr, 0xa438=data} pairs and reads/stamps the ramcode version at
     * slot 0x801e the same way. Model it as a side array so the version readback
     * is self-consistent (driver stamps after load -> matches -> skips reload).
     */
    if (reg == 0xa436) {
        s->phy_page_sel = val;
        s->phy_ocp[reg >> 1] = val;
        return;
    }
    if (reg == 0xa438) {
        s->phy_page[s->phy_page_sel] = val;
        s->phy_ocp[reg >> 1] = val;
        return;
    }
    s->phy_ocp[reg >> 1] = val;
}

/* ------------------------------------------------------------------ */
/* TX path                                                             */

static void rtl8125_tx_pkt_reset(RTL8125State *s)
{
    if (s->tx_pkt) {
        net_tx_pkt_reset(s->tx_pkt, net_tx_pkt_unmap_frag_pci, PCI_DEVICE(s));
    }
    s->tx_in_packet = false;
    s->tx_skip = false;
}

static void rtl8125_xmit_packet(RTL8125State *s)
{
    struct NetTxPkt *pkt = s->tx_pkt;
    uint32_t opts1 = s->tx_first_opts1;
    uint32_t opts2 = s->tx_first_opts2;
    bool tso = opts1 & (TX1_GTSENV4 | TX1_GTSENV6);
    bool l4_csum = opts2 & (TX2_TCP_CS | TX2_UDP_CS);

    if (!rtl8125_link_up(s)) {
        return;
    }

    if (!net_tx_pkt_parse(pkt)) {
        return;
    }

    if (opts2 & TX2_VLAN_TAG) {
        net_tx_pkt_setup_vlan_header_ex(pkt, bswap16(opts2 & 0xffff),
                                        ETH_P_VLAN);
    }

    if (tso) {
        uint16_t mss = (opts2 >> TX2_MSS_SHIFT) & TX2_MSS_MASK;

        if (!net_tx_pkt_build_vheader(pkt, true, true, mss)) {
            return;
        }
        net_tx_pkt_update_ip_checksums(pkt);
    } else if (l4_csum) {
        if (!net_tx_pkt_build_vheader(pkt, false, true, 0)) {
            return;
        }
        net_tx_pkt_update_ip_hdr_checksum(pkt);
    } else if (opts2 & TX2_IPV4_CS) {
        net_tx_pkt_update_ip_hdr_checksum(pkt);
    }

    net_tx_pkt_send(pkt, qemu_get_queue(s->nic));
}

/*
 * Two doorbell models share this engine:
 *  - legacy (mainline r8169): write BIT(0) to TxPoll (0x90), hardware
 *    consumes descriptors while the OWN bit is set
 *  - tail pointer (vendor/Windows drivers): write a free-running 16-bit
 *    descriptor count to SW_TAIL_PTR0 (0x2800); hardware reports its own
 *    free-running completion count via HW_CLO_PTR0 (0x2802)
 */
static void rtl8125_process_tx(RTL8125State *s, bool tail_mode)
{
    PCIDevice *d = PCI_DEVICE(s);
    uint64_t base;
    uint32_t stride;
    int budget;

    if (!(s->regs[REG_CHIPCMD] & CMD_TX_ENB)) {
        return;
    }

    base = ldq_le_p(&s->regs[REG_TXDESC_LOW]);
    if (!base) {
        return;
    }

    /*
     * MAC OCP 0xeb58 bit 0 selects the "new" 32-byte TX descriptor
     * layout (same fields, padded). Mainline r8169 clears it, Realtek's
     * vendor and Windows drivers set it.
     */
    stride = (s->mac_ocp[0xeb58 >> 1] & 0x1) ? 32 : DESC_SIZE;

    for (budget = 0; budget < TX_BUDGET_LIMIT; budget++) {
        uint64_t daddr = base + (uint64_t)s->tx_idx * stride;
        uint8_t desc[DESC_SIZE];
        uint32_t opts1, opts2, flen;
        uint64_t bufaddr;

        if (tail_mode && s->tx_clo == s->tx_tail) {
            break;
        }

        pci_dma_read(d, daddr, desc, DESC_SIZE);
        opts1 = ldl_le_p(desc);
        opts2 = ldl_le_p(desc + 4);
        bufaddr = ldq_le_p(desc + 8);

        if (!(opts1 & DESC_OWN)) {
            if (tail_mode) {
                qemu_log_mask(LOG_GUEST_ERROR,
                              "rtl8125: tx tail 0x%x ahead of last owned "
                              "descriptor (clo 0x%x)\n", s->tx_tail,
                              s->tx_clo);
            }
            break;
        }

        flen = opts1 & 0xffff;

        if (opts1 & DESC_FIRST_FRAG) {
            rtl8125_tx_pkt_reset(s);
            s->tx_in_packet = true;
            s->tx_first_opts1 = opts1;
            s->tx_first_opts2 = opts2;
        }

        if (s->tx_in_packet && !s->tx_skip && flen &&
            !net_tx_pkt_add_raw_fragment_pci(s->tx_pkt, d, bufaddr, flen)) {
            s->tx_skip = true;
        }

        /* hand the descriptor back to the driver */
        stl_le_p(desc, opts1 & ~DESC_OWN);
        pci_dma_write(d, daddr, desc, 4);

        s->tx_clo++;

        /* the ring wraps only at the descriptor carrying RingEnd */
        if (opts1 & DESC_RING_END) {
            s->tx_idx = 0;
        } else {
            s->tx_idx++;
        }

        if (opts1 & DESC_LAST_FRAG) {
            if (s->tx_in_packet && !s->tx_skip) {
                rtl8125_xmit_packet(s);
            }
            rtl8125_tx_pkt_reset(s);
            rtl8125_intr_tx(s);
        }
    }
}

/* ------------------------------------------------------------------ */
/* RX path                                                             */

static bool rtl8125_rx_filter(RTL8125State *s, const uint8_t *buf)
{
    uint32_t rxcfg = ldl_le_p(&s->regs[REG_RXCONFIG]);
    static const uint8_t bcast[6] = { 0xff, 0xff, 0xff, 0xff, 0xff, 0xff };

    if (rxcfg & RX_ACCEPT_ALLPHYS) {
        return true;
    }
    if (!memcmp(buf, bcast, 6)) {
        return rxcfg & RX_ACCEPT_BROADCAST;
    }
    if (buf[0] & 1) {
        /*
         * The driver programs a 64-bit multicast hash in MAR0, but its
         * layout depends on the CRC endianness and a swab32 of the two
         * words that is awkward to mirror exactly. Accept any multicast
         * when AcceptMulticast is set and let the guest stack re-filter;
         * over-delivery is harmless and never wrongly drops wanted frames.
         */
        return rxcfg & RX_ACCEPT_MULTICAST;
    }
    return (rxcfg & RX_ACCEPT_MYPHYS) &&
           !memcmp(buf, &s->regs[REG_MAC0], 6);
}

static bool rtl8125_can_receive(NetClientState *nc)
{
    RTL8125State *s = qemu_get_nic_opaque(nc);

    return rtl8125_link_up(s) &&
           (s->regs[REG_CHIPCMD] & CMD_RX_ENB) &&
           (ldl_le_p(&s->regs[REG_RXCONFIG]) & RX_ACCEPT_MASK);
}

static ssize_t rtl8125_receive(NetClientState *nc, const uint8_t *buf,
                               size_t size)
{
    RTL8125State *s = qemu_get_nic_opaque(nc);
    PCIDevice *d = PCI_DEVICE(s);
    uint8_t desc[32];
    uint32_t opts1, bufsize, status, stride, opts1_off, addr_off, len_mask;
    uint64_t base, daddr, bufaddr;
    bool v3;
    static const uint8_t fcs_pad[4];

    if (!rtl8125_can_receive(nc)) {
        return -1;
    }
    if (size < 14 || !rtl8125_rx_filter(s, buf)) {
        return size;
    }

    base = ldq_le_p(&s->regs[REG_RXDESC_LOW]);
    if (!base) {
        return size;
    }

    /*
     * RxConfig bit 24 selects the 32-byte V3 descriptor layout used by
     * Realtek's vendor and Windows drivers: buffer address at offset 16,
     * opts2/opts1 at offsets 24/28, FS/LS at bits 25/24, 15-bit length.
     */
    v3 = ldl_le_p(&s->regs[REG_RXCONFIG]) & RXCFG_DESC_V3;
    stride = v3 ? 32 : DESC_SIZE;
    opts1_off = v3 ? 28 : 0;
    addr_off = v3 ? 16 : 8;
    len_mask = v3 ? 0x7fff : 0x3fff;

    daddr = base + (uint64_t)s->rx_idx * stride;
    pci_dma_read(d, daddr, desc, stride);
    opts1 = ldl_le_p(desc + opts1_off);
    bufaddr = ldq_le_p(desc + addr_off);

    if (!(opts1 & DESC_OWN)) {
        /* no free descriptor: drop like real hardware */
        rtl8125_intr_rx(s, true);
        return size;
    }

    bufsize = opts1 & len_mask;
    if (size + 4 > bufsize) {
        return size;
    }

    pci_dma_write(d, bufaddr, buf, size);
    pci_dma_write(d, bufaddr + size, fcs_pad, 4);

    status = (size + 4) & len_mask;
    status |= opts1 & DESC_RING_END;
    if (v3) {
        status |= DESC_V3_FIRST_FRAG | DESC_V3_LAST_FRAG;

        /* clear RSS hash and header-split info */
        memset(desc + 8, 0, 8);
        pci_dma_write(d, daddr + 8, desc + 8, 8);
    } else {
        status |= DESC_FIRST_FRAG | DESC_LAST_FRAG;
    }

    stl_le_p(desc, 0);
    pci_dma_write(d, daddr + (v3 ? 24 : 4), desc, 4);  /* opts2 = 0 */
    stl_le_p(desc, status);
    pci_dma_write(d, daddr + opts1_off, desc, 4);

    if (opts1 & DESC_RING_END) {
        s->rx_idx = 0;
    } else {
        s->rx_idx++;
    }

    rtl8125_intr_rx(s, false);

    return size;
}

/* ------------------------------------------------------------------ */
/* Tally counters                                                      */

static void rtl8125_dump_counters(RTL8125State *s)
{
    PCIDevice *d = PCI_DEVICE(s);
    uint32_t lo = ldl_le_p(&s->regs[REG_COUNTER_LOW]);
    uint32_t hi = ldl_le_p(&s->regs[REG_COUNTER_HIGH]);
    uint64_t addr = ((uint64_t)hi << 32) | (lo & ~0xfull);
    uint8_t counters[192];

    if (!addr) {
        return;
    }
    memset(counters, 0, sizeof(counters));
    pci_dma_write(d, addr, counters, sizeof(counters));
}

/* ------------------------------------------------------------------ */
/* Soft reset                                                          */

static void rtl8125_soft_reset(RTL8125State *s)
{
    s->tx_idx = 0;
    s->rx_idx = 0;
    s->tx_tail = 0;
    s->tx_clo = 0;
    rtl8125_tx_pkt_reset(s);
    s->intr_status = 0;
    rtl8125_update_irq(s);
}

/* ------------------------------------------------------------------ */
/* MMIO                                                                */

static uint64_t rtl8125_mmio_read(void *opaque, hwaddr addr, unsigned size)
{
    RTL8125State *s = opaque;

    switch (addr) {
    case REG_CHIPCMD:
        return s->regs[REG_CHIPCMD] & ~(CMD_RESET | CMD_STOP_REQ);
    case REG_INTRMASK_8125 ... REG_INTRMASK_8125 + 3:
        return s->intr_mask >> ((addr - REG_INTRMASK_8125) * 8);
    case REG_INTRSTATUS_8125 ... REG_INTRSTATUS_8125 + 3:
        return s->intr_status >> ((addr - REG_INTRSTATUS_8125) * 8);
    case REG_PHYAR:
        return s->phyar_latch;
    case REG_CSIDR:
        return s->csidr;
    case REG_CSIAR:
        return s->csiar_latch;
    case REG_PHYSTATUS: {
        bool fdx;
        uint32_t speed, v = 0;

        if (!rtl8125_link_up(s)) {
            return 0;
        }
        speed = rtl8125_link_speed(s, &fdx);
        v = 0x02;                       /* LinkStatus */
        if (speed == 2500) {
            v |= 0x400;                 /* _2500bpsF (PHYstatus bit10) */
        } else if (speed >= 1000) {
            v |= 0x10;                  /* _1000bpsF */
        } else if (speed == 100) {
            v |= 0x08;                  /* _100bps */
        } else {
            v |= 0x04;                  /* _10bps */
        }
        if (fdx) {
            v |= 0x01;                  /* FullDup */
        }
        return v;
    }
    case REG_ERIDR:
        return s->eridr;
    case REG_ERIAR:
        return s->eriar_latch;
    case REG_EPHYAR:
        return s->ephy_latch;
    case REG_OCPDR:
        return s->mac_ocp[(s->mac_ocp_last >> 1) & 0x7fff];
    case REG_GPHY_OCP:
        return s->gphy_latch;
    case REG_MCU:
        return (s->regs[REG_MCU] | MCU_RXTX_EMPTY | MCU_LINK_LIST_RDY);
    case REG_INTRMITIGATE:
        /*
         * On RTL8125B+ the driver polls bits 0x0103 here to confirm the
         * tx/rx FIFOs have drained (rtl_rxtx_empty_cond_2).
         */
        return lduw_le_p(&s->regs[REG_INTRMITIGATE]) | 0x0103;
    case REG_MAC0 ... REG_MAC0 + 5: {
        uint64_t val = 0;
        memcpy(&val, &s->regs[addr], size);
        return le64_to_cpu(val);
    }
    default:
        break;
    }

    if (addr + size <= sizeof(s->regs)) {
        uint64_t val = 0;
        memcpy(&val, &s->regs[addr], size);
        return le64_to_cpu(val);
    }

    if (addr == REG_SW_TAIL_PTR0) {
        return s->tx_tail;
    }
    if (addr == REG_HW_CLO_PTR0) {
        return s->tx_clo;
    }

    if (addr >= REG_MAC0_BKP && addr <= REG_MAC0_BKP + 5) {
        uint8_t tmp[16] = {};
        memcpy(tmp, s->mac_bkp, 6);
        uint64_t val = 0;
        memcpy(&val, tmp + (addr - REG_MAC0_BKP), size);
        return le64_to_cpu(val);
    }

    qemu_log_mask(LOG_UNIMP,
                  "rtl8125: unhandled read  addr 0x%04" HWADDR_PRIx
                  " size %u\n", addr, size);

    return 0;
}

static void rtl8125_write_reg_bytes(RTL8125State *s, hwaddr addr,
                                    uint64_t val, unsigned size)
{
    uint64_t le = cpu_to_le64(val);

    if (addr + size <= sizeof(s->regs)) {
        memcpy(&s->regs[addr], &le, size);
    }
}

static void rtl8125_mmio_write(void *opaque, hwaddr addr, uint64_t val,
                               unsigned size)
{
    RTL8125State *s = opaque;
    uint16_t reg;

    switch (addr) {
    case REG_MAC0 ... REG_MAC0 + 5: {
        /*
         * On real RTL8125 the IDR (MAC) registers are only writable while the
         * config registers are unlocked via CFG9346 (0x50) == 0xC0; otherwise
         * the write is dropped by hardware. The Win10 default driver
         * (rt640x64.sys) pokes IDR0=0 while locked, which must NOT clobber the
         * power-on MAC -- applying it gave a zero-OUI MAC and APIPA.
         */
        bool unlocked = (s->regs[REG_CFG9346] & 0xc0) == 0xc0;
        if (unlocked) {
            rtl8125_write_reg_bytes(s, addr, val, size);
            memcpy(s->mac_bkp, &s->regs[REG_MAC0], 6);
        }
        return;
    }
    case REG_COUNTER_LOW:
        rtl8125_write_reg_bytes(s, addr, val, size);
        if (val & 0x8) {
            rtl8125_dump_counters(s);
        }
        /* dump/reset complete instantly */
        s->regs[REG_COUNTER_LOW] &= ~0x9;
        return;
    case REG_TXDESC_LOW:
    case REG_TXDESC_HIGH:
        rtl8125_write_reg_bytes(s, addr, val, size);
        s->tx_idx = 0;
        s->tx_tail = 0;
        s->tx_clo = 0;
        return;
    case REG_RXDESC_LOW:
    case REG_RXDESC_HIGH:
        rtl8125_write_reg_bytes(s, addr, val, size);
        s->rx_idx = 0;
        qemu_flush_queued_packets(qemu_get_queue(s->nic));
        return;
    case REG_CHIPCMD:
        if (val & CMD_RESET) {
            rtl8125_soft_reset(s);
        }
        s->regs[REG_CHIPCMD] = val & (CMD_RX_ENB | CMD_TX_ENB);
        if (val & CMD_RX_ENB) {
            qemu_flush_queued_packets(qemu_get_queue(s->nic));
        }
        return;
    case REG_INTRMASK_8125 ... REG_INTRMASK_8125 + 3: {
        /* Byte-accurate so 16-bit half writes (the NDIS driver writes IMR/ISR in
         * 16-bit halves) update the right bits instead of clobbering the rest. */
        uint32_t shift = (addr - REG_INTRMASK_8125) * 8;
        uint32_t wmask = (size >= 4) ? 0xffffffffu
                                     : (((1u << (size * 8)) - 1) << shift);
        s->intr_mask = (s->intr_mask & ~wmask) | ((uint32_t)(val << shift) & wmask);
        rtl8125_update_irq(s);
        return;
    }
    case REG_INTRSTATUS_8125 ... REG_INTRSTATUS_8125 + 3: {
        uint32_t shift = (addr - REG_INTRSTATUS_8125) * 8;
        uint32_t clr = (uint32_t)(val << shift);
        s->intr_status &= ~clr;
        rtl8125_update_irq(s);
        return;
    }
    case REG_TXCONFIG:
        if (size == 4) {
            uint32_t old = ldl_le_p(&s->regs[REG_TXCONFIG]);
            uint32_t keep = 0xfcf00000;
            stl_le_p(&s->regs[REG_TXCONFIG],
                     (old & keep) | ((uint32_t)val & ~keep));
        }
        return;
    case REG_RXCONFIG:
        rtl8125_write_reg_bytes(s, addr, val, size);
        qemu_log_mask(LOG_UNIMP, "rtl8125: RxConfig <= 0x%08x (desc %s)\n",
                      ldl_le_p(&s->regs[REG_RXCONFIG]),
                      (ldl_le_p(&s->regs[REG_RXCONFIG]) & RXCFG_DESC_V3) ?
                      "V3" : "V1");
        qemu_flush_queued_packets(qemu_get_queue(s->nic));
        return;
    case REG_PHYAR:
        reg = (val >> 16) & 0x1f;
        if (val & OCP_FLAG) {
            rtl8125_phy_ocp_write(s, PHY_OCP_STD_BASE + reg * 2,
                                  val & 0xffff);
            s->phyar_latch = 0;
        } else {
            s->phyar_latch = OCP_FLAG |
                rtl8125_phy_ocp_read(s, PHY_OCP_STD_BASE + reg * 2);
        }
        return;
    case REG_CSIDR:
        s->csidr = val;
        return;
    case REG_CSIAR: {
        uint32_t idx = (val & 0xfff) >> 2;
        if (val & OCP_FLAG) {
            uint32_t be = (val >> 12) & 0xf;
            uint32_t cur = s->csi[idx];
            uint32_t mask = 0;
            for (int i = 0; i < 4; i++) {
                if (be & (1 << i)) {
                    mask |= 0xffu << (i * 8);
                }
            }
            s->csi[idx] = (cur & ~mask) | (s->csidr & mask);
            s->csiar_latch = 0;
        } else {
            s->csidr = s->csi[idx];
            s->csiar_latch = OCP_FLAG;
        }
        return;
    }
    case REG_ERIDR:
        s->eridr = val;
        return;
    case REG_ERIAR: {
        uint32_t idx = (val & 0xfff) >> 2;
        if (val & OCP_FLAG) {
            uint32_t be = (val >> 12) & 0xf;
            uint32_t cur = s->eri[idx];
            uint32_t mask = 0;
            for (int i = 0; i < 4; i++) {
                if (be & (1 << i)) {
                    mask |= 0xffu << (i * 8);
                }
            }
            s->eri[idx] = (cur & ~mask) | (s->eridr & mask);
            s->eriar_latch = 0;
        } else {
            s->eridr = s->eri[idx];
            s->eriar_latch = OCP_FLAG;
        }
        return;
    }
    case REG_EPHYAR:
        reg = (val >> 16) & 0x7f;
        if (val & OCP_FLAG) {
            s->ephy[reg] = val & 0xffff;
            s->ephy_latch = 0;
        } else {
            s->ephy_latch = OCP_FLAG | s->ephy[reg];
        }
        return;
    case REG_TXPOLL_8125:
        if (val & ~0x1ull) {
            qemu_log_mask(LOG_UNIMP,
                          "rtl8125: doorbell with unknown queue bits 0x%"
                          PRIx64 "\n", val);
        }
        if (val & 0x1) {
            rtl8125_process_tx(s, false);
        }
        return;
    case REG_SW_TAIL_PTR0:
        s->tx_tail = val;
        rtl8125_process_tx(s, true);
        return;
    case REG_OCPDR:
        reg = ((val >> 16) & 0x7fff) << 1;
        if (val & OCP_FLAG) {
            s->mac_ocp[reg >> 1] = val & 0xffff;
        } else {
            s->mac_ocp_last = reg;
        }
        return;
    case REG_GPHY_OCP:
        reg = ((val >> 16) & 0x7fff) << 1;
        if (val & OCP_FLAG) {
            rtl8125_phy_ocp_write(s, reg, val & 0xffff);
            s->gphy_latch = 0;
        } else {
            s->gphy_latch = OCP_FLAG | rtl8125_phy_ocp_read(s, reg);
        }
        return;
    default:
        break;
    }

    if (addr + size > sizeof(s->regs)) {
        qemu_log_mask(LOG_UNIMP,
                      "rtl8125: unhandled write addr 0x%04" HWADDR_PRIx
                      " size %u val 0x%" PRIx64 "\n", addr, size, val);
    }

    rtl8125_write_reg_bytes(s, addr, val, size);
}

static const MemoryRegionOps rtl8125_mmio_ops = {
    .read = rtl8125_mmio_read,
    .write = rtl8125_mmio_write,
    .endianness = DEVICE_LITTLE_ENDIAN,
    .valid = {
        .min_access_size = 1,
        .max_access_size = 4,
    },
    .impl = {
        .min_access_size = 1,
        .max_access_size = 4,
    },
};

/* ------------------------------------------------------------------ */
/* Device lifecycle                                                    */

static void rtl8125_reset(DeviceState *dev)
{
    RTL8125State *s = RTL8125(dev);
    RTL8125Class *rc = RTL8125_GET_CLASS(s);

    memset(s->regs, 0, sizeof(s->regs));
    memset(s->mac_ocp, 0, sizeof(s->mac_ocp));
    memset(s->ephy, 0, sizeof(s->ephy));
    memset(s->eri, 0, sizeof(s->eri));
    memset(s->csi, 0, sizeof(s->csi));
    rtl8125_phy_reset(s);

    s->intr_status = 0;
    s->intr_mask = 0;
    s->intr_level = false;
    s->gphy_latch = 0;
    s->ephy_latch = 0;
    s->eriar_latch = 0;
    s->csiar_latch = 0;
    s->phyar_latch = 0;
    s->eridr = 0;
    s->csidr = 0;
    s->mac_ocp_last = 0;
    s->tx_idx = 0;
    s->rx_idx = 0;
    s->tx_tail = 0;
    s->tx_clo = 0;
    rtl8125_tx_pkt_reset(s);

    stl_le_p(&s->regs[REG_TXCONFIG], rc->xid << 20);

    memcpy(&s->regs[REG_MAC0], s->conf.macaddr.a, 6);
    memcpy(s->mac_bkp, s->conf.macaddr.a, 6);
}

static void rtl8125_set_link_status(NetClientState *nc)
{
    RTL8125State *s = qemu_get_nic_opaque(nc);

    rtl8125_intr_link(s);
    if (rtl8125_link_up(s)) {
        qemu_flush_queued_packets(qemu_get_queue(s->nic));
    }
}

static NetClientInfo net_rtl8125_info = {
    .type = NET_CLIENT_DRIVER_NIC,
    .size = sizeof(NICState),
    .can_receive = rtl8125_can_receive,
    .receive = rtl8125_receive,
    .link_status_changed = rtl8125_set_link_status,
};

static void rtl8125_realize(PCIDevice *pci_dev, Error **errp)
{
    RTL8125State *s = RTL8125(pci_dev);
    DeviceState *dev = DEVICE(pci_dev);
    int ret;

    pci_dev->config[PCI_INTERRUPT_PIN] = 1;

    memory_region_init_io(&s->mmio, OBJECT(s), &rtl8125_mmio_ops, s,
                          "rtl8125-mmio", RTL8125_MMIO_SIZE);
    pci_register_bar(pci_dev, 2,
                     PCI_BASE_ADDRESS_SPACE_MEMORY |
                     PCI_BASE_ADDRESS_MEM_TYPE_64,
                     &s->mmio);

    ret = msi_init(pci_dev, 0x50, 1, true, false, NULL);
    assert(!ret || ret == -ENOTSUP);

    if (pci_is_express(pci_dev) &&
        pci_bus_is_express(pci_get_bus(pci_dev))) {
        pcie_endpoint_cap_init(pci_dev, 0x70);
    }

    qemu_macaddr_default_if_unset(&s->conf.macaddr);

    s->nic = qemu_new_nic(&net_rtl8125_info, &s->conf,
                          object_get_typename(OBJECT(pci_dev)), dev->id,
                          &dev->mem_reentrancy_guard, s);
    qemu_format_nic_info_str(qemu_get_queue(s->nic), s->conf.macaddr.a);

    net_tx_pkt_init(&s->tx_pkt, RTL8125_MAX_TX_FRAGS);
}

static void rtl8125_exit(PCIDevice *pci_dev)
{
    RTL8125State *s = RTL8125(pci_dev);

    rtl8125_tx_pkt_reset(s);
    net_tx_pkt_uninit(s->tx_pkt);
    s->tx_pkt = NULL;
    qemu_del_nic(s->nic);
}

static const VMStateDescription vmstate_rtl8125 = {
    .name = "rtl8125",
    .version_id = 2,
    .minimum_version_id = 2,
    .fields = (const VMStateField[]) {
        VMSTATE_PCI_DEVICE(parent_obj, RTL8125State),
        VMSTATE_UINT8_ARRAY(regs, RTL8125State, 256),
        VMSTATE_UINT8_ARRAY(mac_bkp, RTL8125State, 6),
        VMSTATE_UINT16_ARRAY(phy_ocp, RTL8125State, 0x8000),
        VMSTATE_UINT16_ARRAY(mac_ocp, RTL8125State, 0x8000),
        VMSTATE_UINT16_ARRAY(ephy, RTL8125State, 0x80),
        VMSTATE_UINT32_ARRAY(eri, RTL8125State, 0x400),
        VMSTATE_UINT32_ARRAY(csi, RTL8125State, 0x400),
        VMSTATE_UINT32(intr_status, RTL8125State),
        VMSTATE_UINT32(intr_mask, RTL8125State),
        VMSTATE_BOOL(intr_level, RTL8125State),
        VMSTATE_UINT32(gphy_latch, RTL8125State),
        VMSTATE_UINT32(ephy_latch, RTL8125State),
        VMSTATE_UINT32(eriar_latch, RTL8125State),
        VMSTATE_UINT32(csiar_latch, RTL8125State),
        VMSTATE_UINT32(phyar_latch, RTL8125State),
        VMSTATE_UINT32(eridr, RTL8125State),
        VMSTATE_UINT32(csidr, RTL8125State),
        VMSTATE_UINT32(mac_ocp_last, RTL8125State),
        VMSTATE_UINT32(tx_idx, RTL8125State),
        VMSTATE_UINT32(rx_idx, RTL8125State),
        VMSTATE_UINT16(tx_tail, RTL8125State),
        VMSTATE_UINT16(tx_clo, RTL8125State),
        VMSTATE_END_OF_LIST()
    }
};

static const Property rtl8125_properties[] = {
    DEFINE_NIC_PROPERTIES(RTL8125State, conf),
};

static void rtl8125_instance_init(Object *obj)
{
    RTL8125State *s = RTL8125(obj);

    device_add_bootindex_property(obj, &s->conf.bootindex,
                                  "bootindex", "/ethernet-phy@0",
                                  DEVICE(obj));
    PCI_DEVICE(obj)->cap_present |= QEMU_PCI_CAP_EXPRESS;
}

typedef struct RTL8125ChipInfo {
    const char *desc;
    uint32_t xid;
    uint8_t revision;
} RTL8125ChipInfo;

static const RTL8125ChipInfo rtl8125b_chip_info = {
    .desc = "Realtek RTL8125B 2.5GbE Controller",
    .xid = RTL8125B_XID,
    .revision = 0x05,
};

static const RTL8125ChipInfo rtl8125a_chip_info = {
    .desc = "Realtek RTL8125A 2.5GbE Controller",
    .xid = RTL8125A_XID,
    .revision = 0x01,
};

static void rtl8125_chip_class_init(ObjectClass *klass, const void *data)
{
    DeviceClass *dc = DEVICE_CLASS(klass);
    PCIDeviceClass *k = PCI_DEVICE_CLASS(klass);
    RTL8125Class *rc = RTL8125_CLASS(klass);
    const RTL8125ChipInfo *info = data;

    k->revision = info->revision;
    rc->xid = info->xid;
    dc->desc = info->desc;
}

static void rtl8125_class_init(ObjectClass *klass, const void *data)
{
    DeviceClass *dc = DEVICE_CLASS(klass);
    PCIDeviceClass *k = PCI_DEVICE_CLASS(klass);

    k->realize = rtl8125_realize;
    k->exit = rtl8125_exit;
    k->vendor_id = PCI_VENDOR_ID_REALTEK;
    k->device_id = 0x8125;
    k->subsystem_vendor_id = PCI_VENDOR_ID_REALTEK;
    k->subsystem_id = 0x8125;
    k->class_id = PCI_CLASS_NETWORK_ETHERNET;
    device_class_set_legacy_reset(dc, rtl8125_reset);
    dc->vmsd = &vmstate_rtl8125;
    device_class_set_props(dc, rtl8125_properties);
    set_bit(DEVICE_CATEGORY_NETWORK, dc->categories);

    rtl8125_chip_class_init(klass, data);
}

static const TypeInfo rtl8125_infos[] = {
    {
        .name          = TYPE_RTL8125,
        .parent        = TYPE_PCI_DEVICE,
        .instance_size = sizeof(RTL8125State),
        .class_size    = sizeof(RTL8125Class),
        .class_init    = rtl8125_class_init,
        .class_data    = &rtl8125b_chip_info,
        .instance_init = rtl8125_instance_init,
        .interfaces = (const InterfaceInfo[]) {
            { INTERFACE_PCIE_DEVICE },
            { INTERFACE_CONVENTIONAL_PCI_DEVICE },
            { },
        },
    },
    {
        .name          = "rtl8125a",
        .parent        = TYPE_RTL8125,
        .class_init    = rtl8125_chip_class_init,
        .class_data    = &rtl8125a_chip_info,
    },
};

DEFINE_TYPES(rtl8125_infos)
