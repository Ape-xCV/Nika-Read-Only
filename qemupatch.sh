#!/usr/bin/env bash

# lspci -nn

lpc_1022="790E"         # FCH LPC Bridge
smbus_1022="790B"       # FCH SMBus Controller
hdaudio_1022="1637"     # Renoir HD Audio Controller
hdaname_1022="Renoir HD Audio Controller"
sata_1022="7901"        # FCH SATA Controller [AHCI mode]
rootport_1022="1448"    # Renoir Device 24: Function 0
xhci_1022="7914"        # FCH USB XHCI Controller
hostbridge_1022="1630"  # Renoir/Cezanne Root Complex
pcibridge_1022="1633"   # Renoir PCIe GPP Bridge

lpc_8086="068D"         # Comet Lake LPC Controller
smbus_8086="A3A3"       # Comet Lake PCH-V SMBus Host Controller
hdaudio_8086="A3F0"     # Comet Lake PCH-V cAVS
hdaname_8086="Comet Lake PCH-V cAVS"
sata_8086="06D2"        # Comet Lake SATA AHCI Controller
rootport_8086="06BA"    # Comet Lake PCI Express Root Port #1
xhci_8086="06ED"        # Comet Lake USB 3.1 xHCI Host Controller
hostbridge_8086="9B54"  # 10th Gen Core Processor Host Bridge/DRAM Registers
pcibridge_8086="1901"   # 6th-10th Gen Core Processor PCIe Controller (x16)


if [ "$EUID" != 0 ]; then
    faillock --reset
    sudo -E "$0" "$@"
    exit $?
fi

if [[ ! -f vars.sh ]]; then
  echo -e "$(pwd)/\e[1mvars.sh\e[0m does not exist, storing..."
  device=$(( ($(date +"%-d") + $(date +"%-m"))*100 + $(date +"%-d") * $(date +"%-m") ))
  xhci=$((   49152 - device - ((RANDOM%768)+256) ))
  virtio=$(( 49152 + device                      ))
  cpu=$((    16384          + ((RANDOM%1024)*16) ))
  echo "device=\"$device\""                  >  vars.sh
  echo "xhci=\"$xhci\""                      >> vars.sh
  echo "virtio=\"$virtio\""                  >> vars.sh
  echo "cpu=\"$cpu\""                        >> vars.sh
  echo "edk2bridge_1022=\"$pcibridge_1022\"" >> vars.sh
  echo "edk2bridge_8086=\"$pcibridge_8086\"" >> vars.sh
else
  echo -e "$(pwd)/\e[1mvars.sh\e[0m found."
  source vars.sh
  echo "device=\"$device\""                  >  vars.sh
  echo "xhci=\"$xhci\""                      >> vars.sh
  echo "virtio=\"$virtio\""                  >> vars.sh
  echo "cpu=\"$cpu\""                        >> vars.sh
  echo "edk2bridge_1022=\"$pcibridge_1022\"" >> vars.sh
  echo "edk2bridge_8086=\"$pcibridge_8086\"" >> vars.sh
fi

QEMU_DEST="/usr/local/bin"

default_models=(
  "Acer SSD SA100 240GB"      "CT240BX500SSD1"
  "EMTCE X150 240GB"          "KINGSTON SA400S37240G"
  "Lexar SSD NQ100 240GB"     "MSI S270 240GB"
  "Patriot Burst Elite 240GB" "SanDisk SSD PLUS 240GB"
)

ide_cd_models=(
  "HL-DT-ST BD-RE BH16NS40"   "HL-DT-ST BD-RE WH16NS60"
  "HL-DT-ST DVDRAM GH22NS50"  "HL-DT-ST DVDRAM GH24NSC0"
  "Pioneer BDR-209DBK"        "Pioneer BDR-212DBK"
  "Pioneer DVR-221LBK"        "Pioneer DVR-S21WBK"
  "Samsung SE-208GB"          "Samsung SE-506BB"
  "Samsung SH-224FB"          "Samsung SH-B123L"
  "Sony BWU-500S"             "Sony DRU-870S"
  "Sony NEC Optiarc AD-5280S" "Sony NEC Optiarc AD-7261S"
  "Lite-On iHAS124-14"        "Lite-On iHAS324-17"
  "Lite-On eBAU108"           "Lite-On eTAU108"
)

ide_cfata_models=(
  "PNY Elite-X microSD"             "PNY Premier-X microSD"
  "Samsung EVO Plus microSDXC"      "Samsung PRO Plus microSDXC"
  "SanDisk Extreme microSDXC UHS-I" "SanDisk Ultra microSDXC UHS-I"
)

cpu_models=(
  "Intel(R) Core(TM) i7 CPU         880  @ 3.07GHz" #1
  "Intel(R) Core(TM) i7 CPU       K 875  @ 2.93GHz"
  "Intel(R) Core(TM) i7 CPU         870  @ 2.93GHz"
  "Intel(R) Core(TM) i7 CPU         860  @ 2.80GHz"
  "Intel(R) Core(TM) i7 CPU       S 870  @ 2.67GHz"
  "Intel(R) Core(TM) i7 CPU       S 860  @ 2.53GHz"
  "Intel(R) Core(TM) i5 CPU         760  @ 2.80GHz"
  "Intel(R) Core(TM) i5 CPU         750  @ 2.67GHz"
  "Intel(R) Core(TM) i5 CPU       S 750  @ 2.40GHz" #9

  "Intel(R) Core(TM) i7-2700K CPU @ 3.50GHz" #10
  "Intel(R) Core(TM) i7-2600K CPU @ 3.40GHz"
  "Intel(R) Core(TM) i7-2600 CPU @ 3.40GHz"
  "Intel(R) Core(TM) i7-2600S CPU @ 2.80GHz"
  "Intel(R) Core(TM) i5-2550K CPU @ 3.40GHz"
  "Intel(R) Core(TM) i5-2500K CPU @ 3.30GHz"
  "Intel(R) Core(TM) i5-2500 CPU @ 3.30GHz"
  "Intel(R) Core(TM) i5-2500S CPU @ 2.70GHz"
  "Intel(R) Core(TM) i5-2500T CPU @ 2.30GHz"
  "Intel(R) Core(TM) i5-2450P CPU @ 3.20GHz"
  "Intel(R) Core(TM) i5-2400 CPU @ 3.10GHz"
  "Intel(R) Core(TM) i5-2405S CPU @ 2.50GHz"
  "Intel(R) Core(TM) i5-2400S CPU @ 2.50GHz" #22

  "Intel(R) Core(TM) i7-4790K CPU @ 4.00GHz" #23
  "Intel(R) Core(TM) i7-4790 CPU @ 3.60GHz"
  "Intel(R) Core(TM) i7-4790S CPU @ 3.20GHz"
  "Intel(R) Core(TM) i7-4790T CPU @ 2.70GHz"
  "Intel(R) Core(TM) i7-4770K CPU @ 3.50GHz"
  "Intel(R) Core(TM) i7-4770 CPU @ 3.40GHz"
  "Intel(R) Core(TM) i7-4770S CPU @ 3.10GHz"
  "Intel(R) Core(TM) i7-4770T CPU @ 2.50GHz"
  "Intel(R) Core(TM) i5-4690K CPU @ 3.50GHz"
  "Intel(R) Core(TM) i5-4690 CPU @ 3.50GHz"
  "Intel(R) Core(TM) i5-4690S CPU @ 3.20GHz"
  "Intel(R) Core(TM) i5-4690T CPU @ 2.50GHz"
  "Intel(R) Core(TM) i5-4670K CPU @ 3.40GHz"
  "Intel(R) Core(TM) i5-4670 CPU @ 3.40GHz"
  "Intel(R) Core(TM) i5-4670S CPU @ 3.10GHz"
  "Intel(R) Core(TM) i5-4670T CPU @ 2.30GHz" #38

  "Intel(R) Core(TM) i7-8700K CPU @ 3.70GHz" #39
  "Intel(R) Core(TM) i7-8700 CPU @ 3.20GHz"
  "Intel(R) Core(TM) i7-8700T CPU @ 2.40GHz"
  "Intel(R) Core(TM) i5-8600K CPU @ 3.60GHz"
  "Intel(R) Core(TM) i5-8600 CPU @ 3.10GHz"
  "Intel(R) Core(TM) i5-8600T CPU @ 2.30GHz" #44
  "Intel(R) Core(TM) i7-8557U CPU @ 1.70GHz" #45
  "Intel(R) Core(TM) i5-8257U CPU @ 1.40GHz"
  "Intel(R) Core(TM) i3-8140U CPU @ 2.10GHz" #47
)

cpu_families=(
  "C6" #Intel® Core™ i7 processor
  "C6" #Intel® Core™ i7 processor
  "C6" #Intel® Core™ i7 processor
  "C6" #Intel® Core™ i7 processor
  "C6" #Intel® Core™ i7 processor
  "C6" #Intel® Core™ i7 processor
  "CD" #Intel® Core™ i5 processor
  "CD" #Intel® Core™ i5 processor
  "CD" #Intel® Core™ i5 processor

  "C6" #Intel® Core™ i7 processor
  "C6" #Intel® Core™ i7 processor
  "C6" #Intel® Core™ i7 processor
  "C6" #Intel® Core™ i7 processor
  "CD" #Intel® Core™ i5 processor
  "CD" #Intel® Core™ i5 processor
  "CD" #Intel® Core™ i5 processor
  "CD" #Intel® Core™ i5 processor
  "CD" #Intel® Core™ i5 processor
  "CD" #Intel® Core™ i5 processor
  "CD" #Intel® Core™ i5 processor
  "CD" #Intel® Core™ i5 processor
  "CD" #Intel® Core™ i5 processor

  "C6" #Intel® Core™ i7 processor
  "C6" #Intel® Core™ i7 processor
  "C6" #Intel® Core™ i7 processor
  "C6" #Intel® Core™ i7 processor
  "C6" #Intel® Core™ i7 processor
  "C6" #Intel® Core™ i7 processor
  "C6" #Intel® Core™ i7 processor
  "C6" #Intel® Core™ i7 processor
  "CD" #Intel® Core™ i5 processor
  "CD" #Intel® Core™ i5 processor
  "CD" #Intel® Core™ i5 processor
  "CD" #Intel® Core™ i5 processor
  "CD" #Intel® Core™ i5 processor
  "CD" #Intel® Core™ i5 processor
  "CD" #Intel® Core™ i5 processor
  "CD" #Intel® Core™ i5 processor

  "C6" #Intel® Core™ i7 processor
  "C6" #Intel® Core™ i7 processor
  "C6" #Intel® Core™ i7 processor
  "CD" #Intel® Core™ i5 processor
  "CD" #Intel® Core™ i5 processor
  "CD" #Intel® Core™ i5 processor
  "C6" #Intel® Core™ i7 processor
  "CD" #Intel® Core™ i5 processor
  "CE" #Intel® Core™ i3 processor
)

cpu_sockets=(
  "1D" #LGA 1156
  "1D" #LGA 1156
  "1D" #LGA 1156
  "1D" #LGA 1156
  "1D" #LGA 1156
  "1D" #LGA 1156
  "1D" #LGA 1156
  "1D" #LGA 1156
  "1D" #LGA 1156

  "24" #LGA 1155
  "24" #LGA 1155
  "24" #LGA 1155
  "24" #LGA 1155
  "24" #LGA 1155
  "24" #LGA 1155
  "24" #LGA 1155
  "24" #LGA 1155
  "24" #LGA 1155
  "24" #LGA 1155
  "24" #LGA 1155
  "24" #LGA 1155
  "24" #LGA 1155

  "2D" #LGA 1150
  "2D" #LGA 1150
  "2D" #LGA 1150
  "2D" #LGA 1150
  "2D" #LGA 1150
  "2D" #LGA 1150
  "2D" #LGA 1150
  "2D" #LGA 1150
  "2D" #LGA 1150
  "2D" #LGA 1150
  "2D" #LGA 1150
  "2D" #LGA 1150
  "2D" #LGA 1150
  "2D" #LGA 1150
  "2D" #LGA 1150
  "2D" #LGA 1150

  "32" #LGA 1151
  "32" #LGA 1151
  "32" #LGA 1151
  "32" #LGA 1151
  "32" #LGA 1151
  "32" #LGA 1151
  "3C" #BGA 1528
  "3C" #BGA 1528
  "3C" #BGA 1528
)

cpu_steppings=(
  "5"
  "5"
  "5"
  "5"
  "5"
  "5"
  "5"
  "5"
  "5"

  "7"
  "7"
  "7"
  "7"
  "7"
  "7"
  "7"
  "7"
  "7"
  "7"
  "7"
  "7"
  "7"

  "3"
  "3"
  "3"
  "3"
  "3"
  "3"
  "3"
  "3"
  "3"
  "3"
  "3"
  "3"
  "3"
  "3"
  "3"
  "3"

  "10"
  "10"
  "10"
  "10"
  "10"
  "10"
  "10"
  "10"
  "10"
)

get_random_element() {
  local array=("$@")
  echo "${array[RANDOM % ${#array[@]}]}"
}

new_ide_cd_model=$(get_random_element "${ide_cd_models[@]}")
new_ide_cfata_model=$(get_random_element "${ide_cfata_models[@]}")
new_default_model=$(get_random_element "${default_models[@]}")

get_random_string() { head /dev/urandom | tr -dc 'A-Z'    | head -c "$1"; }
get_random_serial() { head /dev/urandom | tr -dc 'A-Z0-9' | head -c "$1"; }
get_random_dec()    { head /dev/urandom | tr -dc '0-9'    | head -c "$1"; }
get_random_hex()    { head /dev/urandom | tr -dc '0-9A-F' | head -c "$1"; }

get_new_string() {
  local random_string=""
  local vowel_count=-1
  while [ $vowel_count -ne $2 ]
  do
    random_string="$(get_random_string 100)"
    new_string=$(echo $random_string | sed -E 's/(.)\1+/\1/g' | head -c $1)
    vowel_count=$(echo $new_string | grep -io '[aeiou]' | wc -l)
  done
  prefix=$(echo $new_string | head -c 1)
  suffix=$(echo $new_string | tail -c ${#new_string} | tr '[A-Z]' '[a-z]')
}

get_type_4_data() {
  local data=$(sudo hexdump -v -e '1/1 "%02X" ' "/sys/firmware/dmi/entries/4-0/raw")
  t4_processor_family="${data:12:2}"
  t4_voltage="${data:34:2}"
  t4_external_clock="${data:38:2}${data:36:2}"
  t4_max_speed="${data:42:2}${data:40:2}"
  t4_current_speed="${data:46:2}${data:44:2}"
  t4_processor_upgrade="${data:50:2}"
  t4_processor_characteristics="${data:78:2}${data:76:2}"
}

if [[ ! -d qemubackup ]]; then
  echo -e "$(pwd)/\e[1mqemubackup\e[0m does not exist, cloning..."
  git clone --single-branch --branch stable-11.0 https://github.com/qemu/qemu.git qemubackup
else
  echo -e "$(pwd)/\e[1mqemubackup\e[0m found."
fi

              file_vhdx_c="$(pwd)/qemu/block/vhdx.c"
             file_vvfat_c="$(pwd)/qemu/block/vvfat.c"
           file_msmouse_c="$(pwd)/qemu/chardev/msmouse.c"
          file_wctablet_c="$(pwd)/qemu/chardev/wctablet.c"
      file_vhostusergpu_c="$(pwd)/qemu/contrib/vhost-user-gpu/vhost-user-gpu.c"
          file_amlbuild_c="$(pwd)/qemu/hw/acpi/aml-build.c"
         file_acpi_core_c="$(pwd)/qemu/hw/acpi/core.c"
          file_acpi_cpu_c="$(pwd)/qemu/hw/acpi/cpu.c"
             file_pcihp_c="$(pwd)/qemu/hw/acpi/pcihp.c"
          file_hdacodec_c="$(pwd)/qemu/hw/audio/hda-codec.c"
    file_hdacodeccommon_h="$(pwd)/qemu/hw/audio/hda-codec-common.h"
          file_intelhda_c="$(pwd)/qemu/hw/audio/intel-hda.c"
              file_escc_c="$(pwd)/qemu/hw/char/escc.c"
#        file_serialpci_c="$(pwd)/qemu/hw/char/serial-pci.c"
      file_edidgenerate_c="$(pwd)/qemu/hw/display/edid-generate.c"
         file_acpibuild_c="$(pwd)/qemu/hw/i386/acpi-build.c"
        file_acpicommon_c="$(pwd)/qemu/hw/i386/acpi-common.c" #
        file_i386_fwcfg_c="$(pwd)/qemu/hw/i386/fw_cfg.c"
         file_multiboot_c="$(pwd)/qemu/hw/i386/multiboot.c"
                file_pc_c="$(pwd)/qemu/hw/i386/pc.c"
#           file_pcpiix_c="$(pwd)/qemu/hw/i386/pc_piix.c"
             file_pcq35_c="$(pwd)/qemu/hw/i386/pc_q35.c"
         file_smbusich9_c="$(pwd)/qemu/hw/i2c/smbus_ich9.c"
             file_atapi_c="$(pwd)/qemu/hw/ide/atapi.c"
          file_ide_core_c="$(pwd)/qemu/hw/ide/core.c"
               file_ich_c="$(pwd)/qemu/hw/ide/ich.c"
            file_adbkbd_c="$(pwd)/qemu/hw/input/adb-kbd.c"
          file_adbmouse_c="$(pwd)/qemu/hw/input/adb-mouse.c"
#          file_ads7846_c="$(pwd)/qemu/hw/input/ads7846.c"
               file_hid_c="$(pwd)/qemu/hw/input/hid.c"
               file_ps2_c="$(pwd)/qemu/hw/input/ps2.c"
#          file_tsc2005_c="$(pwd)/qemu/hw/input/tsc2005.c"
#          file_tsc210x_c="$(pwd)/qemu/hw/input/tsc210x.c"
    file_virtioinputhid_c="$(pwd)/qemu/hw/input/virtio-input-hid.c"
              file_piix_c="$(pwd)/qemu/hw/isa/piix.c"
           file_lpcich9_c="$(pwd)/qemu/hw/isa/lpc_ich9.c"
        file_ivshmempci_c="$(pwd)/qemu/hw/misc/ivshmem-pci.c"
        file_pvpanicisa_c="$(pwd)/qemu/hw/misc/pvpanic-isa.c"
        file_e1000xregs_h="$(pwd)/qemu/hw/net/e1000x_regs.h"
             file_Kconfig="$(pwd)/qemu/hw/net/Kconfig"
          file_mesonbuild="$(pwd)/qemu/hw/net/meson.build"
              file_ctrl_c="$(pwd)/qemu/hw/nvme/ctrl.c"
       file_nvram_fwcfg_c="$(pwd)/qemu/hw/nvram/fw_cfg.c"
         file_fwcfgacpi_c="$(pwd)/qemu/hw/nvram/fw_cfg-acpi.c"
               file_pci_c="$(pwd)/qemu/hw/pci/pci.c"
              file_gpex_c="$(pwd)/qemu/hw/pci-host/gpex.c"
         file_mptconfig_c="$(pwd)/qemu/hw/scsi/mptconfig.c"
           file_scsibus_c="$(pwd)/qemu/hw/scsi/scsi-bus.c"
          file_scsidisk_c="$(pwd)/qemu/hw/scsi/scsi-disk.c"
        file_spaprvscsi_c="$(pwd)/qemu/hw/scsi/spapr_vscsi.c"
file_smbios="$(pwd)/qemu/hw/smbios/smbios.c"
                file_lu_c="$(pwd)/qemu/hw/ufs/lu.c"
          file_devaudio_c="$(pwd)/qemu/hw/usb/dev-audio.c"
            file_devhid_c="$(pwd)/qemu/hw/usb/dev-hid.c"
            file_devhub_c="$(pwd)/qemu/hw/usb/dev-hub.c"
            file_devmtp_c="$(pwd)/qemu/hw/usb/dev-mtp.c"
        file_devnetwork_c="$(pwd)/qemu/hw/usb/dev-network.c"
         file_devserial_c="$(pwd)/qemu/hw/usb/dev-serial.c"
file_devsmartcardreader_c="$(pwd)/qemu/hw/usb/dev-smartcard-reader.c"
        file_devstorage_c="$(pwd)/qemu/hw/usb/dev-storage.c"
            file_devuas_c="$(pwd)/qemu/hw/usb/dev-uas.c"
          file_devwacom_c="$(pwd)/qemu/hw/usb/dev-wacom.c"
#          file_hcduhci_c="$(pwd)/qemu/hw/usb/hcd-uhci.c"
#       file_hcdehcipci_c="$(pwd)/qemu/hw/usb/hcd-ehci-pci.c"
               file_u2f_c="$(pwd)/qemu/hw/usb/u2f.c"
       file_u2femulated_c="$(pwd)/qemu/hw/usb/u2f-emulated.c"
       file_u2fpassthru_c="$(pwd)/qemu/hw/usb/u2f-passthru.c"
          file_amlbuild_h="$(pwd)/qemu/include/hw/acpi/aml-build.h"
         file_pchotplug_h="$(pwd)/qemu/include/hw/acpi/pc-hotplug.h"
            file_smbios_h="$(pwd)/qemu/include/hw/firmware/smbios.h"
          file_topology_h="$(pwd)/qemu/include/hw/i386/topology.h" #
               file_x86_h="$(pwd)/qemu/include/hw/i386/x86.h"
               file_pci_h="$(pwd)/qemu/include/hw/pci/pci.h"
            file_pciids_h="$(pwd)/qemu/include/hw/pci/pci_ids.h"
              file_ich9_h="$(pwd)/qemu/include/hw/southbridge/ich9.h"
         file_qemufwcfg_h="$(pwd)/qemu/include/standard-headers/linux/qemu_fw_cfg.h"
         file_optionrom_h="$(pwd)/qemu/pc-bios/optionrom/optionrom.h"
#       file_configvgaqxl="$(pwd)/qemu/roms/config.vga-qxl"
            file_makefile="$(pwd)/qemu/roms/Makefile"
               file_cpu_c="$(pwd)/qemu/target/i386/cpu.c"
               file_cpu_h="$(pwd)/qemu/target/i386/cpu.h"
               file_kvm_c="$(pwd)/qemu/target/i386/kvm/kvm.c"
            file_kvmcpu_c="$(pwd)/qemu/target/i386/kvm/kvm-cpu.c"
               file_ssdt1="$(pwd)/qemu/ssdt1.dsl"
               file_ssdt2="$(pwd)/qemu/ssdt2.dsl"

if [[ -f "$file_vhdx_c" ]]; then rm "$file_vhdx_c"; fi
if [[ -f "$file_vvfat_c" ]]; then rm "$file_vvfat_c"; fi
if [[ -f "$file_msmouse_c" ]]; then rm "$file_msmouse_c"; fi
if [[ -f "$file_wctablet_c" ]]; then rm "$file_wctablet_c"; fi
if [[ -f "$file_vhostusergpu_c" ]]; then rm "$file_vhostusergpu_c"; fi
if [[ -f "$file_amlbuild_c" ]]; then rm "$file_amlbuild_c"; fi
if [[ -f "$file_acpi_core_c" ]]; then rm "$file_acpi_core_c"; fi
if [[ -f "$file_acpi_cpu_c" ]]; then rm "$file_acpi_cpu_c"; fi
if [[ -f "$file_pcihp_c" ]]; then rm "$file_pcihp_c"; fi
if [[ -f "$file_hdacodec_c" ]]; then rm "$file_hdacodec_c"; fi
if [[ -f "$file_hdacodeccommon_h" ]]; then rm "$file_hdacodeccommon_h"; fi
if [[ -f "$file_intelhda_c" ]]; then rm "$file_intelhda_c"; fi
if [[ -f "$file_escc_c" ]]; then rm "$file_escc_c"; fi
#if [[ -f "$file_serialpci_c" ]]; then rm "$file_serialpci_c"; fi
if [[ -f "$file_edidgenerate_c" ]]; then rm "$file_edidgenerate_c"; fi
if [[ -f "$file_acpibuild_c" ]]; then rm "$file_acpibuild_c"; fi
if [[ -f "$file_acpicommon_c" ]]; then rm "$file_acpicommon_c"; fi #
if [[ -f "$file_i386_fwcfg_c" ]]; then rm "$file_i386_fwcfg_c"; fi
if [[ -f "$file_multiboot_c" ]]; then rm "$file_multiboot_c"; fi
if [[ -f "$file_pc_c" ]]; then rm "$file_pc_c"; fi
#if [[ -f "$file_pcpiix_c" ]]; then rm "$file_pcpiix_c"; fi
if [[ -f "$file_pcq35_c" ]]; then rm "$file_pcq35_c"; fi
if [[ -f "$file_smbusich9_c" ]]; then rm "$file_smbusich9_c"; fi
if [[ -f "$file_atapi_c" ]]; then rm "$file_atapi_c"; fi
if [[ -f "$file_ide_core_c" ]]; then rm "$file_ide_core_c"; fi
if [[ -f "$file_ich_c" ]]; then rm "$file_ich_c"; fi
if [[ -f "$file_adbkbd_c" ]]; then rm "$file_adbkbd_c"; fi
if [[ -f "$file_adbmouse_c" ]]; then rm "$file_adbmouse_c"; fi
#if [[ -f "$file_ads7846_c" ]]; then rm "$file_ads7846_c"; fi
if [[ -f "$file_hid_c" ]]; then rm "$file_hid_c"; fi
if [[ -f "$file_ps2_c" ]]; then rm "$file_ps2_c"; fi
#if [[ -f "$file_tsc2005_c" ]]; then rm "$file_tsc2005_c"; fi
#if [[ -f "$file_tsc210x_c" ]]; then rm "$file_tsc210x_c"; fi
if [[ -f "$file_virtioinputhid_c" ]]; then rm "$file_virtioinputhid_c"; fi
if [[ -f "$file_piix_c" ]]; then rm "$file_piix_c"; fi
if [[ -f "$file_lpcich9_c" ]]; then rm "$file_lpcich9_c"; fi
if [[ -f "$file_ivshmempci_c" ]]; then rm "$file_ivshmempci_c"; fi
if [[ -f "$file_pvpanicisa_c" ]]; then rm "$file_pvpanicisa_c"; fi
if [[ -f "$file_e1000xregs_h" ]]; then rm "$file_e1000xregs_h"; fi
if [[ -f "$file_Kconfig" ]]; then rm "$file_Kconfig"; fi
if [[ -f "$file_mesonbuild" ]]; then rm "$file_mesonbuild"; fi
if [[ -f "$file_ctrl_c" ]]; then rm "$file_ctrl_c"; fi
if [[ -f "$file_nvram_fwcfg_c" ]]; then rm "$file_nvram_fwcfg_c"; fi
if [[ -f "$file_fwcfgacpi_c" ]]; then rm "$file_fwcfgacpi_c"; fi
if [[ -f "$file_pci_c" ]]; then rm "$file_pci_c"; fi
if [[ -f "$file_gpex_c" ]]; then rm "$file_gpex_c"; fi
if [[ -f "$file_mptconfig_c" ]]; then rm "$file_mptconfig_c"; fi
if [[ -f "$file_scsibus_c" ]]; then rm "$file_scsibus_c"; fi
if [[ -f "$file_scsidisk_c" ]]; then rm "$file_scsidisk_c"; fi
if [[ -f "$file_spaprvscsi_c" ]]; then rm "$file_spaprvscsi_c"; fi
if [[ -f "$file_smbios" ]]; then rm "$file_smbios"; fi
if [[ -f "$file_lu_c" ]]; then rm "$file_lu_c"; fi
if [[ -f "$file_devaudio_c" ]]; then rm "$file_devaudio_c"; fi
if [[ -f "$file_devhid_c" ]]; then rm "$file_devhid_c"; fi
if [[ -f "$file_devhub_c" ]]; then rm "$file_devhub_c"; fi
if [[ -f "$file_devmtp_c" ]]; then rm "$file_devmtp_c"; fi
if [[ -f "$file_devnetwork_c" ]]; then rm "$file_devnetwork_c"; fi
if [[ -f "$file_devserial_c" ]]; then rm "$file_devserial_c"; fi
if [[ -f "$file_devsmartcardreader_c" ]]; then rm "$file_devsmartcardreader_c"; fi
if [[ -f "$file_devstorage_c" ]]; then rm "$file_devstorage_c"; fi
if [[ -f "$file_devuas_c" ]]; then rm "$file_devuas_c"; fi
if [[ -f "$file_devwacom_c" ]]; then rm "$file_devwacom_c"; fi
#if [[ -f "$file_hcduhci_c" ]]; then rm "$file_hcduhci_c"; fi
#if [[ -f "$file_hcdehcipci_c" ]]; then rm "$file_hcdehcipci_c"; fi
if [[ -f "$file_u2f_c" ]]; then rm "$file_u2f_c"; fi
if [[ -f "$file_u2femulated_c" ]]; then rm "$file_u2femulated_c"; fi
if [[ -f "$file_u2fpassthru_c" ]]; then rm "$file_u2fpassthru_c"; fi
if [[ -f "$file_amlbuild_h" ]]; then rm "$file_amlbuild_h"; fi
if [[ -f "$file_pchotplug_h" ]]; then rm "$file_pchotplug_h"; fi
if [[ -f "$file_smbios_h" ]]; then rm "$file_smbios_h"; fi
if [[ -f "$file_topology_h" ]]; then rm "$file_topology_h"; fi #
if [[ -f "$file_x86_h" ]]; then rm "$file_x86_h"; fi
if [[ -f "$file_pci_h" ]]; then rm "$file_pci_h"; fi
if [[ -f "$file_pciids_h" ]]; then rm "$file_pciids_h"; fi
if [[ -f "$file_ich9_h" ]]; then rm "$file_ich9_h"; fi
if [[ -f "$file_qemufwcfg_h" ]]; then rm "$file_qemufwcfg_h"; fi
if [[ -f "$file_optionrom_h" ]]; then rm "$file_optionrom_h"; fi
#if [[ -f "$file_configvgaqxl" ]]; then rm "$file_configvgaqxl"; fi
if [[ -f "$file_makefile" ]]; then rm "$file_makefile"; fi
if [[ -f "$file_cpu_c" ]]; then rm "$file_cpu_c"; fi
if [[ -f "$file_cpu_h" ]]; then rm "$file_cpu_h"; fi
if [[ -f "$file_kvm_c" ]]; then rm "$file_kvm_c"; fi
if [[ -f "$file_kvmcpu_c" ]]; then rm "$file_kvmcpu_c"; fi
if [[ -f "$file_ssdt1" ]]; then rm "$file_ssdt1"; fi
if [[ -f "$file_ssdt2" ]]; then rm "$file_ssdt2"; fi
mkdir -p qemu
cp -fr qemubackup/. qemu
cp -f *.dsl qemu
#cp -f *.aml qemu
mkdir -p qemu/hw/net
cp -f rtl8125.c qemu/hw/net/rtl8125.c

echo "  $file_vhdx_c"
get_new_string 4 1
echo "QEMU v                                            -> $new_string v"
sed -i "$file_vhdx_c" -Ee "s/QEMU v/$new_string v/"

echo "  $file_vvfat_c"
get_new_string 6 3
echo "QEMU VVFAT                                        -> $new_string FAT"
sed -i "$file_vvfat_c" -Ee "s/QEMU VVFAT/$new_string FAT/"

echo "  $file_msmouse_c"
echo "QEMU Microsoft Mouse                              -> Microsoft Mouse"
sed -i "$file_msmouse_c" -Ee "s/QEMU Microsoft Mouse/Microsoft Mouse/"

echo "  $file_wctablet_c"
echo "QEMU Wacom Pen Tablet                             -> Wacom Pen Tablet"
sed -i "$file_wctablet_c" -Ee "s/QEMU Wacom Pen Tablet/Wacom Pen Tablet/"

IFS=':'
cpu_vendor=( $(cat /proc/cpuinfo | grep 'vendor_id' | uniq) )
cpu_vendor="${cpu_vendor[1]}"
cpu_name=( $(cat /proc/cpuinfo | grep 'model name' | uniq) )
cpu_name="${cpu_name[1]}"
unset IFS

echo "  $file_vhostusergpu_c"
if [[ "${cpu_vendor:1}" == "AuthenticAMD" ]]; then
  echo "QEMU vhost-user-gpu                               -> AMD Radeon(TM) Graphics"
  sed -i "$file_vhostusergpu_c" -Ee "s/QEMU vhost-user-gpu/AMD Radeon(TM) Graphics/"
else
  echo "QEMU vhost-user-gpu                               -> Intel(R) HD Graphics"
  sed -i "$file_vhostusergpu_c" -Ee "s/QEMU vhost-user-gpu/Intel(R) HD Graphics/"
fi

echo "  $file_amlbuild_c"
chassis_type=$(sudo dmidecode --string chassis-type)
#chassis_type="Desktop"
if [[ "$chassis_type" == "Desktop" ]]; then
  pm_type="1"
else
  pm_type="2"
fi
sed -i "$file_amlbuild_c" -e  's/build_append_int_noprefix(tbl, 0 \/\* Unspecified \*\//build_append_int_noprefix(tbl, '"$pm_type"' \/\* '"$chassis_type"' \*\//'
echo "    if (f->rev <= 4) {"
echo "        v v v v v v v v v v v v v v v v v v v v v v v v v v"
echo "        build_append_int_noprefix(tbl, 0, 1); /* Reserved */"
##sed -i "$file_amlbuild_c" -Ee "/    if \(f->rev <= 4\) \{/a\        build_append_int_noprefix(tbl, 0, 1); /* Reserved */"
get_new_string $(shuf -i 5-7 -n 1) 3
echo "\"QEMU\"                                            -> \"$prefix$suffix\""
sed -i "$file_amlbuild_c" -Ee "s/\"QEMU\"/\"$prefix$suffix\"/"

get_le_hex() {
  local offset=$1
  local len=$2
  local hex=""
  for (( i=offset+len-1; i>=offset; i-- )); do
    hex+="${bytes[$i]}"
  done
  echo "$hex"
}

get_dsdt_data() {
  local hex_data=$(sudo hexdump -v -n 36 -e '1/1 "%02X "' "/sys/firmware/acpi/tables/DSDT")
  bytes=($hex_data)

  get_ascii() {
    local offset=$1
    local len=$2
    local str=""
    for (( i=offset; i<offset+len; i++ )); do
      local char
      printf -v char "\x${bytes[$i]}"
      str+="$char"
    done
    echo "$str"
  }

  dsdt_sig=$(get_ascii 0 4 "${bytes[@]}")
  dsdt_len=$(get_le_hex 4 4)
  dsdt_rev="${bytes[8]}"
  dsdt_sum="${bytes[9]}"
  dsdt_oem_id=$(get_ascii 10 6)
  dsdt_oem_table=$(get_ascii 16 8)
  dsdt_oem_rev=$(get_le_hex 24 4)
  dsdt_asl_id=$(get_ascii 28 4)
  dsdt_asl_rev=$(get_le_hex 32 4)
}

get_dsdt_data

echo "  $file_acpi_core_c"
echo "\"QEMU\0\0\0\0\1\0\"                                -> \"$dsdt_sig\0\0\0\0\" \"\x$dsdt_rev\" \"\0\""
sed -i "$file_acpi_core_c" -Ee "s/\"QEMU\\\\0\\\\0\\\\0\\\\0\\\\1\\\\0\"/\"$dsdt_sig\\\\0\\\\0\\\\0\\\\0\" \"\\\\x$dsdt_rev\" \"\\\\0\"            /"
echo "\"QEMUQEQEMUQEMU\1\0\0\0\"                          -> \"$dsdt_oem_id$dsdt_oem_table\" \"\x${dsdt_oem_rev:6:2}\" \"\x${dsdt_oem_rev:4:2}\" \"\x${dsdt_oem_rev:2:2}\" \"\x${dsdt_oem_rev:0:2}\""
sed -i "$file_acpi_core_c" -Ee "s/\"QEMUQEQEMUQEMU\\\\1\\\\0\\\\0\\\\0\"/\"$dsdt_oem_id$dsdt_oem_table\" \"\\\\x${dsdt_oem_rev:6:2}\" \"\\\\x${dsdt_oem_rev:4:2}\" \"\\\\x${dsdt_oem_rev:2:2}\" \"\\\\x${dsdt_oem_rev:0:2}\"/"
echo "\"QEMU\1\0\0\0\"                                    -> \"$dsdt_asl_id\" \"\x${dsdt_asl_rev:6:2}\" \"\x${dsdt_asl_rev:4:2}\" \"\x${dsdt_asl_rev:2:2}\" \"\x${dsdt_asl_rev:0:2}\""
sed -i "$file_acpi_core_c" -Ee "s/\"QEMU\\\\1\\\\0\\\\0\\\\0\"/\"$dsdt_asl_id\" \"\\\\x${dsdt_asl_rev:6:2}\" \"\\\\x${dsdt_asl_rev:4:2}\" \"\\\\x${dsdt_asl_rev:2:2}\" \"\\\\x${dsdt_asl_rev:0:2}\"/"

echo "  $file_acpi_cpu_c"
get_new_string $(shuf -i 5-7 -n 1) 3
echo "CPU Hotplug resources                             -> CPU $prefix$suffix"
sed -i "$file_acpi_cpu_c" -Ee "s/CPU Hotplug resources/CPU $prefix$suffix/"

echo "  $file_pcihp_c"
get_new_string 4 1
echo "PHPR                                              -> $new_string"
sed -i "$file_pcihp_c" -Ee "s/PHPR/$new_string/"
get_new_string $(shuf -i 5-7 -n 1) 3
echo "PCI Hotplug resources                             -> PCI $prefix$suffix"
sed -i "$file_pcihp_c" -Ee "s/PCI Hotplug resources/PCI $prefix$suffix/"
sed -i "$file_pcihp_c" -e  '/        \/\* add _EJ0 to make slot hotpluggable/{n;N;N;N;N;d;}'
sed -i "$file_pcihp_c" -Ee "/        \/\* add _EJ0 to make slot hotpluggable/a\        method = aml_method(\"_RMV\", 0, AML_NOTSERIALIZED);\n\
        aml_append(method, aml_return(aml_int(0)));\n\
        aml_append(dev, method);"
path=$(head /dev/urandom | tr -dc 'AEIOU' | head -c 1)$(head /dev/urandom | tr -dc 'B-DF-HJ-NP-RTV-Z' | head -c 1)
echo "S%.02X                                            -> $path%.02X"
#sed -i "$file_pcihp_c" -Ee "s/S%.02X/$path%.02X/"
if [[ "${cpu_vendor:1}" == "AuthenticAMD" ]]; then
  sed -i "$file_pcihp_c" -Ee "/bool build_append_notification_callback\(Aml \*parent_scope, const PCIBus \*bus\)/istatic void get_pci_name(char *cstr, int devfn)\n\
{\n\
    int slot = PCI_SLOT(devfn);\n\
    int func = PCI_FUNC(devfn);\n\
    switch (slot) {\n\
        case 20:\n\
            if (func == 0) sprintf(cstr, \"SBUS\");\n\
            else if (func == 3) sprintf(cstr, \"LPCB\");\n\
            else sprintf(cstr, \"$path%.02X\", devfn);\n\
            break;\n\
        case 27:\n\
            if (func == 0) sprintf(cstr, \"AZAL\");\n\
            else sprintf(cstr, \"$path%.02X\", devfn);\n\
            break;\n\
        case 29:\n\
            sprintf(cstr, \"EHC%X\", func);\n\
            break;\n\
        case 31:\n\
            if (func == 2) sprintf(cstr, \"SAT%X\", func);\n\
            else sprintf(cstr, \"$path%.02X\", devfn);\n\
            break;\n\
        default:\n\
            sprintf(cstr, \"$path%.02X\", devfn);\n\
            break;\n\
    }\n}\n"
else
  sed -i "$file_pcihp_c" -Ee "/bool build_append_notification_callback\(Aml \*parent_scope, const PCIBus \*bus\)/istatic void get_pci_name(char *cstr, int devfn)\n\
{\n\
    int slot = PCI_SLOT(devfn);\n\
    int func = PCI_FUNC(devfn);\n\
    switch (slot) {\n\
        case 27:\n\
            if (func == 0) sprintf(cstr, \"HDEF\");\n\
            else sprintf(cstr, \"$path%.02X\", devfn);\n\
            break;\n\
        case 29:\n\
            sprintf(cstr, \"EHC%X\", func);\n\
            break;\n\
        case 31:\n\
            if (func == 0) sprintf(cstr, \"LPCB\");\n\
            else if (func == 2) sprintf(cstr, \"SAT%X\", func);\n\
            else if (func == 4) sprintf(cstr, \"SBUS\");\n\
            else sprintf(cstr, \"$path%.02X\", devfn);\n\
            break;\n\
        default:\n\
            sprintf(cstr, \"$path%.02X\", devfn);\n\
            break;\n\
    }\n}\n"
fi
sed -i "$file_pcihp_c" -Ee "/    QLIST_FOREACH\(sec, &bus->child, sibling\) \{/{n;d;}"
sed -i "$file_pcihp_c" -Ee "/    QLIST_FOREACH\(sec, &bus->child, sibling\) \{/a\        char pci_name[5] = {0};\n\
        get_pci_name(pci_name, sec->parent_dev->devfn);\n\
        Aml *br_scope = aml_scope(\"%s\", pci_name);"
sed -i "$file_pcihp_c" -Ee "s/        aml_append\(method, aml_name\(\"\^S%.02X.PCNT\", sec->parent_dev->devfn\)\);/        char pci_name[5] = {0};\n\
        get_pci_name(pci_name, sec->parent_dev->devfn);\n\
        aml_append(method, aml_name(\"^%s.PCNT\", pci_name));/"
sed -i "$file_pcihp_c" -Ee "s/    aml_append\(if_ctx, aml_notify\(aml_name\(\"S%.02X\", devfn\), aml_arg\(1\)\)\);/    char pci_name[5] = {0};\n\
    get_pci_name(pci_name, devfn);\n\
    aml_append(if_ctx, aml_notify(aml_name(\"%s\", pci_name), aml_arg(1)));/"
sed -i "$file_pcihp_c" -Ee "/        if \(bus->devices\[devfn\]\) \{/i\        char pci_name[5] = {0};\n\
        get_pci_name(pci_name, devfn);"
sed -i "$file_pcihp_c" -Ee "/        if \(bus->devices\[devfn\]\) \{/{ n; s/            dev = aml_scope\(\"S%.02X\", devfn\);/            dev = aml_scope(\"%s\", pci_name);/ }"
sed -i "$file_pcihp_c" -Ee "/        if \(bus->devices\[devfn\]\) \{/{ n;n;n; s/            dev = aml_device\(\"S%.02X\", devfn\);/            dev = aml_device(\"%s\", pci_name);/ }"
sed -i "$file_pcihp_c" -Ee "s/        dev = aml_device\(\"S%.02X\", devfn\);/        char pci_name[5] = {0};\n\
        get_pci_name(pci_name, devfn);\n\
        dev = aml_device(\"%s\", pci_name);/"

echo "  $file_hdacodec_c"
echo "0x1af4                                            -> 0x10EC"
sed -i "$file_hdacodec_c" -Ee "s/0x1af4/0x10EC/"

echo "  $file_hdacodeccommon_h"
echo "((QEMU_HDA_ID_VENDOR << 16) | 0x22)               -> ((QEMU_HDA_ID_VENDOR << 16) | 0x1220)  // Realtek ALC1220 CODEC"
sed -i "$file_hdacodeccommon_h" -Ee "s/\(\(QEMU_HDA_ID_VENDOR << 16\) \| 0x22\)/((QEMU_HDA_ID_VENDOR << 16) | 0x1220)  \/\/ Realtek ALC1220 CODEC/"

echo "  $file_intelhda_c"
if [[ "${cpu_vendor:1}" == "AuthenticAMD" ]]; then
  echo "PCI_VENDOR_ID_INTEL;                              -> 0x1022;"
  echo "0x293e;                                           -> 0x1637;  // Renoir HD Audio Controller"
  echo "Intel HD Audio Controller (ich9)                  -> Renoir HD Audio Controller"
  sed -i "$file_intelhda_c" -Ee "s/PCI_VENDOR_ID_INTEL;/0x1022;/"
  sed -i "$file_intelhda_c" -Ee "s/0x293e;/0x$hdaudio_1022;/"
  sed -i "$file_intelhda_c" -Ee "s/Intel HD Audio Controller \(ich9\)/$hdaname_1022/"
else
  echo "PCI_VENDOR_ID_INTEL;                              -> 0x8086;"
  echo "0x293e;                                           -> 0xA3F0;  // Comet Lake PCH-V cAVS"
  echo "Intel HD Audio Controller (ich9)                  -> Comet Lake PCH-V cAVS"
  sed -i "$file_intelhda_c" -Ee "s/PCI_VENDOR_ID_INTEL;/0x8086;/"
  sed -i "$file_intelhda_c" -Ee "s/0x293e;/0x$hdaudio_8086;/"
  sed -i "$file_intelhda_c" -Ee "s/Intel HD Audio Controller \(ich9\)/$hdaname_8086/"
fi

echo "  $file_escc_c"
echo "QEMU Sun Mouse                                    -> Sun Mouse"
sed -i "$file_escc_c" -Ee "s/QEMU Sun Mouse/Sun Mouse/"

#echo "  $file_serialpci_c"

echo "  $file_edidgenerate_c"
get_new_string 3 0
echo "RHT                                               -> $new_string"
sed -i "$file_edidgenerate_c" -Ee "s/RHT/$new_string/"
get_new_string $(shuf -i 5-7 -n 1) 3
word=$(get_random_hex 4)
week=$(shuf -i 1-52 -n 1)
year=$(shuf -i 15-35 -n 1)
echo "QEMU Monitor                                      -> $prefix$suffix"
#echo "prefx = 1280                                      -> prefx = 1024"
#echo "prefy = 800                                       -> prefy = 768"
echo "0x1234                                            -> 0x$word"
echo "edid[16] = 42                                     -> edid[16] = $week"
echo "edid[17] = 2014 - 1990                            -> edid[17] = $year"
sed -i "$file_edidgenerate_c" -Ee "s/QEMU Monitor/$prefix$suffix/"
#sed -i "$file_edidgenerate_c" -Ee "s/prefx = 1280/prefx = 1024/"
#sed -i "$file_edidgenerate_c" -Ee "s/prefy = 800/prefy = 768/"
sed -i "$file_edidgenerate_c" -Ee "s/0x1234/0x$word/"
sed -i "$file_edidgenerate_c" -Ee "s/edid\[16\] = 42/edid\[16\] = $week/"
sed -i "$file_edidgenerate_c" -Ee "s/edid\[17\] = 2014 - 1990/edid\[17\] = $year/"

get_fadt_data() {
  local hex_data=$(sudo hexdump -v -n 100 -e '1/1 "%02X "' "/sys/firmware/acpi/tables/FACP")
  bytes=($hex_data)

  fadt_plvl2_lat=$(get_le_hex 96 2)
  fadt_plvl3_lat=$(get_le_hex 98 2)
}

get_fadt_data

echo "  $file_acpibuild_c"
echo ".rev = 3,                                         -> .rev = 4,"
echo ".plvl2_lat = 0xfff                                -> .plvl2_lat = 0x$fadt_plvl2_lat"
echo ".plvl3_lat = 0xfff                                -> .plvl3_lat = 0x$fadt_plvl3_lat"
sed -i "$file_acpibuild_c" -Ee "s/.rev = 3,/.rev = 4,/"
sed -i "$file_acpibuild_c" -Ee "s/.plvl2_lat = 0xfff/.plvl2_lat = 0x$fadt_plvl2_lat/"
sed -i "$file_acpibuild_c" -Ee "s/.plvl3_lat = 0xfff/.plvl3_lat = 0x$fadt_plvl3_lat/"
get_new_string 2 0
echo "\"VMBS\"                                            -> \"${new_string}BS\""
echo "\"VMBus\"                                           -> \"${new_string}BUS\""
echo "\"VMBUS\"                                           -> \"${new_string}BUS\""
sed -i "$file_acpibuild_c" -Ee "s/\"VMBS\"/\"${new_string}BS\"/"
sed -i "$file_acpibuild_c" -Ee "s/\"VMBus\"/\"${new_string}BUS\"/"
sed -i "$file_acpibuild_c" -Ee "s/\"VMBUS\"/\"${new_string}BUS\"/"
sed -i "$file_acpibuild_c" -e  '/static void build_dbg_aml(Aml \*table)/{N;N;N;N;N;N;N;N;N;N;N;N;N;N;N;N;N;N;N;N;N;N;N;N;N;N;N;N;N;N;N;N;N;N;d;}'
get_new_string 3 0
prt=$new_string
get_new_string 3 0
lnk=$new_string
get_new_string 3 0
gsi=$new_string
echo "PRTP\", build_q35_routing_table(\"LNK               -> ${prt}P\", build_q35_routing_table(\"${lnk}"
echo "PRTA\", build_q35_routing_table(\"GSI               -> ${prt}A\", build_q35_routing_table(\"${gsi}"
echo "aml_return(aml_name(\"PRT                          -> aml_return(aml_name(\"${prt}"
sed -i "$file_acpibuild_c" -Ee "s/PRTP\", build_q35_routing_table\(\"LNK/${prt}P\", build_q35_routing_table(\"${lnk}/"
sed -i "$file_acpibuild_c" -Ee "s/PRTA\", build_q35_routing_table\(\"GSI/${prt}A\", build_q35_routing_table(\"${gsi}/"
sed -i "$file_acpibuild_c" -Ee "s/aml_return\(aml_name\(\"PRT/aml_return(aml_name(\"${prt}/g"
echo "LNKD\", \"LNKA\", \"LNKB\", \"LNKC                      -> ${lnk}D\", \"${lnk}A\", \"${lnk}B\", \"${lnk}C"
sed -i "$file_acpibuild_c" -Ee "s/LNKD\", \"LNKA\", \"LNKB\", \"LNKC/${lnk}D\", \"${lnk}A\", \"${lnk}B\", \"${lnk}C/"
echo "build_link_dev(\"LNK                               -> build_link_dev(\"${lnk}"
echo "build_gsi_link_dev(\"GSI                           -> build_gsi_link_dev(\"${gsi}"
echo "DRAC                                              -> MEMC"
sed -i "$file_acpibuild_c" -Ee "s/build_link_dev\(\"LNK/build_link_dev(\"${lnk}/g"
sed -i "$file_acpibuild_c" -Ee "s/build_gsi_link_dev\(\"GSI/build_gsi_link_dev(\"${gsi}/g"
sed -i "$file_acpibuild_c" -Ee "s/DRAC/MEMC/"
sed -i "$file_acpibuild_c" -e  '/build_dbg_aml(dsdt);/{d;}'
echo "aml_string(\"SMI resources\")));                    -> aml_int(1)));"
echo "aml_string(\"GPE0 resources\")));                   -> aml_int(2)));"
sed -i "$file_acpibuild_c" -Ee "s/aml_string\(\"SMI resources\"\)\)\);/aml_int(1)));/"
sed -i "$file_acpibuild_c" -Ee "s/aml_string\(\"GPE0 resources\"\)\)\);/aml_int(2)));/"
sed -i "$file_acpibuild_c" -e  '/create fw_cfg node, unconditionally/{n;N;N;N;N;d;}'
sed -i "$file_acpibuild_c" -e  '/Windows ACPI Emulated Devices Table/{n;n;n;n;n;n;N;N;N;N;N;N;N;N;N;N;N;N;N;N;N;N;N;d;}'
sed -i "$file_acpibuild_c" -e  '/x86ms->oem_id, x86ms->oem_table_id, &pcms->cxl_devices_state);/{n;n;N;N;d;}'

echo "100000000                                         -> 41666666"
sed -i "$file_acpibuild_c" -e  '/    if_ctx = aml_if(aml_lor(aml_equal(period, zero),/{n;d;}'
sed -i "$file_acpibuild_c" -Ee "s/    if_ctx = aml_if\(aml_lor\(aml_equal\(period, zero\),/    if_ctx = aml_if(aml_equal(period, zero));/"
if [[ "${cpu_vendor:1}" == "AuthenticAMD" ]]; then
  echo "for (i = 0; i < 0x18; i++) {                      -> for (i = 0; i < 0x14; i++) {"
  sed -i "$file_acpibuild_c" -Ee "s/for \(i = 0; i < 0x18; i\+\+\) \{/for (i = 0; i < 0x14; i++) {/"
  echo "            append_q35_prt_entry(pkg, i, name);"
  echo "            v v v v v v v v v v v v v v v v v v"
  echo "    }"
  echo "    name[3] = 'A';"
  echo "    append_q35_prt_entry(pkg, 0x14, name);"
  echo "    for (i = 0x15; i < 0x18; i++) {"
  echo "        name[3] = 'E' + (i & 0x3);"
  echo "        append_q35_prt_entry(pkg, i, name);"
  sed -i "$file_acpibuild_c" -Ee "/            append_q35_prt_entry\(pkg, i, name\);/a\    }\n\
\n\
    name[3] = 'A';\n\
    append_q35_prt_entry(pkg, 0x14, name);\n\
\n\
    for (i = 0x15; i < 0x18; i++) {\n\
        name[3] = 'E' + (i & 0x3);\n\
        append_q35_prt_entry(pkg, i, name);"
fi

echo "  $file_i386_fwcfg_c"
get_new_string $(shuf -i 5-7 -n 1) 3
echo "\"QEMU\"                                            -> \"$prefix$suffix\""
sed -i "$file_i386_fwcfg_c" -Ee "s/\"QEMU\"/\"$prefix$suffix\"/"
get_new_string 4 1
fwcf=$new_string
echo "\"FWCF\"                                            -> \"$fwcf\""
echo "\"QEMU0002\"                                        -> \"UEFI0002\""
sed -i "$file_i386_fwcfg_c" -Ee "s/\"FWCF\"/\"$fwcf\"/"
sed -i "$file_i386_fwcfg_c" -Ee "s/\"QEMU0002\"/\"UEFI0002\"/"

echo "  $file_multiboot_c"
echo "\"qemu\"                                            -> \"Windows Boot Manager\""
sed -i "$file_multiboot_c" -Ee "s/\"qemu\"/\"Windows Boot Manager\"/"

echo "  $file_pc_c"
echo "pcms->smbus_enabled = true;                       -> pcms->smbus_enabled = false;"
echo "pcms->sata_enabled = true;                        -> pcms->sata_enabled = false;"
echo "pcms->i8042_enabled = true;                       -> pcms->i8042_enabled = false;"
##sed -i "$file_pc_c" -Ee "s/pcms->smbus_enabled = true;/pcms->smbus_enabled = false;/"
sed -i "$file_pc_c" -Ee "s/pcms->sata_enabled = true;/pcms->sata_enabled = false;/"
##sed -i "$file_pc_c" -Ee "s/pcms->i8042_enabled = true;/pcms->i8042_enabled = false;/"

#echo "  $file_pcpiix_c"

echo "  $file_pcq35_c"
echo "Standard PC (Q35 + ICH9, 2009)                    -> ${cpu_name:1}"
sed -i "$file_pcq35_c" -Ee "s/Standard PC \(Q35 \+ ICH9, 2009\)/${cpu_name:1}/"
echo "    pc_q35_machine_options(m);"
echo "    v v v v v v v v v v v v v v v v v v v v"
echo "    m->smbios_memory_device_size = 8 * GiB;"
sed -i "$file_pcq35_c" -Ee "/    pc_q35_machine_options\(m\);/a\    m->smbios_memory_device_size = 8 * GiB;"
echo "smbios_memory_device_size = 16                    -> smbios_memory_device_size = 8"
sed -i "$file_pcq35_c" -Ee "s/smbios_memory_device_size = 16/smbios_memory_device_size = 8/"

echo "  $file_smbusich9_c"
if [[ "${cpu_vendor:1}" == "AuthenticAMD" ]]; then
  echo "PCI_VENDOR_ID_INTEL;                              -> 0x1022;"
  echo "PCI_DEVICE_ID_INTEL_ICH9_6;                       -> 0x790B;  // FCH SMBus Controller"
  sed -i "$file_smbusich9_c" -Ee "s/PCI_VENDOR_ID_INTEL;/0x1022;/"
  sed -i "$file_smbusich9_c" -Ee "s/PCI_DEVICE_ID_INTEL_ICH9_6;/0x$smbus_1022;/"
else
  echo "    PMSMBus smb;"
  echo "    v v v v v v v v v"
  echo "    MemoryRegion mmio;"
  sed -i "$file_smbusich9_c" -Ee "/    PMSMBus smb;/a\    MemoryRegion mmio;"
  echo "static const MemoryRegionOps ich9_smb_mmio_ops = {"
  echo "    .read = ich9_smb_mmio_read,"
  echo "    .write = ich9_smb_mmio_write,"
  echo "    .endianness = DEVICE_LITTLE_ENDIAN,"
  echo "    .valid = {"
  echo "        .min_access_size = 1,"
  echo "        .max_access_size = 4,"
  echo "    },"
  echo "};"
  echo "^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^"
  echo "static void ich9_smbus_realize(PCIDevice *d, Error **errp)"
  sed -i "$file_smbusich9_c" -Ee "/static void ich9_smbus_realize\(PCIDevice \*d, Error \*\*errp\)/istatic uint64_t ich9_smb_mmio_read(void *opaque, hwaddr addr, unsigned size)\n\
{\n\
    return 0;\n\
}\n\
\n\
static void ich9_smb_mmio_write(void *opaque, hwaddr addr, uint64_t val, unsigned size)\n\
{\n\
}\n\
\n\
static const MemoryRegionOps ich9_smb_mmio_ops = {\n\
    .read = ich9_smb_mmio_read,\n\
    .write = ich9_smb_mmio_write,\n\
    .endianness = DEVICE_LITTLE_ENDIAN,\n\
    .valid = {\n\
        .min_access_size = 1,\n\
        .max_access_size = 4,\n\
    },\n\
};\n"
  echo "    memory_region_init_io(&s->io, OBJECT(s), &pm_smb_ops, &s->smb, \"ich9-smb-io\", ICH9_SMB_SMB_BASE_SIZE);"
  echo "    pci_register_bar(d, ICH9_SMB_SMB_BASE_BAR, PCI_BASE_ADDRESS_SPACE_IO, &s->io);"
  echo "    memory_region_init_io(&s->mmio, OBJECT(s), &ich9_smb_mmio_ops, &s->smb, \"ich9-smb-mmio\", ICH9_SMB_SMBM_SIZE);"
  echo "    pci_register_bar(d, ICH9_SMB_SMBM_BAR, PCI_BASE_ADDRESS_SPACE_MEMORY, &s->mmio);"
  echo "    ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^"
  echo "    s->smb.set_irq = ich9_smb_set_irq;"
  sed -i "$file_smbusich9_c" -Ee "/    s->smb.set_irq = ich9_smb_set_irq;/i\    memory_region_init_io(&s->mmio, OBJECT(s), &ich9_smb_mmio_ops, &s->smb, \"ich9-smb-mmio\", ICH9_SMB_SMBM_SIZE);\n\
    pci_register_bar(d, ICH9_SMB_SMBM_BAR, PCI_BASE_ADDRESS_SPACE_MEMORY, &s->mmio);\n"
  echo "PCI_VENDOR_ID_INTEL;                              -> 0x8086;"
  echo "PCI_DEVICE_ID_INTEL_ICH9_6;                       -> 0xA3A3;  // Comet Lake PCH-V SMBus Host Controller"
  sed -i "$file_smbusich9_c" -Ee "s/PCI_VENDOR_ID_INTEL;/0x8086;/"
  sed -i "$file_smbusich9_c" -Ee "s/PCI_DEVICE_ID_INTEL_ICH9_6;/0x$smbus_8086;/"
fi
get_new_string $(shuf -i 5-7 -n 1) 3
echo "ICH9 SMBUS Bridge                                 -> $prefix$suffix SMBus"
sed -i "$file_smbusich9_c" -Ee "s/ICH9 SMBUS Bridge/$prefix$suffix SMBus/"

echo "  $file_atapi_c"
get_new_string 4 1
echo "\"QEMU\"                                            -> \"$new_string\""
sed -i "$file_atapi_c" -Ee "s/\"QEMU\"/\"$new_string\"/"
get_new_string 4 1
echo "QEMU DVD-ROM                                      -> $new_string DVD-ROM"
sed -i "$file_atapi_c" -Ee "s/QEMU DVD-ROM/$new_string DVD-ROM/"

echo "  $file_ide_core_c"
get_new_string 4 1
echo "\"QM%05d\"                                          -> \"${new_string}%05d\""
echo "QEMU DVD-ROM                                      -> $new_ide_cd_model"
echo "QEMU MICRODRIVE                                   -> $new_ide_cfata_model"
echo "QEMU HARDDISK                                     -> $new_default_model"
sed -i "$file_ide_core_c" -Ee "s/\"QM%05d\"/\"${new_string}%05d\"/"
sed -i "$file_ide_core_c" -Ee "s/QEMU DVD-ROM/$new_ide_cd_model/"
sed -i "$file_ide_core_c" -Ee "s/QEMU MICRODRIVE/$new_ide_cfata_model/"
sed -i "$file_ide_core_c" -Ee "s/QEMU HARDDISK/$new_default_model/"

echo "  $file_ich_c"
if [[ "${cpu_vendor:1}" == "AuthenticAMD" ]]; then
  echo "PCI_VENDOR_ID_INTEL;                              -> 0x1022;"
  echo "PCI_DEVICE_ID_INTEL_82801IR;                      -> 0x7901;  // FCH SATA Controller [AHCI mode]"
  sed -i "$file_ich_c" -Ee "s/PCI_VENDOR_ID_INTEL;/0x1022;/"
  sed -i "$file_ich_c" -Ee "s/PCI_DEVICE_ID_INTEL_82801IR;/0x$sata_1022;/"
else
  echo "PCI_VENDOR_ID_INTEL;                              -> 0x8086;"
  echo "PCI_DEVICE_ID_INTEL_82801IR;                      -> 0x06D2;  // Comet Lake SATA AHCI Controller"
  sed -i "$file_ich_c" -Ee "s/PCI_VENDOR_ID_INTEL;/0x8086;/"
  sed -i "$file_ich_c" -Ee "s/PCI_DEVICE_ID_INTEL_82801IR;/0x$sata_8086;/"
fi

echo "  $file_adbkbd_c"
get_new_string $(shuf -i 5-7 -n 1) 3
echo "QEMU ADB Keyboard                                 -> $prefix$suffix ADB Keyboard"
sed -i "$file_adbkbd_c" -Ee "s/QEMU ADB Keyboard/$prefix$suffix ADB Keyboard/"

echo "  $file_adbmouse_c"
get_new_string $(shuf -i 5-7 -n 1) 3
echo "QEMU ADB Mouse                                    -> $prefix$suffix ADB Mouse"
sed -i "$file_adbmouse_c" -Ee "s/QEMU ADB Mouse/$prefix$suffix ADB Mouse/"

#echo "  $file_ads7846_c"
#get_new_string $(shuf -i 5-7 -n 1) 3
#echo "QEMU ADS7846-driven Touchscreen                  -> $prefix$suffix ADS7846-driven Touchscreen"

echo "  $file_hid_c"
get_new_string $(shuf -i 5-7 -n 1) 3
echo "QEMU HID Keyboard                                 -> $prefix$suffix HID Keyboard"
echo "QEMU HID Mouse                                    -> $prefix$suffix HID Mouse"
echo "QEMU HID Tablet                                   -> $prefix$suffix HID Tablet"
sed -i "$file_hid_c" -Ee "s/QEMU HID Keyboard/$prefix$suffix HID Keyboard/"
sed -i "$file_hid_c" -Ee "s/QEMU HID Mouse/$prefix$suffix HID Mouse/"
sed -i "$file_hid_c" -Ee "s/QEMU HID Tablet/$prefix$suffix HID Tablet/"

echo "  $file_ps2_c"
get_new_string $(shuf -i 5-7 -n 1) 3
echo "QEMU PS/2 Keyboard                                -> $prefix$suffix PS/2 Keyboard"
echo "QEMU PS/2 Mouse                                   -> $prefix$suffix PS/2 Mouse"
sed -i "$file_ps2_c" -Ee "s/QEMU PS\/2 Keyboard/$prefix$suffix PS\/2 Keyboard/"
sed -i "$file_ps2_c" -Ee "s/QEMU PS\/2 Mouse/$prefix$suffix PS\/2 Mouse/"

#echo "  $file_tsc2005_c"
#get_new_string $(shuf -i 5-7 -n 1) 3
#echo "QEMU TSC2005-driven Touchscreen                  -> $prefix$suffix TSC2005-driven Touchscreen"

#echo "  $file_tsc210x_c"
#get_new_string $(shuf -i 5-7 -n 1) 3
#echo "QEMU TSC2102-driven Touchscreen                  -> $prefix$suffix TSC2102-driven Touchscreen"
#echo "QEMU TSC2301-driven Touchscreen                  -> $prefix$suffix TSC2301-driven Touchscreen"

echo "  $file_virtioinputhid_c"
get_new_string $(shuf -i 5-7 -n 1) 3
echo "QEMU Virtio Keyboard                              -> $prefix$suffix Keyboard"
echo "QEMU Virtio Mouse                                 -> $prefix$suffix Mouse"
echo "QEMU Virtio Tablet                                -> $prefix$suffix Tablet"
echo "QEMU Virtio MultiTouch                            -> $prefix$suffix MultiTouch"
sed -i "$file_virtioinputhid_c" -Ee "s/QEMU Virtio Keyboard/$prefix$suffix Keyboard/"
sed -i "$file_virtioinputhid_c" -Ee "s/QEMU Virtio Mouse/$prefix$suffix Mouse/"
sed -i "$file_virtioinputhid_c" -Ee "s/QEMU Virtio Tablet/$prefix$suffix Tablet/"
sed -i "$file_virtioinputhid_c" -Ee "s/QEMU Virtio MultiTouch/$prefix$suffix MultiTouch/"
echo "0x0627                                            -> 0x045e"
sed -i "$file_virtioinputhid_c" -Ee "s/0x0627/0x045e/"

echo "  $file_piix_c"
echo ".S08.                                             -> .${path}08."
sed -i "$file_piix_c" -Ee "s/.S08./.${path}08./"

echo "  $file_lpcich9_c"
#echo ".SF8.                                             -> .${path}F8."
#sed -i "$file_lpcich9_c" -Ee "s/.SF8./.${path}F8./"
echo ".SF8.                                             -> .LPCB."
echo "ICH9 LPC bridge                                   -> LPC Bridge"
sed -i "$file_lpcich9_c" -Ee "s/.SF8./.LPCB./"
sed -i "$file_lpcich9_c" -Ee "s/ICH9 LPC bridge/LPC Bridge/"
if [[ "${cpu_vendor:1}" == "AuthenticAMD" ]]; then
  echo "PCI_VENDOR_ID_INTEL;                              -> 0x1022;"
  echo "PCI_DEVICE_ID_INTEL_ICH9_8;                       -> 0x790E;  // FCH LPC Bridge"
  sed -i "$file_lpcich9_c" -Ee "s/PCI_VENDOR_ID_INTEL;/0x1022;/"
  sed -i "$file_lpcich9_c" -Ee "s/PCI_DEVICE_ID_INTEL_ICH9_8;/0x$lpc_1022;/"
  echo "        if (slot == 31) ich9_cc_update_ir(lpc->irr[20], pci_get_word(lpc->chip_config + *offset));"
  echo "        else"
  echo "        ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^"
  echo "        ich9_cc_update_ir(lpc->irr[slot],"
  sed -i "$file_lpcich9_c" -Ee "/        ich9_cc_update_ir\(lpc->irr\[slot\],/i\        if (slot == 31) ich9_cc_update_ir(lpc->irr[20], pci_get_word(lpc->chip_config + *offset));\n\
        else"
else
  echo "PCI_VENDOR_ID_INTEL;                              -> 0x8086;"
  echo "PCI_DEVICE_ID_INTEL_ICH9_8;                       -> 0x068D;  // Comet Lake LPC Controller"
  sed -i "$file_lpcich9_c" -Ee "s/PCI_VENDOR_ID_INTEL;/0x8086;/"
  sed -i "$file_lpcich9_c" -Ee "s/PCI_DEVICE_ID_INTEL_ICH9_8;/0x$lpc_8086;/"
fi

echo "  $file_ivshmempci_c"
if [[ "${cpu_vendor:1}" == "AuthenticAMD" ]]; then
  echo "VENDOR_ID_IVSHMEM   PCI_VENDOR_ID_REDHAT_QUMRANET -> VENDOR_ID_IVSHMEM   0x1022"
  sed -i "$file_ivshmempci_c" -Ee "s/VENDOR_ID_IVSHMEM   PCI_VENDOR_ID_REDHAT_QUMRANET/VENDOR_ID_IVSHMEM   0x1022/"
else
  echo "VENDOR_ID_IVSHMEM   PCI_VENDOR_ID_REDHAT_QUMRANET -> VENDOR_ID_IVSHMEM   0x8086"
  sed -i "$file_ivshmempci_c" -Ee "s/VENDOR_ID_IVSHMEM   PCI_VENDOR_ID_REDHAT_QUMRANET/VENDOR_ID_IVSHMEM   0x8086/"
fi
echo "DEVICE_ID_IVSHMEM   0x1110                        -> DEVICE_ID_IVSHMEM   0x$device"
sed -i "$file_ivshmempci_c" -Ee "s/DEVICE_ID_IVSHMEM   0x1110/DEVICE_ID_IVSHMEM   0x$device/"

echo "  $file_pvpanicisa_c"
echo "QEMU0001                                          -> UEFI0001"
sed -i "$file_pvpanicisa_c" -Ee "s/QEMU0001/UEFI0001/"

echo "  $file_e1000xregs_h"
echo "0x10D3                                            -> 0x10F6"
sed -i "$file_e1000xregs_h" -Ee "s/0x10D3/0x10F6/"

echo "  $file_Kconfig"
echo "config RTL8125_PCI_EXPRESS"
echo "    bool"
echo "    default y if PCI_DEVICES || PCIE_DEVICES"
echo "    depends on PCI_EXPRESS && MSI_NONBROKEN"
echo "^ ^ ^ ^ ^ ^ ^ ^ ^"
echo "config RTL8139_PCI"
sed -i "$file_Kconfig" -Ee "/config RTL8139_PCI/iconfig RTL8125_PCI_EXPRESS\n\
    bool\n\
    default y if PCI_DEVICES || PCIE_DEVICES\n\
    depends on PCI_EXPRESS && MSI_NONBROKEN\n"

echo "  $file_mesonbuild"
echo "system_ss.add(when: 'CONFIG_RTL8125_PCI_EXPRESS', if_true: files('rtl8125.c', 'net_tx_pkt.c'))"
echo "^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^"
echo "system_ss.add(when: 'CONFIG_RTL8139_PCI', if_true: files('rtl8139.c'))"
sed -i "$file_mesonbuild" -Ee "/system_ss.add\(when: 'CONFIG_RTL8139_PCI', if_true: files\('rtl8139.c'\)\)/isystem_ss.add(when: 'CONFIG_RTL8125_PCI_EXPRESS', if_true: files('rtl8125.c', 'net_tx_pkt.c'))"

echo "  $file_ctrl_c"
get_new_string $(shuf -i 5-7 -n 1) 3
echo "QEMU NVMe Ctrl                                    -> $prefix$suffix NVMe Ctrl"
sed -i "$file_ctrl_c" -Ee "s/QEMU NVMe Ctrl/$prefix$suffix NVMe Ctrl/"

echo "  $file_nvram_fwcfg_c"
#signature=$(get_random_hex 16)
signature="41204D2049202020"
echo "0x51454d5520434647ULL                             -> 0x${signature}ULL"
sed -i "$file_nvram_fwcfg_c" -Ee "s/0x51454d5520434647ULL/0x${signature}ULL/"
#get_new_string 4 1
#echo "\"QEMU\"                                            -> \"$new_string\""
#sed -i "$file_nvram_fwcfg_c" -Ee "s/\"QEMU\"/\"$new_string\"/"

echo "  $file_fwcfgacpi_c"
echo "\"FWCF\"                                            -> \"$fwcf\""
echo "\"QEMU0002\"                                        -> \"UEFI0002\""
sed -i "$file_fwcfgacpi_c" -Ee "s/\"FWCF\"/\"$fwcf\"/"
sed -i "$file_fwcfgacpi_c" -Ee "s/\"QEMU0002\"/\"UEFI0002\"/"

echo "  $file_pci_c"
echo "    PCIDeviceClass *pc = PCI_DEVICE_GET_CLASS(pci_dev);"
echo "    v v v v v v v v v v v v v v v v v v v v v v v v v v"
echo "    static int index;"
echo "    if (pc->vendor_id == PCI_VENDOR_ID_REDHAT &&"
echo "        pc->device_id == PCI_DEVICE_ID_REDHAT_PCIE_RP + index)"
echo "        pc->device_id = PCI_DEVICE_ID_REDHAT_PCIE_RP + ++index;"
sed -i "$file_pci_c" -Ee "/    PCIDeviceClass \*pc = PCI_DEVICE_GET_CLASS\(pci_dev\);/a\    static int index;\n\
    if (pc->vendor_id == PCI_VENDOR_ID_REDHAT &&\n\
        pc->device_id == PCI_DEVICE_ID_REDHAT_PCIE_RP + index)\n\
        pc->device_id = PCI_DEVICE_ID_REDHAT_PCIE_RP + ++index;"

echo "  $file_gpex_c"
get_new_string $(shuf -i 5-7 -n 1) 3
echo "QEMU generic PCIe host bridge                     -> $prefix$suffix PCIe host bridge"
sed -i "$file_gpex_c" -Ee "s/QEMU generic PCIe host bridge/$prefix$suffix PCIe host bridge/"

echo "  $file_mptconfig_c"
get_new_string 4 1
serial=$(get_random_serial 16)
echo "QEMU MPT Fusion                                   -> $new_string MPT Fusion"
echo "\"QEMU\"                                            -> \"$new_string\""
echo "0000111122223333                                  -> $serial"
sed -i "$file_mptconfig_c" -Ee "s/QEMU MPT Fusion/$new_string MPT Fusion/"
sed -i "$file_mptconfig_c" -Ee "s/\"QEMU\"/\"$new_string\"/"
sed -i "$file_mptconfig_c" -Ee "s/0000111122223333/$serial/"

echo "  $file_scsibus_c"
get_new_string 4 1
echo "\"QEMU    \"                                        -> \"$new_string    \""
echo "\"QEMU TARGET     \"                                -> \"$new_string TARGET     \""
sed -i "$file_scsibus_c" -Ee "s/\"QEMU    \"/\"$new_string    \"/"
sed -i "$file_scsibus_c" -Ee "s/\"QEMU TARGET     \"/\"$new_string TARGET     \"/"

echo "  $file_scsidisk_c"
get_new_string 4 1
echo "\"QEMU\"                                            -> \"$new_string\""
echo "\"QEMU HARDDISK\"                                   -> \"$new_string HDD\""
echo "\"QEMU CD-ROM\"                                     -> \"$new_string CD-ROM\""
sed -i "$file_scsidisk_c" -Ee "s/\"QEMU\"/\"$new_string\"/"
sed -i "$file_scsidisk_c" -Ee "s/\"QEMU HARDDISK\"/\"$new_string HDD\"/"
sed -i "$file_scsidisk_c" -Ee "s/\"QEMU CD-ROM\"/\"$new_string CD-ROM\"/"

echo "  $file_spaprvscsi_c"
get_new_string 4 1
nocaps=$(echo $new_string | tr '[A-Z]' '[a-z]')
echo "\"QEMU EMPTY      \"                                -> \"$new_string EMPTY      \""
echo "\"QEMU    \"                                        -> \"$new_string    \""
echo "\"qemu\"                                            -> \"$nocaps\""
sed -i "$file_spaprvscsi_c" -Ee "s/\"QEMU EMPTY      \"/\"$new_string EMPTY      \"/"
sed -i "$file_spaprvscsi_c" -Ee "s/\"QEMU    \"/\"$new_string    \"/"
sed -i "$file_spaprvscsi_c" -Ee "s/\"qemu\"/\"$nocaps\"/g"

echo "  $file_smbios"
echo "static struct {"
echo "    const char *socket_designation_l1;"
echo "    const char *socket_designation_l2;"
echo "    const char *socket_designation_l3;"
echo "} type7;"
echo "^ ^ ^ ^ ^ ^ ^ ^"
echo "struct type8_instance {"
sed -i "$file_smbios" -Ee "/struct type8_instance \{/istatic struct {\n\
    const char *socket_designation_l1;\n\
    const char *socket_designation_l2;\n\
    const char *socket_designation_l3;\n\
} type7;\n"
echo "static struct {"
echo "    const char *description;"
echo "} type26;"
echo "static struct {"
echo "    const char *description;"
echo "} type27;"
echo "static struct {"
echo "    const char *description;"
echo "} type28;"
echo "^ ^ ^ ^ ^ ^ ^ ^"
echo "static QEnumLookup type41_kind_lookup = {"
sed -i "$file_smbios" -Ee "/static QEnumLookup type41_kind_lookup = \{/istatic struct {\n\
    const char *description;\n\
} type26;\n\
\n\
static struct {\n\
    const char *description;\n\
} type27;\n\
\n\
static struct {\n\
    const char *description;\n\
} type28;\n"
echo "#define T7_BASE 0x700"
echo "#define T8_BASE 0x800"
echo "^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^"
echo "#define T9_BASE 0x900"
sed -i "$file_smbios" -Ee "/#define T9_BASE 0x900/i#define T7_BASE 0x700\n\
#define T8_BASE 0x800"
echo "#define T20_BASE 0x1400"
echo "#define T26_BASE 0x1A00"
echo "#define T27_BASE 0x1B00"
echo "#define T28_BASE 0x1C00"
echo "^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^"
echo "#define T32_BASE 0x2000"
sed -i "$file_smbios" -Ee "/#define T32_BASE 0x2000/i#define T20_BASE 0x1400\n\
#define T26_BASE 0x1A00\n\
#define T27_BASE 0x1B00\n\
#define T28_BASE 0x1C00"
echo "uint8_t g_type4_family;"
echo "uint8_t g_type4_upgrade;"
echo "^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^"
echo "static void smbios_build_type_4_table(MachineState *ms, unsigned instance,"
sed -i "$file_smbios" -Ee "/static void smbios_build_type_4_table\(MachineState \*ms, unsigned instance,/iuint8_t g_type4_family;\n\
uint8_t g_type4_upgrade;"
echo "    if (instance > 0)"
echo "        snprintf(sock_str, sizeof(sock_str), \"%s%2x\", type4.sock_pfx, instance + 1);"
echo "    else"
echo "        snprintf(sock_str, sizeof(sock_str), \"%s\", type4.sock_pfx);"
echo "    ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^"
echo "    SMBIOS_TABLE_SET_STR(4, socket_designation_str, sock_str);"
sed -i "$file_smbios" -e  '/type4.sock_pfx, instance);/{d;}'
sed -i "$file_smbios" -Ee "/    SMBIOS_TABLE_SET_STR\(4, socket_designation_str, sock_str\);/i\    if (instance > 0)\n\
        snprintf(sock_str, sizeof(sock_str), \"%s%2x\", type4.sock_pfx, instance + 1);\n\
    else\n\
        snprintf(sock_str, sizeof(sock_str), \"%s\", type4.sock_pfx);"
get_type_4_data
voltage=$(shuf -i 1300-1450 -n 1)
echo "    t->processor_family = 0xfe; /* use Processor Family 2 field */"
echo "    v v v v v v v v v v v v v v v v v v v v v v v v v v v v v v v"
echo "    if (g_type4_family > 0) t->processor_family = g_type4_family;"
sed -i "$file_smbios" -Ee "/    t->processor_family = 0xfe; \/\* use Processor Family 2 field \*\//a\    if (g_type4_family > 0) t->processor_family = g_type4_family;"
echo "t->processor_family = 0xfe;                       -> t->processor_family = 0x$t4_processor_family;"
#echo "t->voltage = 0;                                   -> t->voltage = 0x$t4_voltage;"
echo "t->voltage = 0;                                   -> t->voltage = $((128 + voltage/100));"
echo "t->external_clock = cpu_to_le16(0);               -> t->external_clock = cpu_to_le16(0x$t4_external_clock);"
echo "t->max_speed = cpu_to_le16(type4.max_speed);      -> t->max_speed = cpu_to_le16(0x$t4_max_speed); /* $((0x$t4_max_speed)) MHz */"
echo "current_speed = cpu_to_le16(type4.current_speed); -> current_speed = cpu_to_le16(0x$( printf '%04X' $((0x$t4_current_speed*2/3)) )); /* $((0x$t4_current_speed*2/3)) MHz */"
sed -i "$file_smbios" -Ee "s/t->processor_family = 0xfe;/t->processor_family = 0x$t4_processor_family;/"
#sed -i "$file_smbios" -Ee "s/t->voltage = 0;/t->voltage = 0x$t4_voltage;/"
sed -i "$file_smbios" -Ee "s/t->voltage = 0;/t->voltage = $((128 + voltage/100));/"
sed -i "$file_smbios" -Ee "s/t->external_clock = cpu_to_le16\(0\);/t->external_clock = cpu_to_le16(0x$t4_external_clock);/"
sed -i "$file_smbios" -Ee "s/t->max_speed = cpu_to_le16\(type4.max_speed\);/t->max_speed = cpu_to_le16(0x$t4_max_speed); \/\* $((0x$t4_max_speed)) MHz \*\//"
sed -i "$file_smbios" -Ee "s/current_speed = cpu_to_le16\(type4.current_speed\);/current_speed = cpu_to_le16(0x$( printf '%04X' $((0x$t4_current_speed*2/3)) )); \/\* $((0x$t4_current_speed*2/3)) MHz \*\//"
echo "    t->processor_upgrade = 0x01; /* Other */"
echo "    v v v v v v v v v v v v v v v v v v v v v v v v v v v v v v v v"
echo "    if (g_type4_upgrade > 0) t->processor_upgrade = g_type4_upgrade;"
sed -i "$file_smbios" -Ee "/    t->processor_upgrade = 0x01; \/\* Other \*\//a\    if (g_type4_upgrade > 0) t->processor_upgrade = g_type4_upgrade;"
echo "t->processor_upgrade = 0x01;                      -> t->processor_upgrade = 0x$t4_processor_upgrade;"
echo "l1_cache_handle = cpu_to_le16(0xFFFF)             -> l1_cache_handle = cpu_to_le16(T7_BASE + 1)"
echo "l2_cache_handle = cpu_to_le16(0xFFFF)             -> l2_cache_handle = cpu_to_le16(T7_BASE + 2)"
echo "l3_cache_handle = cpu_to_le16(0xFFFF)             -> l3_cache_handle = cpu_to_le16(T7_BASE + 3)"
echo "t->processor_characteristics = cpu_to_le16(0x02); -> t->processor_characteristics = cpu_to_le16(0x$t4_processor_characteristics);"
echo "family2 = cpu_to_le16(type4.processor_family);    -> family2 = cpu_to_le16(t->processor_family);"
sed -i "$file_smbios" -Ee "s/t->processor_upgrade = 0x01;/t->processor_upgrade = 0x$t4_processor_upgrade;/"
sed -i "$file_smbios" -Ee "s/l1_cache_handle = cpu_to_le16\(0xFFFF\)/l1_cache_handle = cpu_to_le16(T7_BASE + 1)/"
sed -i "$file_smbios" -Ee "s/l2_cache_handle = cpu_to_le16\(0xFFFF\)/l2_cache_handle = cpu_to_le16(T7_BASE + 2)/"
sed -i "$file_smbios" -Ee "s/l3_cache_handle = cpu_to_le16\(0xFFFF\)/l3_cache_handle = cpu_to_le16(T7_BASE + 3)/"
sed -i "$file_smbios" -Ee "s/t->processor_characteristics = cpu_to_le16\(0x02\);/t->processor_characteristics = cpu_to_le16(0x$t4_processor_characteristics);/"
sed -i "$file_smbios" -Ee "s/family2 = cpu_to_le16\(type4.processor_family\);/family2 = cpu_to_le16\(t->processor_family\);/"
echo "    if      (level == 0b000) SMBIOS_TABLE_SET_STR(7, socket_designation, type7.socket_designation_l1);"
echo "    else if (level == 0b001) SMBIOS_TABLE_SET_STR(7, socket_designation, type7.socket_designation_l2);"
echo "    else if (level == 0b010) SMBIOS_TABLE_SET_STR(7, socket_designation, type7.socket_designation_l3);"
echo "    SMBIOS_BUILD_TABLE_POST;"
echo "}"
echo "^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^"
echo "static void smbios_build_type_8_table(void)"
sed -i "$file_smbios" -Ee "/static void smbios_build_type_8_table\(void\)/istatic void smbios_build_type_7_table(unsigned offset, uint8_t level, uint8_t system_cache_type, uint16_t installed_size, uint32_t installed_size_2)\n\
{\n\
    SMBIOS_BUILD_TABLE_PRE(7, T7_BASE + offset, true); /* required */\n\
    t->cache_configuration = 0b0000000100000000 | level; // 000000 WriteBack(01) Disabled(0) Internal(00) 0 NotSocketed(0) L1(000)\n\
    t->maximum_cache_size = installed_size;\n\
    t->installed_size = installed_size;\n\
    t->supported_sram_type = 0b0000000000100000;         // 0000000000 Synchronous(1) 00000\n\
    t->current_sram_type = 0b0000000000100000;\n\
    t->cache_speed = 0;\n\
    t->error_correction_type = 0x06;                     // Multi-bit ECC\n\
    t->system_cache_type = system_cache_type;\n\
    t->associativity = 0x06;                             // Fully Associative\n\
    t->maximum_cache_size_2 = installed_size_2;\n\
    t->installed_size_2 = installed_size_2;\n\
    if      (level == 0b000) SMBIOS_TABLE_SET_STR(7, socket_designation, type7.socket_designation_l1);\n\
    else if (level == 0b001) SMBIOS_TABLE_SET_STR(7, socket_designation, type7.socket_designation_l2);\n\
    else if (level == 0b010) SMBIOS_TABLE_SET_STR(7, socket_designation, type7.socket_designation_l3);\n\
    SMBIOS_BUILD_TABLE_POST;\n\
}\n"
echo "SMBIOS_BUILD_TABLE_PRE(8, T0_BASE                 -> SMBIOS_BUILD_TABLE_PRE(8, T8_BASE"
echo "t->segment_group_number = 0xff;                   -> t->segment_group_number = cpu_to_le16(0);"
echo "t->bus_number = 0xff;                             -> t->bus_number = 0x00;"
sed -i "$file_smbios" -Ee "s/SMBIOS_BUILD_TABLE_PRE\(8, T0_BASE/SMBIOS_BUILD_TABLE_PRE(8, T8_BASE/"
sed -i "$file_smbios" -Ee "s/t->segment_group_number = 0xff;/t->segment_group_number = cpu_to_le16(0);/"
sed -i "$file_smbios" -Ee "s/t->bus_number = 0xff;/t->bus_number = 0x00;/"
echo "            t->device_number = 0xff;"
echo "            v v v v v v v v v v v v v v v"
echo "            if (t9->current_usage == 0x04)"
echo "                t->device_number = t9->slot_id << 3;"
sed -i "$file_smbios" -Ee "/            t->device_number = 0xff;/a\            if (t9->current_usage == 0x04)\n\
                t->device_number = t9->slot_id << 3;"
echo "uint64_t start, uint64_t size)                    -> uint64_t start, uint64_t size, unsigned dimm_cnt)"
echo "partition_width = 1; /* One device per row */     -> partition_width = dimm_cnt;"
sed -i "$file_smbios" -Ee "s/uint64_t start, uint64_t size\)/uint64_t start, uint64_t size, unsigned dimm_cnt)/"
sed -i "$file_smbios" -Ee "s/partition_width = 1; \/\* One device per row \*\//partition_width = dimm_cnt;/"
rpm=$(shuf -i 1450-1850 -n 1)
temperature=$(shuf -i 350-550 -n 1)
echo "    SMBIOS_BUILD_TABLE_PRE(20, T20_BASE + instance, true); /* required */"
echo "    t->memory_device_handle = cpu_to_le16(T17_BASE + instance);"
echo "    t->memory_array_mapped_address_handle = cpu_to_le16(T19_BASE);"
echo "    SMBIOS_BUILD_TABLE_POST;"
echo "}"
echo "    SMBIOS_TABLE_SET_STR(26, description, type26.description);"
echo "    SMBIOS_BUILD_TABLE_POST;"
echo "}"
echo "    SMBIOS_TABLE_SET_STR(27, description, type27.description);"
echo "    SMBIOS_BUILD_TABLE_POST;"
echo "}"
echo "    SMBIOS_TABLE_SET_STR(28, description, type28.description);"
echo "    SMBIOS_BUILD_TABLE_POST;"
echo "}"
echo "^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^"
echo "static void smbios_build_type_32_table(void)"
sed -i "$file_smbios" -Ee "/static void smbios_build_type_32_table\(void\)/istatic void smbios_build_type_20_table(unsigned instance, uint64_t size)\n\
{\n\
    uint64_t start, end, start_kb, end_kb;\n\
    SMBIOS_BUILD_TABLE_PRE(20, T20_BASE + instance, true); /* required */\n\
    start = instance * size;\n\
    end = start + size - 1;\n\
    assert(end > start);\n\
    start_kb = start / KiB;\n\
    end_kb = end / KiB;\n\
    if (start_kb < UINT32_MAX && end_kb < UINT32_MAX) {\n\
        t->starting_address = cpu_to_le32(start_kb);\n\
        t->ending_address = cpu_to_le32(end_kb);\n\
        t->extended_starting_address = t->extended_ending_address = cpu_to_le64(0);\n\
    } else {\n\
        t->starting_address = t->ending_address = cpu_to_le32(UINT32_MAX);\n\
        t->extended_starting_address = cpu_to_le64(start);\n\
        t->extended_ending_address = cpu_to_le64(end);\n\
    }\n\
    t->memory_device_handle = cpu_to_le16(T17_BASE + instance);\n\
    t->memory_array_mapped_address_handle = cpu_to_le16(T19_BASE);\n\
    t->partition_row_position = 0xFF; /* Unknown */\n\
    t->interleave_position = 0; /* Not interleaved */\n\
    t->interleaved_data_depth = 0; /* Not interleaved */\n\
    SMBIOS_BUILD_TABLE_POST;\n\
}\n"
sed -i "$file_smbios" -Ee "/static void smbios_build_type_32_table\(void\)/istatic void smbios_build_type_26_table(void)\n\
{\n\
    SMBIOS_BUILD_TABLE_PRE(26, T26_BASE, true); /* required */\n\
    t->location_and_status = 0b01100011; // OK (011) Processor (00011)\n\
    t->maximum_value = 0x8000;           // in millivolts\n\
    t->minimum_value = 0x8000;           // in millivolts\n\
    t->resolution = 10;                  // in 1/10 mV\n\
    t->tolerance = 0x8000;\n\
    t->accuracy = 0x8000;\n\
    t->oem_defined = 0;\n\
    t->nominal_value = $voltage;             // in millivolts\n\
    SMBIOS_TABLE_SET_STR(26, description, type26.description);\n\
    SMBIOS_BUILD_TABLE_POST;\n\
}\n"
sed -i "$file_smbios" -Ee "/static void smbios_build_type_32_table\(void\)/istatic void smbios_build_type_27_table(void)\n\
{\n\
    SMBIOS_BUILD_TABLE_PRE(27, T27_BASE, true); /* required */\n\
    t->temperature_probe_handle = T28_BASE;\n\
    t->device_type_and_status = 0b01100011; // OK (011) Fan (00011)\n\
    t->cooling_unit_group = 0;\n\
    t->oem_defined = 0;\n\
    t->nominal_speed = $rpm;                // in RPM\n\
    SMBIOS_TABLE_SET_STR(27, description, type27.description);\n\
    SMBIOS_BUILD_TABLE_POST;\n\
}\n"
sed -i "$file_smbios" -Ee "/static void smbios_build_type_32_table\(void\)/istatic void smbios_build_type_28_table(void)\n\
{\n\
    SMBIOS_BUILD_TABLE_PRE(28, T28_BASE, true); /* required */\n\
    t->location_and_status = 0b01100011; // OK (011) Processor (00011)\n\
    t->maximum_value = 1270;             // in 1/10 °C\n\
    t->minimum_value = -550;             // in 1/10 °C\n\
    t->resolution = 100;                 // in 1/1000 °C\n\
    t->tolerance = 0x8000;\n\
    t->accuracy = 0x8000;\n\
    t->oem_defined = 0;\n\
    t->nominal_value = $temperature;              // in 1/10 °C\n\
    SMBIOS_TABLE_SET_STR(28, description, type28.description);\n\
    SMBIOS_BUILD_TABLE_POST;\n\
}\n"
echo "char *g_type4_version;"
echo "^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^"
echo "void smbios_set_defaults(const char *manufacturer, const char *product,"
sed -i "$file_smbios" -Ee "/void smbios_set_defaults\(const char \*manufacturer, const char \*product,/ichar *g_type4_version;"
echo "type4.manufacturer, manufacturer);                -> type4.manufacturer, \"Intel(R) Corporation\");"
echo "type4.version, version);                          -> type4.version, g_type4_version);"
sed -i "$file_smbios" -Ee "s/type4.manufacturer, manufacturer\);/type4.manufacturer, \"Intel(R) Corporation\");/"
sed -i "$file_smbios" -Ee "s/type4.version, version\);/type4.version, g_type4_version);/"
echo "    SMBIOS_SET_DEFAULT(type7.socket_designation_l1, \"L1 Cache\");"
echo "    SMBIOS_SET_DEFAULT(type7.socket_designation_l2, \"L2 Cache\");"
echo "    SMBIOS_SET_DEFAULT(type7.socket_designation_l3, \"L3 Cache\");"
echo "    ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^"
echo "    SMBIOS_SET_DEFAULT(type17.loc_pfx, \"DIMM\");"
sed -i "$file_smbios" -Ee "/    SMBIOS_SET_DEFAULT\(type17.loc_pfx, \"DIMM\"\);/i\    SMBIOS_SET_DEFAULT(type7.socket_designation_l1, \"L1 Cache\");\n\
    SMBIOS_SET_DEFAULT(type7.socket_designation_l2, \"L2 Cache\");\n\
    SMBIOS_SET_DEFAULT(type7.socket_designation_l3, \"L3 Cache\");"
echo "    SMBIOS_SET_DEFAULT(type17.bank, \"BANK\");"
echo "    ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^"
echo "    SMBIOS_SET_DEFAULT(type17.manufacturer, manufacturer);"
sed -i "$file_smbios" -Ee "/    SMBIOS_SET_DEFAULT\(type17.manufacturer, manufacturer\);/i\    SMBIOS_SET_DEFAULT(type17.bank, \"BANK\");"
echo "    SMBIOS_SET_DEFAULT(type17.manufacturer, manufacturer);"
echo "    v v v v v v v v v v v v v v v v v v v v v v v v v"
echo "    SMBIOS_SET_DEFAULT(type26.description, \"VPROBE0\");"
echo "    SMBIOS_SET_DEFAULT(type27.description, \"FAN0\");"
echo "    SMBIOS_SET_DEFAULT(type28.description, \"TPROBE0\");"
sed -i "$file_smbios" -Ee "/    SMBIOS_SET_DEFAULT\(type17.manufacturer, manufacturer\);/a\    SMBIOS_SET_DEFAULT(type26.description, \"VPROBE0\");\n\
    SMBIOS_SET_DEFAULT(type27.description, \"FAN0\");\n\
    SMBIOS_SET_DEFAULT(type28.description, \"TPROBE0\");"
echo "unsigned i, dimm_cnt, offset;                     -> unsigned i, dimm_cnt, slot_cnt, offset;"
sed -i "$file_smbios" -Ee "s/unsigned i, dimm_cnt, offset;/unsigned i, dimm_cnt, slot_cnt, offset;/"
echo "    smbios_build_type_7_table(0, 0b000, 0x03, 0x0080, 0x00000080); // L1 Instruction 128 KiB"
echo "    smbios_build_type_7_table(1, 0b000, 0x04, 0x0080, 0x00000080); // L1 Data        128 KiB"
echo "    smbios_build_type_7_table(2, 0b001, 0x05, 0x3000, 0x00003000); // L2 Unified      12 MiB"
echo "    smbios_build_type_7_table(3, 0b010, 0x05, 0x8400, 0x80000400); // L3 Unified      64 MiB"
echo "    ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^"
echo "    smbios_build_type_8_table();"
sed -i "$file_smbios" -Ee "/    smbios_build_type_8_table\(\);/i\    smbios_build_type_7_table(0, 0b000, 0x03, 0x0080, 0x00000080); // L1 Instruction 128 KiB\n\
    smbios_build_type_7_table(1, 0b000, 0x04, 0x0080, 0x00000080); // L1 Data        128 KiB\n\
    smbios_build_type_7_table(2, 0b001, 0x05, 0x3000, 0x00003000); // L2 Unified      12 MiB\n\
    smbios_build_type_7_table(3, 0b010, 0x05, 0x8400, 0x80000400); // L3 Unified      64 MiB"
echo "               mc->smbios_memory_device_size;"
echo "    v v v v v v v v v v v v"
echo "    slot_cnt = 4;"
echo "    if (slot_cnt < dimm_cnt)"
echo "        slot_cnt = dimm_cnt;"
sed -i "$file_smbios" -Ee "/               mc->smbios_memory_device_size;/a\    slot_cnt = 4;\n\
    if (slot_cnt < dimm_cnt)\n\
        slot_cnt = dimm_cnt;"
echo "smbios_build_type_16_table(dimm_cnt)              -> smbios_build_type_16_table(slot_cnt)"
sed -i "$file_smbios" -Ee "s/smbios_build_type_16_table\(dimm_cnt\)/smbios_build_type_16_table(slot_cnt)/"
echo "    srand(time(0));"
echo "    ^ ^ ^ ^ ^ ^ ^ ^"
echo "    for (i = 0; i < dimm_cnt; i++) {"
sed -i "$file_smbios" -Ee "/    for \(i = 0; i < dimm_cnt; i\+\+\) \{/i\    srand(time(0));"
echo "    if (slot_cnt > dimm_cnt)"
echo "        for (i = dimm_cnt; i < slot_cnt; i++)"
echo "            smbios_build_type_17_table(i, 0);"
echo "    ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^"
echo "    for (i = 0; i < mem_array_size; i++) {"
sed -i "$file_smbios" -Ee "/    for \(i = 0; i < mem_array_size; i\+\+\) \{/i\    if (slot_cnt > dimm_cnt)\n\
        for (i = dimm_cnt; i < slot_cnt; i++)\n\
            smbios_build_type_17_table(i, 0);\n"
echo "mem_array[i].length);                             -> mem_array[i].length, dimm_cnt);"
sed -i "$file_smbios" -Ee "s/mem_array\[i\].length\);/mem_array[i].length, dimm_cnt);/"
echo "    for (i = 0; i < dimm_cnt; i++)"
echo "        smbios_build_type_20_table(i, GET_DIMM_SZ);"
echo "    smbios_build_type_26_table();"
echo "    smbios_build_type_27_table();"
echo "    smbios_build_type_28_table();"
echo "    ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^"
echo "    smbios_build_type_32_table();"
sed -i "$file_smbios" -Ee "/    smbios_build_type_32_table\(\);/i\    for (i = 0; i < dimm_cnt; i++)\n\
        smbios_build_type_20_table(i, GET_DIMM_SZ);\n\n\
    smbios_build_type_26_table();\n\
    smbios_build_type_27_table();\n\
    smbios_build_type_28_table();"
echo "bios_starting_address_segment = cpu_to_le16(0xE800) -> bios_starting_address_segment = cpu_to_le16(0xE000)"
echo "bios_rom_size = 0                                 -> bios_rom_size = 0xFF"
echo "bios_characteristics = cpu_to_le64(0x08)          -> bios_characteristics = cpu_to_le64(0x0040001330099880)"
echo "bios_characteristics_extension_bytes[0] = 0       -> bios_characteristics_extension_bytes[0] = 0x03"
echo "bios_characteristics_extension_bytes[1] = 0x14    -> bios_characteristics_extension_bytes[1] = 0x0D"
echo "feature_flags = 0x01                              -> feature_flags = 0x09"
echo "location = 0x01; /* Other */                      -> location = 0x03; /* Motherboard */"
echo "error_correction = 0x06                           -> error_correction = 0x03"
echo "    char loc_str[128];"
echo "    v v v v v v v v v v"
echo "    char bank_str[128];"
echo "    char serial_str[128];"
sed -i "$file_smbios" -Ee "/    char loc_str\[128\];/a\    char bank_str[128];\n\
    char serial_str[128];"
echo "total_width = cpu_to_le16(0xFFFF);                -> total_width = cpu_to_le16(64); /* 64-bit no ECC */"
echo "data_width = cpu_to_le16(0xFFFF);                 -> data_width = cpu_to_le16(64); /* 64-bit no ECC */"
echo "type17.loc_pfx, instance);                        -> type17.loc_pfx, instance % 2);"
sed -i "$file_smbios" -Ee "s/bios_starting_address_segment = cpu_to_le16\(0xE800\)/bios_starting_address_segment = cpu_to_le16(0xE000)/"
sed -i "$file_smbios" -Ee "s/t->bios_rom_size = 0/t->bios_rom_size = 0xFF/"
sed -i "$file_smbios" -Ee "s/bios_characteristics = cpu_to_le64\(0x08\)/bios_characteristics = cpu_to_le64(0x0040001330099880)/"
sed -i "$file_smbios" -Ee "s/bios_characteristics_extension_bytes\[0\] = 0/bios_characteristics_extension_bytes[0] = 0x03/"
sed -i "$file_smbios" -Ee "s/bios_characteristics_extension_bytes\[1\] = 0x04/bios_characteristics_extension_bytes[1] = 0x0D/"
sed -i "$file_smbios" -Ee "s/feature_flags = 0x01/feature_flags = 0x09/"
sed -i "$file_smbios" -Ee "s/location = 0x01; \/\* Other \*\//location = 0x03; \/* Motherboard *\//"
sed -i "$file_smbios" -Ee "s/error_correction = 0x06/error_correction = 0x03/"
sed -i "$file_smbios" -Ee "s/total_width = cpu_to_le16\(0xFFFF\); \/\* Unknown \*\//total_width = cpu_to_le16\(64\); \/* 64-bit no ECC *\//"
sed -i "$file_smbios" -Ee "s/data_width = cpu_to_le16\(0xFFFF\); \/\* Unknown \*\//data_width = cpu_to_le16\(64\); \/* 64-bit no ECC *\//"
sed -i "$file_smbios" -Ee "s/type17.loc_pfx, instance\);/type17.loc_pfx, instance % 2);/"
echo "    SMBIOS_TABLE_SET_STR(17, device_locator_str, loc_str);"
echo "    v v v v v v v v v v v v v v v v v v v v v v v v v v v v v v v v v v v v v"
echo "    snprintf(bank_str, sizeof(bank_str), \"%s %d\", type17.bank, instance / 2);"
sed -i "$file_smbios" -Ee "/    SMBIOS_TABLE_SET_STR\(17, device_locator_str, loc_str\);/a\    snprintf(bank_str, sizeof(bank_str), \"%s %d\", type17.bank, instance / 2);"
echo "bank_locator_str, type17.bank);                   -> bank_locator_str, bank_str);"
echo "memory_type = 0x07; /* RAM */                     -> memory_type = 0x18; /* DDR3 */"
echo "type_detail = cpu_to_le16(0x02); /* Other */      -> type_detail = cpu_to_le16(0x80); /* Synchronous */"
sed -i "$file_smbios" -Ee "s/bank_locator_str, type17.bank\);/bank_locator_str, bank_str);/"
sed -i "$file_smbios" -Ee "s/memory_type = 0x07; \/\* RAM \*\//memory_type = 0x1A; \/* DDR4 *\//"
sed -i "$file_smbios" -Ee "s/type_detail = cpu_to_le16\(0x02\); \/\* Other \*\//type_detail = cpu_to_le16\(0x80\); \/* Synchronous *\//"
echo "    SMBIOS_TABLE_SET_STR(17, manufacturer_str, type17.manufacturer);"
echo "    v v v v v v v v v v v v v v v v v v v v v v v v v v v v"
echo "    snprintf(serial_str, 11, \"%s%d\", type17.serial, rand());"
sed -i "$file_smbios" -Ee "/    SMBIOS_TABLE_SET_STR\(17, manufacturer_str, type17.manufacturer\);/a\    snprintf(serial_str, 11, \"%s%d\", type17.serial, rand());"
echo "serial_number_str, type17.serial);                -> serial_number_str, serial_str);"
echo "attributes = 0; /* Unknown */                     -> attributes = 0x01; /* Single rank */"
echo "minimum_voltage = cpu_to_le16(0); /* Unknown */   -> minimum_voltage = cpu_to_le16(1200);"
echo "maximum_voltage = cpu_to_le16(0); /* Unknown */   -> maximum_voltage = cpu_to_le16(1350);"
echo "configured_voltage = cpu_to_le16(0);              -> configured_voltage = cpu_to_le16(1200);"
sed -i "$file_smbios" -Ee "s/serial_number_str, type17.serial\);/serial_number_str, serial_str);/"
sed -i "$file_smbios" -Ee "s/attributes = 0; \/\* Unknown \*\//attributes = 0x01; \/* Single rank *\//"
sed -i "$file_smbios" -Ee "s/minimum_voltage = cpu_to_le16\(0\); \/\* Unknown \*\//minimum_voltage = cpu_to_le16\(1200\);/"
sed -i "$file_smbios" -Ee "s/maximum_voltage = cpu_to_le16\(0\); \/\* Unknown \*\//maximum_voltage = cpu_to_le16\(1350\);/"
sed -i "$file_smbios" -Ee "s/configured_voltage = cpu_to_le16\(0\); \/\* Unknown \*\//configured_voltage = cpu_to_le16\(1200\);/"
echo "        t->size = cpu_to_le16(0); /* Not installed */"
echo "        SMBIOS_BUILD_TABLE_POST;"
echo "        return;"
echo "    }"
echo "    ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^"
echo "    size_mb = QEMU_ALIGN_UP(size, MiB) / MiB;"
sed -i "$file_smbios" -e  '/    SMBIOS_BUILD_TABLE_PRE(17, T17_BASE/{n;n;n;n;N;d;}'
sed -i "$file_smbios" -Ee "/    size_mb = QEMU_ALIGN_UP\(size, MiB\) \/ MiB;/i\    if (size == 0) {\n\
        t->total_width = cpu_to_le16(0xFFFF); /* Unknown */\n\
        t->data_width = cpu_to_le16(0xFFFF); /* Unknown */\n\
        t->size = cpu_to_le16(0); /* Not installed */\n\
        t->form_factor = 0x02; /* Unknown */\n\
        t->device_set = 0; /* Not in a set */\n\
        snprintf(loc_str, sizeof(loc_str), \"%s %d\", type17.loc_pfx, instance % 2);\n\
        SMBIOS_TABLE_SET_STR(17, device_locator_str, loc_str);\n\
        snprintf(bank_str, sizeof(bank_str), \"%s %d\", type17.bank, instance / 2);\n\
        SMBIOS_TABLE_SET_STR(17, bank_locator_str, bank_str);\n\
        t->memory_type = 0x02; /* Unknown */\n\
        t->type_detail = cpu_to_le16(0x04); /* Unknown */\n\
        t->speed = cpu_to_le16(0); /* Unknown */\n\
        t->manufacturer_str = 0;\n\
        t->serial_number_str = 0;\n\
        t->asset_tag_number_str = 0;\n\
        t->part_number_str = 0;\n\
        t->attributes = 0; /* Unknown */\n\
        t->extended_size = cpu_to_le32(0); /* Unknown */\n\
        t->configured_clock_speed = 0; /* Unknown */\n\
        t->minimum_voltage = cpu_to_le16(0); /* Unknown */\n\
        t->maximum_voltage = cpu_to_le16(0); /* Unknown */\n\
        t->configured_voltage = cpu_to_le16(0); /* Unknown */\n\
\n\
        SMBIOS_BUILD_TABLE_POST;\n\
        return;\n\
    }\n\
    t->total_width = cpu_to_le16(64); /* 64-bit no ECC */\n\
    t->data_width = cpu_to_le16(64); /* 64-bit no ECC */"

echo "  $file_lu_c"
get_new_string 4 1
echo "\"QEMU\"                                            -> \"$new_string\""
echo "\"QEMU UFS\"                                        -> \"$new_string UFS\""
sed -i "$file_lu_c" -Ee "s/\"QEMU\"/\"$new_string\"/"
sed -i "$file_lu_c" -Ee "s/\"QEMU UFS\"/\"$new_string UFS\"/"

echo "  $file_devaudio_c"
get_new_string $(shuf -i 5-7 -n 1) 3
number=$(get_random_dec 10)
echo "\"QEMU\",                                           -> \"$prefix$suffix\","
echo "\"QEMU USB Audio\"                                  -> \"$prefix$suffix USB Audio\""
echo "\"1\"                                               -> \"$number\""
echo "\"Audio Configuration\"                             -> \"USB Audio Config\""
echo "\"Audio Device\"                                    -> \"USB Audio Control\""
echo "\"Audio Output Pipe\"                               -> \"USB Audio Input Terminal\""
echo "\"Audio Output Volume Control\"                     -> \"USB Audio Feature Unit\""
echo "\"Audio Output Terminal\"                           -> \"USB Audio Output Terminal\""
echo "\"Audio Output - Disabled\"                         -> \"USB Audio Null Stream\""
echo "\"Audio Output - 48 kHz Stereo\"                    -> \"USB Audio Real Stream\""
echo "QEMU USB Audio Interface                          -> $prefix$suffix USB Audio"
sed -i "$file_devaudio_c" -Ee "s/\"QEMU\",/\"$prefix$suffix\",/"
sed -i "$file_devaudio_c" -Ee "s/\"QEMU USB Audio\"/\"$prefix$suffix USB Audio\"/"
sed -i "$file_devaudio_c" -Ee "s/\"1\"/\"$number\"/"
sed -i "$file_devaudio_c" -Ee "s/\"Audio Configuration\"/\"USB Audio Config\"/"
sed -i "$file_devaudio_c" -Ee "s/\"Audio Device\"/\"USB Audio Control\"/"
sed -i "$file_devaudio_c" -Ee "s/\"Audio Output Pipe\"/\"USB Audio Input Terminal\"/"
sed -i "$file_devaudio_c" -Ee "s/\"Audio Output Volume Control\"/\"USB Audio Feature Unit\"/"
sed -i "$file_devaudio_c" -Ee "s/\"Audio Output Terminal\"/\"USB Audio Output Terminal\"/"
sed -i "$file_devaudio_c" -Ee "s/\"Audio Output - Disabled\"/\"USB Audio Null Stream\"/"
sed -i "$file_devaudio_c" -Ee "s/\"Audio Output - 48 kHz Stereo\"/\"USB Audio Real Stream\"/"
sed -i "$file_devaudio_c" -Ee "s/QEMU USB Audio Interface/$prefix$suffix USB Audio/"

echo "  $file_devhid_c"
get_new_string $(shuf -i 5-7 -n 1) 3
echo "\"QEMU\"                                            -> \"$prefix$suffix\""
echo "_MOUSE]    = \"QEMU USB Mouse\"                     -> _MOUSE]    = \"$prefix$suffix USB Mouse\""
echo "_TABLET]   = \"QEMU USB Tablet\"                    -> _TABLET]   = \"$prefix$suffix USB Tablet\""
echo "_KEYBOARD] = \"QEMU USB Keyboard\"                  -> _KEYBOARD] = \"$prefix$suffix USB Keyboard\""
sed -i "$file_devhid_c" -Ee "s/\"QEMU\"/\"$prefix$suffix\"/"
sed -i "$file_devhid_c" -Ee "s/_MOUSE]    = \"QEMU USB Mouse\"/_MOUSE]    = \"$prefix$suffix USB Mouse\"/"
sed -i "$file_devhid_c" -Ee "s/_TABLET]   = \"QEMU USB Tablet\"/_TABLET]   = \"$prefix$suffix USB Tablet\"/"
sed -i "$file_devhid_c" -Ee "s/_KEYBOARD] = \"QEMU USB Keyboard\"/_KEYBOARD] = \"$prefix$suffix USB Keyboard\"/"
number=$(get_random_dec 10)
echo "\"89126\"                                           -> \"$number\""
sed -i "$file_devhid_c" -Ee "s/\"89126\"/\"$number\"/"
number=$(get_random_dec 10)
echo "\"28754\"                                           -> \"$number\""
sed -i "$file_devhid_c" -Ee "s/\"28754\"/\"$number\"/"
number=$(get_random_dec 10)
echo "\"68284\"                                           -> \"$number\""
sed -i "$file_devhid_c" -Ee "s/\"68284\"/\"$number\"/"
echo "_desc   = \"QEMU USB Tablet\"                       -> _desc   = \"$prefix$suffix USB Tablet\""
echo "_desc   = \"QEMU USB Mouse\"                        -> _desc   = \"$prefix$suffix USB Mouse\""
echo "_desc   = \"QEMU USB Keyboard\"                     -> _desc   = \"$prefix$suffix USB Keyboard\""
sed -i "$file_devhid_c" -Ee "s/_desc   = \"QEMU USB Tablet\"/_desc   = \"$prefix$suffix USB Tablet\"/"
sed -i "$file_devhid_c" -Ee "s/_desc   = \"QEMU USB Mouse\"/_desc   = \"$prefix$suffix USB Mouse\"/"
sed -i "$file_devhid_c" -Ee "s/_desc   = \"QEMU USB Keyboard\"/_desc   = \"$prefix$suffix USB Keyboard\"/"
echo "0x0627                                            -> 0x045e"
sed -i "$file_devhid_c" -Ee "s/0x0627/0x045e/"

echo "  $file_devhub_c"
get_new_string $(shuf -i 5-7 -n 1) 3
number=$(get_random_dec 10)
echo "\"QEMU\"                                            -> \"$prefix$suffix\""
echo "_PRODUCT]      = \"QEMU USB Hub\"                   -> _PRODUCT]      = \"$prefix$suffix USB Hub\""
echo "\"314159\"                                          -> \"$number\""
echo "_desc   = \"QEMU USB Hub\"                          -> _desc   = \"$prefix$suffix USB Hub\""
sed -i "$file_devhub_c" -Ee "s/\"QEMU\"/\"$prefix$suffix\"/"
sed -i "$file_devhub_c" -Ee "s/_PRODUCT]      = \"QEMU USB Hub\"/_PRODUCT]      = \"$prefix$suffix USB Hub\"/"
sed -i "$file_devhub_c" -Ee "s/\"314159\"/\"$number\"/"
sed -i "$file_devhub_c" -Ee "s/_desc   = \"QEMU USB Hub\"/_desc   = \"$prefix$suffix USB Hub\"/"

echo "  $file_devmtp_c"
get_new_string $(shuf -i 5-7 -n 1) 3
number=$(get_random_dec 10)
echo "MTP_MANUFACTURER  \"QEMU\"                          -> MTP_MANUFACTURER  \"$prefix$suffix\""
echo "QEMU filesharing                                  -> $prefix$suffix USB MTP"
echo "\"34617\"                                           -> \"$number\""
echo "_desc   = \"QEMU USB MTP\"                          -> _desc   = \"$prefix$suffix USB MTP\""
sed -i "$file_devmtp_c" -Ee "s/MTP_MANUFACTURER  \"QEMU\"/MTP_MANUFACTURER  \"$prefix$suffix\"/"
sed -i "$file_devmtp_c" -Ee "s/QEMU filesharing/$prefix$suffix USB MTP/"
sed -i "$file_devmtp_c" -Ee "s/\"34617\"/\"$number\"/"
sed -i "$file_devmtp_c" -Ee "s/_desc   = \"QEMU USB MTP\"/_desc   = \"$prefix$suffix USB MTP\"/"

echo "  $file_devnetwork_c"
get_new_string 4 1
word=$(get_random_hex 12)
number=$(get_random_dec 10)
echo "\"QEMU\"                                            -> \"$new_string\""
echo "RNDIS/QEMU USB Network Device                     -> $new_string RNDIS USB Network Adapter"
echo "\"400102030405\"                                    -> \"$word\""
echo "QEMU USB Net Data Interface                       -> USB Net Data"
echo "QEMU USB Net Control Interface                    -> USB Net Control"
echo "QEMU USB Net RNDIS Control Interface              -> USB Net RNDIS Control"
echo "QEMU USB Net CDC                                  -> USB Net CDC"
echo "QEMU USB Net Subset                               -> USB Net Subset"
echo "QEMU USB Net RNDIS                                -> USB Net RNDIS"
echo "\"1\"                                               -> \"$number\""
echo "QEMU USB RNDIS Net                                -> $new_string RNDIS USB Net"
echo "QEMU USB Network Interface                        -> $new_string RNDIS USB Network Adapter"
sed -i "$file_devnetwork_c" -Ee "s/\"QEMU\"/\"$new_string\"/"
sed -i "$file_devnetwork_c" -Ee "s/RNDIS\/QEMU USB Network Device/$new_string RNDIS USB Network Adapter/"
sed -i "$file_devnetwork_c" -Ee "s/\"400102030405\"/\"$word\"/"
sed -i "$file_devnetwork_c" -Ee "s/QEMU USB Net Data Interface/USB Net Data/"
sed -i "$file_devnetwork_c" -Ee "s/QEMU USB Net Control Interface/USB Net Control/"
sed -i "$file_devnetwork_c" -Ee "s/QEMU USB Net RNDIS Control Interface/USB Net RNDIS Control/"
sed -i "$file_devnetwork_c" -Ee "s/QEMU USB Net CDC/USB Net CDC/"
sed -i "$file_devnetwork_c" -Ee "s/QEMU USB Net Subset/USB Net Subset/"
sed -i "$file_devnetwork_c" -Ee "s/QEMU USB Net RNDIS/USB Net RNDIS/"
sed -i "$file_devnetwork_c" -Ee "s/\"1\"/\"$number\"/"
sed -i "$file_devnetwork_c" -Ee "s/QEMU USB RNDIS Net/$new_string RNDIS USB Net/"
sed -i "$file_devnetwork_c" -Ee "s/QEMU USB Network Interface/$new_string RNDIS USB Network Adapter/"

echo "  $file_devserial_c"
get_new_string $(shuf -i 5-7 -n 1) 3
number=$(get_random_dec 10)
echo "\"QEMU\"                                            -> \"$prefix$suffix\""
echo "_SERIAL]  = \"QEMU USB SERIAL\"                     -> $prefix$suffix USB Serial"
echo "_BRAILLE]  = \"QEMU USB BAUM BRAILLE\"              -> $prefix$suffix USB Braille"
echo "\"1\"                                               -> \"$number\""
echo "_desc   = \"QEMU USB Serial\"                       -> _desc   = \"$prefix$suffix USB Serial\""
echo "_desc   = \"QEMU USB Braille\"                      -> _desc   = \"$prefix$suffix USB Braille\""
sed -i "$file_devserial_c" -Ee "s/\"QEMU\"/\"$prefix$suffix\"/"
sed -i "$file_devserial_c" -Ee "s/_SERIAL\]  = \"QEMU USB SERIAL\"/_SERIAL\]  = \"$prefix$suffix USB Serial\"/"
sed -i "$file_devserial_c" -Ee "s/_BRAILLE\] = \"QEMU USB BAUM BRAILLE\"/_BRAILLE\] = \"$prefix$suffix USB Braille\"/"
sed -i "$file_devserial_c" -Ee "s/\"1\"/\"$number\"/"
sed -i "$file_devserial_c" -Ee "s/_desc   = \"QEMU USB Serial\"/_desc   = \"$prefix$suffix USB Serial\"/"
sed -i "$file_devserial_c" -Ee "s/_desc   = \"QEMU USB Braille\"/_desc   = \"$prefix$suffix USB Braille\"/"

echo "  $file_devsmartcardreader_c"
get_new_string $(shuf -i 5-7 -n 1) 3
number=$(get_random_dec 10)
echo "_MANUFACTURER]  = \"QEMU\"                          -> _MANUFACTURER]  = \"$prefix$suffix\""
echo "_PRODUCT]       = \"QEMU USB CCID\"                 -> _PRODUCT]       = \"$prefix$suffix USB CCID\""
echo "_SERIALNUMBER]  = \"1\"                             -> _SERIALNUMBER]  = \"$number\""
echo "_desc   = \"QEMU USB CCID\"                         -> _desc   = \"$prefix$suffix USB CCID\""
sed -i "$file_devsmartcardreader_c" -Ee "s/_MANUFACTURER]  = \"QEMU\"/_MANUFACTURER]  = \"$prefix$suffix\"/"
sed -i "$file_devsmartcardreader_c" -Ee "s/_PRODUCT]       = \"QEMU USB CCID\"/_PRODUCT]       = \"$prefix$suffix USB CCID\"/"
sed -i "$file_devsmartcardreader_c" -Ee "s/_SERIALNUMBER]  = \"1\"/_SERIALNUMBER]  = \"$number\"/"
sed -i "$file_devsmartcardreader_c" -Ee "s/_desc   = \"QEMU USB CCID\"/_desc   = \"$prefix$suffix USB CCID\"/"

echo "  $file_devstorage_c"
get_new_string $(shuf -i 5-7 -n 1) 3
serial=$(get_random_serial 16)
echo "\"QEMU\",                                           -> \"$new_string\","
echo "QEMU USB HARDDRIVE                                -> $new_string USB HDD"
echo "\"1\"                                               -> \"$serial\""
echo "_desc   = \"QEMU USB MSD\"                          -> _desc   = \"$new_string USB HDD\""
sed -i "$file_devstorage_c" -Ee "s/\"QEMU\",/\"$new_string\",/"
sed -i "$file_devstorage_c" -Ee "s/QEMU USB HARDDRIVE/$new_string USB HDD/"
sed -i "$file_devstorage_c" -Ee "s/\"1\"/\"$serial\"/"
sed -i "$file_devstorage_c" -Ee "s/_desc   = \"QEMU USB MSD\"/_desc   = \"$new_string USB HDD\"/"

echo "  $file_devuas_c"
get_new_string $(shuf -i 5-7 -n 1) 3
number=$(get_random_dec 10)
echo "\"QEMU\",                                           -> \"$prefix$suffix\","
echo "USB Attached SCSI HBA                             -> $prefix$suffix USB Attached SCSI HBA"
echo "\"27842\"                                           -> \"$number\""
sed -i "$file_devuas_c" -Ee "s/\"QEMU\",/\"$prefix$suffix\",/"
sed -i "$file_devuas_c" -Ee "s/USB Attached SCSI HBA/$prefix$suffix USB Attached SCSI HBA/"
sed -i "$file_devuas_c" -Ee "s/\"27842\"/\"$number\"/"

echo "  $file_devwacom_c"
number=$(get_random_dec 10)
echo "\"QEMU\"                                            -> \"Wacom\""
echo "Wacom PenPartner                                  -> Wacom PenPartner Tablet"
echo "\"1\"                                               -> \"$number\""
echo "QEMU PenPartner tablet                            -> Wacom PenPartner Tablet"
echo "_desc   = \"QEMU PenPartner Tablet\"                -> _desc   = \"Wacom PenPartner Tablet\""
echo "desc = \"QEMU PenPartner Tablet\"                   -> desc = \"Wacom PenPartner Tablet\""
sed -i "$file_devwacom_c" -Ee "s/\"QEMU\"/\"Wacom\"/"
sed -i "$file_devwacom_c" -Ee "s/Wacom PenPartner/Wacom PenPartner Tablet/"
sed -i "$file_devwacom_c" -Ee "s/\"1\"/\"$number\"/"
sed -i "$file_devwacom_c" -Ee "s/QEMU PenPartner tablet/Wacom PenPartner Tablet/"
sed -i "$file_devwacom_c" -Ee "s/_desc   = \"QEMU PenPartner Tablet\"/_desc   = \"Wacom PenPartner Tablet\"/"
sed -i "$file_devwacom_c" -Ee "s/desc = \"QEMU PenPartner Tablet\"/desc = \"Wacom PenPartner Tablet\"/"

#echo "  $file_hcduhci_c"

#echo "  $file_hcdehcipci_c"

echo "  $file_u2f_c"
get_new_string $(shuf -i 5-7 -n 1) 3
number=$(get_random_dec 10)
echo "\"QEMU\",                                           -> \"$prefix$suffix\","
echo "\"U2F USB key\"                                     -> \"$prefix$suffix U2F USB key\""
echo "\"0\"                                               -> \"$number\""
echo "_desc   = \"QEMU U2F USB key\"                      -> _desc   = \"$prefix$suffix U2F USB key\""
echo "desc           = \"QEMU U2F key\"                   -> desc           = \"$prefix$suffix U2F USB key\""
sed -i "$file_u2f_c" -Ee "s/\"QEMU\",/\"$prefix$suffix\",/"
sed -i "$file_u2f_c" -Ee "s/\"U2F USB key\"/\"$prefix$suffix U2F USB key\"/"
sed -i "$file_u2f_c" -Ee "s/\"0\"/\"$number\"/"
sed -i "$file_u2f_c" -Ee "s/_desc   = \"QEMU U2F USB key\"/_desc   = \"$prefix$suffix U2F USB key\"/"
sed -i "$file_u2f_c" -Ee "s/desc           = \"QEMU U2F key\"/desc           = \"$prefix$suffix U2F USB key\"/"

echo "  $file_u2femulated_c"
get_new_string $(shuf -i 5-7 -n 1) 3
echo "desc = \"QEMU U2F emulated key\"                    -> desc = \"$prefix$suffix U2F emulated key\""
sed -i "$file_u2femulated_c" -Ee "s/desc = \"QEMU U2F emulated key\"/desc = \"$prefix$suffix U2F emulated key\"/"

echo "  $file_u2fpassthru_c"
get_new_string $(shuf -i 5-7 -n 1) 3
echo "desc = \"QEMU U2F passthrough key\"                 -> desc = \"$prefix$suffix U2F passthrough key\""
sed -i "$file_u2fpassthru_c" -Ee "s/desc = \"QEMU U2F passthrough key\"/desc = \"$prefix$suffix U2F passthrough key\"/"

echo "  $file_amlbuild_h"
echo "APPNAME6 \"BOCHS \"                                 -> APPNAME6 \"$dsdt_oem_id\""
echo "APPNAME8 \"BXPC    \"                               -> APPNAME8 \"$dsdt_oem_table\""
sed -i "$file_amlbuild_h" -Ee "s/APPNAME6 \"BOCHS \"/APPNAME6 \"$dsdt_oem_id\"/"
sed -i "$file_amlbuild_h" -Ee "s/APPNAME8 \"BXPC    \"/APPNAME8 \"$dsdt_oem_table\"/"

echo "  $file_pchotplug_h"
echo "ICH9_CPU_HOTPLUG_IO_BASE 0x0CD8                   -> ICH9_CPU_HOTPLUG_IO_BASE 0x$( printf '%X' $cpu )"
sed -i "$file_pchotplug_h" -Ee "s/ICH9_CPU_HOTPLUG_IO_BASE 0x0CD8/ICH9_CPU_HOTPLUG_IO_BASE 0x$( printf '%X' $cpu )/"

echo "  $file_smbios_h"
echo "/* SMBIOS type 7 - Cache Information */"
echo "struct smbios_type_7 {"
echo "} QEMU_PACKED;"
echo "^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^"
echo "/* SMBIOS type 8 - Port Connector Information */"
sed -i "$file_smbios_h" -Ee "/\/\* SMBIOS type 8 - Port Connector Information \*\//i/* SMBIOS type 7 - Cache Information */\n\
struct smbios_type_7 {\n\
    struct smbios_structure_header header;\n\
    uint8_t socket_designation;\n\
    uint16_t cache_configuration;\n\
    uint16_t maximum_cache_size;\n\
    uint16_t installed_size;\n\
    uint16_t supported_sram_type;\n\
    uint16_t current_sram_type;\n\
    uint8_t cache_speed;\n\
    uint8_t error_correction_type;\n\
    uint8_t system_cache_type;\n\
    uint8_t associativity;\n\
    uint32_t maximum_cache_size_2;\n\
    uint32_t installed_size_2;\n\
} QEMU_PACKED;\n"
echo "/* SMBIOS type 20 - Memory Device Mapped Address */"
echo "struct smbios_type_20 {"
echo "} QEMU_PACKED;"
echo "/* SMBIOS type 26 - Voltage Probe */"
echo "struct smbios_type_26 {"
echo "} QEMU_PACKED;"
echo "/* SMBIOS type 27 - Cooling Device */"
echo "struct smbios_type_27 {"
echo "} QEMU_PACKED;"
echo "/* SMBIOS type 28 - Temperature Probe */"
echo "struct smbios_type_28 {"
echo "} QEMU_PACKED;"
echo "^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^"
echo "/* SMBIOS type 32 - System Boot Information */"
sed -i "$file_smbios_h" -Ee "/\/\* SMBIOS type 32 - System Boot Information \*\//i/* SMBIOS type 20 - Memory Device Mapped Address */\n\
struct smbios_type_20 {\n\
    struct smbios_structure_header header;\n\
    uint32_t starting_address;\n\
    uint32_t ending_address;\n\
    uint16_t memory_device_handle;\n\
    uint16_t memory_array_mapped_address_handle;\n\
    uint8_t partition_row_position;\n\
    uint8_t interleave_position;\n\
    uint8_t interleaved_data_depth;\n\
    uint64_t extended_starting_address;\n\
    uint64_t extended_ending_address;\n\
} QEMU_PACKED;\n\
\n\
/* SMBIOS type 26 - Voltage Probe */\n\
struct smbios_type_26 {\n\
    struct smbios_structure_header header;\n\
    uint8_t description;\n\
    uint8_t location_and_status;\n\
    uint16_t maximum_value;\n\
    uint16_t minimum_value;\n\
    uint16_t resolution;\n\
    uint16_t tolerance;\n\
    uint16_t accuracy;\n\
    uint32_t oem_defined;\n\
    uint16_t nominal_value;\n\
} QEMU_PACKED;\n\
\n\
/* SMBIOS type 27 - Cooling Device */\n\
struct smbios_type_27 {\n\
    struct smbios_structure_header header;\n\
    uint16_t temperature_probe_handle;\n\
    uint8_t device_type_and_status;\n\
    uint8_t cooling_unit_group;\n\
    uint32_t oem_defined;\n\
    uint16_t nominal_speed;\n\
    uint8_t description;\n\
} QEMU_PACKED;\n\
\n\
/* SMBIOS type 28 - Temperature Probe */\n\
struct smbios_type_28 {\n\
    struct smbios_structure_header header;\n\
    uint8_t description;\n\
    uint8_t location_and_status;\n\
    uint16_t maximum_value;\n\
    uint16_t minimum_value;\n\
    uint16_t resolution;\n\
    uint16_t tolerance;\n\
    uint16_t accuracy;\n\
    uint32_t oem_defined;\n\
    uint16_t nominal_value;\n\
} QEMU_PACKED;\n"

echo "  $file_x86_h"
echo "((1<<5) | (1<<9) | (1<<10) | (1<<11))             -> (1<<9)"
sed -i "$file_x86_h" -Ee "s/\(\(1<<5\) \| \(1<<9\) \| \(1<<10\) \| \(1<<11\)\)/(1<<9)/"

echo "  $file_pci_h"
if [[ "${cpu_vendor:1}" == "AuthenticAMD" ]]; then
  echo "QEMU               0x1234                         -> QEMU               0x1022"
  echo "VMWARE             0x15ad                         -> VMWARE             0x1022"
#  echo "QUMRANET    0x1af4                                -> QUMRANET    0x1022"
  echo "QUMRANET 0x1af4                                   -> QUMRANET 0x1022"
  echo "REDHAT             0x1b36                         -> REDHAT             0x1022"
  echo "PCIE_RP     0x000c                                -> PCIE_RP     0x1448  // Renoir Device 24: Function 0"
  echo "XHCI        0x000d                                -> XHCI        0x7914  // FCH USB XHCI Controller"
  echo "PCIE_BRIDGE 0x000e                                -> PCIE_BRIDGE 0x1633  // Renoir PCIe GPP Bridge"
  sed -i "$file_pci_h" -Ee "s/QEMU               0x1234/QEMU               0x1022/"
  sed -i "$file_pci_h" -Ee "s/VMWARE             0x15ad/VMWARE             0x1022/"
#  sed -i "$file_pci_h" -Ee "s/QUMRANET    0x1af4/QUMRANET    0x1022/"
  sed -i "$file_pci_h" -Ee "s/QUMRANET 0x1af4/QUMRANET 0x1022/"
  sed -i "$file_pci_h" -Ee "s/REDHAT             0x1b36/REDHAT             0x1022/"
  sed -i "$file_pci_h" -Ee "s/PCIE_RP     0x000c/PCIE_RP     0x$rootport_1022/"
  sed -i "$file_pci_h" -Ee "s/XHCI        0x000d/XHCI        0x$( printf '%X' $((xhci)) )/"
  sed -i "$file_pci_h" -Ee "s/PCIE_BRIDGE 0x000e/PCIE_BRIDGE 0x$hostbridge_1022/"
else
  echo "QEMU               0x1234                         -> QEMU               0x8086"
  echo "VMWARE             0x15ad                         -> VMWARE             0x8086"
#  echo "QUMRANET    0x1af4                                -> QUMRANET    0x8086"
  echo "QUMRANET 0x1af4                                   -> QUMRANET 0x8086"
  echo "REDHAT             0x1b36                         -> REDHAT             0x8086"
  echo "PCIE_RP     0x000c                                -> PCIE_RP     0x06BA  // Comet Lake PCI Express Root Port #1"
  echo "XHCI        0x000d                                -> XHCI        0x06ED  // Comet Lake USB 3.1 xHCI Host Controller"
  echo "PCIE_BRIDGE 0x000e                                -> PCIE_BRIDGE 0x9B54  // 10th Gen Core Processor Host Bridge/DRAM Registers"
  sed -i "$file_pci_h" -Ee "s/QEMU               0x1234/QEMU               0x8086/"
  sed -i "$file_pci_h" -Ee "s/VMWARE             0x15ad/VMWARE             0x8086/"
#  sed -i "$file_pci_h" -Ee "s/QUMRANET    0x1af4/QUMRANET    0x8086/"
  sed -i "$file_pci_h" -Ee "s/QUMRANET 0x1af4/QUMRANET 0x8086/"
  sed -i "$file_pci_h" -Ee "s/REDHAT             0x1b36/REDHAT             0x8086/"
  sed -i "$file_pci_h" -Ee "s/PCIE_RP     0x000c/PCIE_RP     0x$rootport_8086/"
  sed -i "$file_pci_h" -Ee "s/XHCI        0x000d/XHCI        0x$( printf '%X' $((xhci)) )/"
  sed -i "$file_pci_h" -Ee "s/PCIE_BRIDGE 0x000e/PCIE_BRIDGE 0x$hostbridge_8086/"
fi
echo "0x1111                                            -> 0x$device"
sed -i "$file_pci_h" -Ee "s/0x1111/0x$device/"
echo "QUMRANET    0x1af4                                -> QUMRANET    0x8086"
sed -i "$file_pci_h" -Ee "s/QUMRANET    0x1af4/QUMRANET    0x8086/"
echo "VIRTIO_10_BASE     0x1040                         -> VIRTIO_10_BASE     0x$( printf '%X' $((virtio - 1)) )"
sed -i "$file_pci_h" -Ee "s/VIRTIO_10_BASE     0x1040/VIRTIO_10_BASE     0x$( printf '%X' $((virtio - 1)) )/"

echo "  $file_pciids_h"
if [[ "${cpu_vendor:1}" == "AuthenticAMD" ]]; then
  echo "PCI_DEVICE_ID_INTEL_P35_MCH      0x29c0           -> PCI_DEVICE_ID_INTEL_P35_MCH      0x$pcibridge_1022"
  sed -i "$file_pciids_h" -Ee "s/PCI_DEVICE_ID_INTEL_P35_MCH      0x29c0/PCI_DEVICE_ID_INTEL_P35_MCH      0x$pcibridge_1022/"
  echo "VMWARE             0x15ad                         -> VMWARE             0x1022"
  sed -i "$file_pciids_h" -Ee "s/VMWARE             0x15ad/VMWARE             0x1022/"
else
  echo "PCI_DEVICE_ID_INTEL_P35_MCH      0x29c0           -> PCI_DEVICE_ID_INTEL_P35_MCH      0x$pcibridge_8086"
  sed -i "$file_pciids_h" -Ee "s/PCI_DEVICE_ID_INTEL_P35_MCH      0x29c0/PCI_DEVICE_ID_INTEL_P35_MCH      0x$pcibridge_8086/"
  echo "VMWARE             0x15ad                         -> VMWARE             0x8086"
  sed -i "$file_pciids_h" -Ee "s/VMWARE             0x15ad/VMWARE             0x8086/"
fi

echo "  $file_ich9_h"
if [[ "${cpu_vendor:1}" == "AuthenticAMD" ]]; then
  echo "ICH9_LPC_DEV                            31        -> ICH9_LPC_DEV                            20"
  echo "ICH9_LPC_FUNC                           0         -> ICH9_LPC_FUNC                           3"
  echo "ICH9_SMB_DEV                            31        -> ICH9_SMB_DEV                            20"
  echo "ICH9_SMB_FUNC                           3         -> ICH9_SMB_FUNC                           0"
  sed -i "$file_ich9_h" -Ee "s/ICH9_LPC_DEV                            31/ICH9_LPC_DEV                            20/"
  sed -i "$file_ich9_h" -Ee "s/ICH9_LPC_FUNC                           0/ICH9_LPC_FUNC                           3/"
  sed -i "$file_ich9_h" -Ee "s/ICH9_SMB_DEV                            31/ICH9_SMB_DEV                            20/"
  sed -i "$file_ich9_h" -Ee "s/ICH9_SMB_FUNC                           3/ICH9_SMB_FUNC                           0/"
else
  echo "ICH9_SMB_FUNC                           3         -> ICH9_SMB_FUNC                           4"
  sed -i "$file_ich9_h" -Ee "s/ICH9_SMB_FUNC                           3/ICH9_SMB_FUNC                           4/"
fi

echo "  $file_qemufwcfg_h"
echo "QEMU0002                                          -> UEFI0002"
echo "0x51454d5520434647ULL                             -> 0x${signature}ULL"
sed -i "$file_qemufwcfg_h" -Ee "s/QEMU0002/UEFI0002/"
sed -i "$file_qemufwcfg_h" -Ee "s/0x51454d5520434647ULL/0x${signature}ULL/"

echo "  $file_optionrom_h"
echo "0x51454d5520434647ULL                             -> 0x${signature}ULL"
sed -i "$file_optionrom_h" -Ee "s/0x51454d5520434647ULL/0x${signature}ULL/"

#echo "  $file_configvgaqxl"
#if [[ "${cpu_vendor:1}" == "AuthenticAMD" ]]; then
#  echo "CONFIG_VGA_VID=0x1b36                             -> CONFIG_VGA_VID=0x1022"
#  sed -i "$file_configvgaqxl" -Ee "s/CONFIG_VGA_VID=0x1b36/CONFIG_VGA_VID=0x1022/"
#else
#  echo "CONFIG_VGA_VID=0x1b36                             -> CONFIG_VGA_VID=0x8086"
#  sed -i "$file_configvgaqxl" -Ee "s/CONFIG_VGA_VID=0x1b36/CONFIG_VGA_VID=0x8086/"
#fi

echo "  $file_makefile"
echo "808610d3                                          -> 808610F6"
echo "DID := 10d3                                       -> DID := 10F6"
sed -i "$file_makefile" -Ee "s/808610d3/808610F6/"
sed -i "$file_makefile" -Ee "s/DID := 10d3/DID := 10F6/"

echo "  $file_cpu_c"
echo "typedef struct X86CPUDefinition {"
echo "    v v v v v v v v v v"
echo "    uint8_t t4_family;"
echo "    uint8_t t4_upgrade;"
sed -i "$file_cpu_c" -Ee "/typedef struct X86CPUDefinition \{/a\    uint8_t t4_family;\n\
    uint8_t t4_upgrade;"
echo "extern uint8_t g_type4_family;"
echo "extern uint8_t g_type4_upgrade;"
echo "extern char *g_type4_version;"
echo "^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^"
echo "static void x86_cpu_load_model(X86CPU *cpu, const X86CPUModel *model)"
sed -i "$file_cpu_c" -Ee "/static void x86_cpu_load_model\(X86CPU \*cpu, const X86CPUModel \*model\)/iextern uint8_t g_type4_family;\n\
extern uint8_t g_type4_upgrade;\n\
extern char *g_type4_version;"
echo "    g_type4_family = def->t4_family;"
echo "    g_type4_upgrade = def->t4_upgrade;"
echo "    g_type4_version = malloc(strlen(def->model_id) + 1);"
echo "    strcpy(g_type4_version, def->model_id);"
echo "    ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^"
echo "    object_property_set_str(OBJECT(cpu), \"model-id\", def->model_id,"
sed -i "$file_cpu_c" -Ee "/    object_property_set_str\(OBJECT\(cpu\), \"model-id\", def->model_id,/i\    g_type4_family = def->t4_family;\n\
    g_type4_upgrade = def->t4_upgrade;\n\
    g_type4_version = malloc(strlen(def->model_id) + 1);\n\
    strcpy(g_type4_version, def->model_id);"
if [[ "${cpu_vendor:1}" == "AuthenticAMD" ]]; then
  echo "\"QEMU Virtual CPU version \"                       -> \"AMD CPU version \""
  echo "\"Common KVM processor\"                            -> \"Common AMD processor\""
  echo "\"Common 32-bit KVM processor\"                     -> \"Common 32-bit AMD processor\""
  echo "\"QEMU TCG CPU version \"                           -> \"AMD CPU version \""
  sed -i "$file_cpu_c" -Ee "s/\"QEMU Virtual CPU version \"/\"AMD CPU version \"/"
  sed -i "$file_cpu_c" -Ee "s/\"Common KVM processor\"/\"Common AMD processor\"/"
  sed -i "$file_cpu_c" -Ee "s/\"Common 32-bit KVM processor\"/\"Common 32-bit AMD processor\"/"
  sed -i "$file_cpu_c" -Ee "s/\"QEMU TCG CPU version \"/\"AMD CPU version \"/"
else
  echo "\"QEMU Virtual CPU version \"                       -> \"Intel CPU version \""
  echo "\"Common KVM processor\"                            -> \"Common Intel processor\""
  echo "\"Common 32-bit KVM processor\"                     -> \"Common 32-bit Intel processor\""
  echo "\"QEMU TCG CPU version \"                           -> \"Intel CPU version \""
  sed -i "$file_cpu_c" -Ee "s/\"QEMU Virtual CPU version \"/\"Intel CPU version \"/"
  sed -i "$file_cpu_c" -Ee "s/\"Common KVM processor\"/\"Common Intel processor\"/"
  sed -i "$file_cpu_c" -Ee "s/\"Common 32-bit KVM processor\"/\"Common 32-bit Intel processor\"/"
  sed -i "$file_cpu_c" -Ee "s/\"QEMU TCG CPU version \"/\"Intel CPU version \"/"
fi
nehalem=$(shuf -i 1-9 -n 1)
echo "        .name = \"Nehalem\","
echo ".model = 26,                                      -> .model = 30,"
echo ".stepping = 3,                                    -> .stepping = ${cpu_steppings[$nehalem-1]},"
echo "Intel Core i7 9xx (Nehalem Class Core i7)         -> ${cpu_models[$nehalem-1]}"
sed -i "$file_cpu_c" -Ee "/        .name = \"Nehalem\",/{ n;n;n;n; s/.model = 26,/.model = 30,/ }"
sed -i "$file_cpu_c" -Ee "/        .name = \"Nehalem\",/{ n;n;n;n;n; s/.stepping = 3,/.stepping = ${cpu_steppings[$nehalem-1]},/ }"
sed -i "$file_cpu_c" -Ee "s/Intel Core i7 9xx \(Nehalem Class Core i7\)/${cpu_models[$nehalem-1]}/"
sed -i "$file_cpu_c" -Ee "/        .name = \"Nehalem\",/a\        .t4_upgrade = 0x${cpu_sockets[$nehalem-1]},\n\
        .t4_family = 0x${cpu_families[$nehalem-1]},"
sed -i "$file_cpu_c" -Ee "s/Intel Core i7 9xx \(Nehalem Core i7, IBRS update\)/${cpu_models[$nehalem-1]}/"
sandybridge=$(shuf -i 10-22 -n 1)
echo "        .name = \"SandyBridge\","
echo ".stepping = 1,                                    -> .stepping = ${cpu_steppings[$sandybridge-1]},"
echo "Intel Xeon E312xx (Sandy Bridge)                  -> ${cpu_models[$sandybridge-1]}"
sed -i "$file_cpu_c" -Ee "/        .name = \"SandyBridge\",/{ n;n;n;n;n; s/.stepping = 1,/.stepping = ${cpu_steppings[$sandybridge-1]},/ }"
sed -i "$file_cpu_c" -Ee "s/Intel Xeon E312xx \(Sandy Bridge\)/${cpu_models[$sandybridge-1]}/"
sed -i "$file_cpu_c" -Ee "/        .name = \"SandyBridge\",/a\        .t4_upgrade = 0x${cpu_sockets[$sandybridge-1]},\n\
        .t4_family = 0x${cpu_families[$sandybridge-1]},"
sed -i "$file_cpu_c" -Ee "s/Intel Xeon E312xx \(Sandy Bridge, IBRS update\)/${cpu_models[$sandybridge-1]}/"
haswell=$(shuf -i 23-38 -n 1)
echo "        .name = \"Westmere\","
echo ".model = 44,                                      -> .model = 60,"
echo ".stepping = 1,                                    -> .stepping = ${cpu_steppings[$haswell-1]},"
echo "Westmere E56xx/L56xx/X56xx (Nehalem-C)            -> ${cpu_models[$haswell-1]}"
sed -i "$file_cpu_c" -Ee "/        .name = \"Westmere\",/{ n;n;n;n; s/.model = 44,/.model = 60,/ }"
sed -i "$file_cpu_c" -Ee "/        .name = \"Westmere\",/{ n;n;n;n;n; s/.stepping = 1,/.stepping = ${cpu_steppings[$haswell-1]},/ }"
sed -i "$file_cpu_c" -Ee "s/Westmere E56xx\/L56xx\/X56xx \(Nehalem-C\)/${cpu_models[$haswell-1]}/"
sed -i "$file_cpu_c" -Ee "/        .name = \"Westmere\",/a\        .t4_upgrade = 0x${cpu_sockets[$haswell-1]},\n\
        .t4_family = 0x${cpu_families[$haswell-1]},"
sed -i "$file_cpu_c" -Ee "s/Westmere E56xx\/L56xx\/X56xx \(IBRS update\)/${cpu_models[$haswell-1]}/"
#coffeelake=$(shuf -i 39-44 -n 1)
coffeelake=$(shuf -i 45-47 -n 1)
echo "        .name = \"IvyBridge\","
#echo ".model = 58,                                      -> .model = 158,"
echo ".model = 58,                                      -> .model = 142,"
echo ".stepping = 9,                                    -> .stepping = ${cpu_steppings[$coffeelake-1]},"
echo "Intel Xeon E3-12xx v2 (Ivy Bridge)                -> ${cpu_models[$coffeelake-1]}"
#sed -i "$file_cpu_c" -Ee "/        .name = \"IvyBridge\",/{ n;n;n;n; s/.model = 58,/.model = 158,/ }"
sed -i "$file_cpu_c" -Ee "/        .name = \"IvyBridge\",/{ n;n;n;n; s/.model = 58,/.model = 142,/ }"
sed -i "$file_cpu_c" -Ee "/        .name = \"IvyBridge\",/{ n;n;n;n;n; s/.stepping = 9,/.stepping = ${cpu_steppings[$coffeelake-1]},/ }"
sed -i "$file_cpu_c" -Ee "s/Intel Xeon E3-12xx v2 \(Ivy Bridge\)/${cpu_models[$coffeelake-1]}/"
sed -i "$file_cpu_c" -Ee "/        .name = \"IvyBridge\",/a\        .t4_upgrade = 0x${cpu_sockets[$coffeelake-1]},\n\
        .t4_family = 0x${cpu_families[$coffeelake-1]},"
sed -i "$file_cpu_c" -Ee "s/Intel Xeon E3-12xx v2 \(Ivy Bridge, IBRS\)/${cpu_models[$coffeelake-1]}/"
echo "    DEFINE_PROP_BOOL(\"kvm-pv-enforce-cpuid\", X86CPU, kvm_pv_enforce_cpuid,"
echo "    v v v v v v v v v v v v"
echo "                     true),"
sed -i "$file_cpu_c" -Ee "/    DEFINE_PROP_BOOL\(\"kvm-pv-enforce-cpuid\", X86CPU, kvm_pv_enforce_cpuid,/{n;d;}"
sed -i "$file_cpu_c" -Ee "/    DEFINE_PROP_BOOL\(\"kvm-pv-enforce-cpuid\", X86CPU, kvm_pv_enforce_cpuid,/a\                     true),"
echo "X86CPU, expose_kvm, true),                        -> X86CPU, expose_kvm, false),"
sed -i "$file_cpu_c" -Ee "s/X86CPU, expose_kvm, true\),/X86CPU, expose_kvm, false),/"

echo "  $file_cpu_h"
echo "MCE_BANKS_DEF   10                                -> MCE_BANKS_DEF   32"
sed -i "$file_cpu_h" -Ee "s/MCE_BANKS_DEF   10/MCE_BANKS_DEF   32/"

echo "  $file_kvm_c"
echo "\"Microsoft VS\"                                    -> 0"
sed -i "$file_kvm_c" -Ee "s/\"Microsoft VS\"/\"\\\\0\\\\0\\\\0\\\\0\\\\0\\\\0\\\\0\\\\0\\\\0\\\\0\\\\0\\\\0\"/"
echo "\"VS#1\0\0\0\0\0\0\0\0\"                            -> 0"
sed -i "$file_kvm_c" -Ee "s/\"VS#1\\\\0\\\\0\\\\0\\\\0\\\\0\\\\0\\\\0\\\\0\"/\"\\\\0\\\\0\\\\0\\\\0\\\\0\\\\0\\\\0\\\\0\\\\0\\\\0\\\\0\\\\0\"/"
echo "\"XenVMMXenVMM\"                                    -> 0"
sed -i "$file_kvm_c" -Ee "s/\"XenVMMXenVMM\"/\"\\\\0\\\\0\\\\0\\\\0\\\\0\\\\0\\\\0\\\\0\\\\0\\\\0\\\\0\\\\0\"/"
if [[ "${cpu_vendor:1}" == "AuthenticAMD" ]]; then
  echo "KVMKVMKVM\0\0\0                                   -> AuthenticAMD"
  sed -i "$file_kvm_c" -Ee "s/KVMKVMKVM\\\\0\\\\0\\\\0/AuthenticAMD/"
else
  echo "KVMKVMKVM\0\0\0                                   -> GenuineIntel"
  sed -i "$file_kvm_c" -Ee "s/KVMKVMKVM\\\\0\\\\0\\\\0/GenuineIntel/"
fi

echo "  $file_kvmcpu_c"
echo "\"kvmclock\", \"on\"                                  -> \"kvmclock\", \"off\""
echo "\"kvm-nopiodelay\", \"on\"                            -> \"kvm-nopiodelay\", \"off\""
echo "\"kvm-asyncpf\", \"on\"                               -> \"kvm-asyncpf\", \"off\""
echo "\"kvm-steal-time\", \"on\"                            -> \"kvm-steal-time\", \"off\""
echo "\"kvm-pv-eoi\", \"on\"                                -> \"kvm-pv-eoi\", \"off\""
echo "\"kvmclock-stable-bit\", \"on\"                       -> \"kvmclock-stable-bit\", \"off\""
sed -i "$file_kvmcpu_c" -Ee "s/\"kvmclock\", \"on\"/\"kvmclock\", \"off\"/"
sed -i "$file_kvmcpu_c" -Ee "s/\"kvm-nopiodelay\", \"on\"/\"kvm-nopiodelay\", \"off\"/"
sed -i "$file_kvmcpu_c" -Ee "s/\"kvm-asyncpf\", \"on\"/\"kvm-asyncpf\", \"off\"/"
sed -i "$file_kvmcpu_c" -Ee "s/\"kvm-steal-time\", \"on\"/\"kvm-steal-time\", \"off\"/"
sed -i "$file_kvmcpu_c" -Ee "s/\"kvm-pv-eoi\", \"on\"/\"kvm-pv-eoi\", \"off\"/"
sed -i "$file_kvmcpu_c" -Ee "s/\"kvmclock-stable-bit\", \"on\"/\"kvmclock-stable-bit\", \"off\"/"

echo "  $file_acpicommon_c"
echo "#define MAX_HOST_VCPUS 256"
echo "static apic_id_t apicid_map[MAX_HOST_VCPUS];"
echo "static bool apicid_map_init = false;"
echo "static inline void init_apicid_map(void)"
echo "{"
echo "    if (apicid_map_init) return;"
echo "    cpu_set_t orig_mask;"
echo "    long max_cpus = sysconf(_SC_NPROCESSORS_CONF);"
echo "    int fallback = 0;"
echo "    if (sched_getaffinity(0, sizeof(cpu_set_t), &orig_mask) != 0 || max_cpus <= 0 || max_cpus > MAX_HOST_VCPUS) fallback = 2;"
echo "    if (fallback == 0) for (int i = 0; i < max_cpus; i++) {"
echo "        cpu_set_t target_mask;"
echo "        CPU_ZERO(&target_mask);"
echo "        CPU_SET(i, &target_mask);"
echo "        if (sched_setaffinity(0, sizeof(cpu_set_t), &target_mask) != 0) { fallback = 1; break; }"
echo "        else {"
echo "            unsigned eax, ebx, ecx, edx;"
echo "            asm volatile(\"cpuid\""
echo "            : \"=a\"(eax), \"=b\"(ebx), \"=c\"(ecx), \"=d\"(edx)"
echo "            : \"a\"(1)"
echo "            );"
echo "            apicid_map[i] = (apic_id_t)((ebx >> 24) & 0xFF);"
echo "        }"
echo "    }"
echo "    if (fallback >= 1) for (int i = 0; i < MAX_HOST_VCPUS; i++) apicid_map[i] = (apic_id_t)i;"
echo "    if (fallback <= 1) sched_setaffinity(0, sizeof(cpu_set_t), &orig_mask);"
echo "    apicid_map_init = true;"
echo "}"
echo "^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^"
echo "void pc_madt_cpu_entry(int uid, const CPUArchIdList *apic_ids,"
if [[ "${cpu_vendor:1}" == "CyrixInstead" ]]; then
  sed -i "$file_acpicommon_c" -Ee "/void pc_madt_cpu_entry\(int uid, const CPUArchIdList \*apic_ids,/i\#define MAX_HOST_VCPUS 256\n\
static apic_id_t apicid_map[MAX_HOST_VCPUS];\n\
static bool apicid_map_init = false;\n\
static inline void init_apicid_map(void)\n\
{\n\
    if (apicid_map_init) return;\n\
    cpu_set_t orig_mask;\n\
    long max_cpus = sysconf(_SC_NPROCESSORS_CONF);\n\
    int fallback = 0;\n\
    if (sched_getaffinity(0, sizeof(cpu_set_t), &orig_mask) != 0 || max_cpus <= 0 || max_cpus > MAX_HOST_VCPUS) fallback = 2;\n\
    if (fallback == 0) for (int i = 0; i < max_cpus; i++) {\n\
        cpu_set_t target_mask;\n\
        CPU_ZERO(&target_mask);\n\
        CPU_SET(i, &target_mask);\n\
        if (sched_setaffinity(0, sizeof(cpu_set_t), &target_mask) != 0) { fallback = 1; break; }\n\
        else {\n\
            unsigned eax, ebx, ecx, edx;\n\
            asm volatile(\"cpuid\"\n\
            : \"=a\"(eax), \"=b\"(ebx), \"=c\"(ecx), \"=d\"(edx)\n\
            : \"a\"(1)\n\
            );\n\
            apicid_map[i] = (apic_id_t)((ebx >> 24) & 0xFF);\n\
        }\n\
    }\n\
    if (fallback >= 1) for (int i = 0; i < MAX_HOST_VCPUS; i++) apicid_map[i] = (apic_id_t)i;\n\
    if (fallback <= 1) sched_setaffinity(0, sizeof(cpu_set_t), &orig_mask);\n\
    apicid_map_init = true;\n\
}\n"
fi
echo "    uint32_t apic_id = apic_ids->cpus[uid].arch_id;"
echo "    v v v v v v v v v v v v v v v v v v v v v v v v"
echo "    init_apicid_map();"
echo "    apic_id = apicid_map[uid];"
if [[ "${cpu_vendor:1}" == "CyrixInstead" ]]; then
  sed -i "$file_acpicommon_c" -Ee "/    uint32_t apic_id = apic_ids->cpus\[uid\].arch_id;/a\    init_apicid_map();\n\
    apic_id = apicid_map[uid];"
fi

echo "  $file_topology_h"
echo "    uint32_t eax, ebx, ecx, edx;"
echo "    asm volatile(\"cpuid\""
echo "    : \"=a\"(eax), \"=b\"(ebx), \"=c\"(ecx), \"=d\"(edx)"
echo "    : \"a\"(0x0B), \"c\"(0x00)"
echo "    : \"memory\""
echo "    );"
echo "    return eax & 0x1F;"
echo "    ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^"
echo "    return apicid_bitwidth_for_count(topo_info->threads_per_core);"
if [[ "${cpu_vendor:1}" == "CyrixInstead" ]]; then
  sed -i "$file_topology_h" -Ee "/    return apicid_bitwidth_for_count\(topo_info->threads_per_core\);/i\    uint32_t eax, ebx, ecx, edx;\n\
    asm volatile(\"cpuid\"\n\
    : \"=a\"(eax), \"=b\"(ebx), \"=c\"(ecx), \"=d\"(edx)\n\
    : \"a\"(0x0B), \"c\"(0x00)\n\
    : \"memory\"\n\
    );\n\
    return eax & 0x1F;"
fi

design_capacity=$((RANDOM % 20000 + 41000))
design_voltage=$((RANDOM % 300 + 12500))
random=$(shuf -i 1-3 -n 1)
if [[ "$random" == "1" ]]; then
  oem_information="Celxpert"
else
  if [[ "$random" == "2" ]]; then
    oem_information="Simplo"
  else
    oem_information="Sunwoda"
  fi
fi
random=$(shuf -i 1-5 -n 1)
if [[ "$chassis_type" != "Desktop" ]]; then
  echo "  $file_ssdt1"
  echo "        Device (BAT0)"
  echo "        ^ ^ ^ ^ ^ ^ ^"
  echo "        Device (EC0)"
  sed -i "$file_ssdt1" -Ee "/        Device \(EC0\)/i\        Device (BAT0)\n\
        {\n\
            Name (_HID, EisaId (\"PNP0C0A\"))\n\
            Name (_UID, One)\n\
            Method (_STA, 0, NotSerialized)\n\
            {\n\
                Return (0x1F)\n\
            }\n\
\n\
            Method (_BIF, 0, NotSerialized)\n\
            {\n\
                Return (Package (0x0D)\n\
                {\n\
                    Zero,    // 0=mWh 1=mAh\n\
                    0x$( printf '%X' $design_capacity ),  // $design_capacity mWh Design Capacity\n\
                    0x$( printf '%X' $((design_capacity * (95 - random)/100)) ),  // $((design_capacity * (95 - random)/100)) mWh Last Full Charge Capacity\n\
                    One,     // 1=Rechargeable\n\
                    0x$( printf '%X' $design_voltage ),  // $design_voltage mV Design Voltage\n\
                    0x$( printf '%X' $((design_capacity / 10)) ),  // $((design_capacity / 10)) mWh Design Capacity Warning\n\
                    0x$( printf '%X' $((design_capacity / 20)) ),   // $((design_capacity / 20)) mWh Design Capacity Low\n\
                    0x$( printf '%X' $((design_capacity / 1000)) ),    // $((design_capacity / 1000)) mWh Battery Capacity Granularity 1\n\
                    0x$( printf '%X' $((design_capacity / 1000)) ),    // $((design_capacity / 1000)) mWh Battery Capacity Granularity 2\n\
                    \"Primary\",\n\
                    \"SerialNumber\",\n\
                    \"LION\",  // Battery Type\n\
                    \"$oem_information\"\n\
                })\n\
            }\n\
\n\
            Method (_BST, 0, NotSerialized)\n\
            {\n\
                Return (Package (0x04)\n\
                {\n\
                    Zero,\n\
                    Zero,\n\
                    0x$( printf '%X' $((design_capacity * (95 - random)/100)) ),  // $((design_capacity * (95 - random)/100)) mWh Battery Remaining Capacity\n\
                    0x$( printf '%X' $((design_voltage * (100 - random)/100)) )   // $((design_voltage * (100 - random)/100)) mV Battery Present Voltage\n\
                })\n\
            }\n\
        }  // end of BAT0 device\n"
fi

read -p $'Continue? [y/\e[1mN\e[0m]> ' -n 1 -r
if [[ $REPLY =~ ^[Yy]$ ]]; then
  echo ""
else
  echo ""
  exit 0
fi


cd qemu
./configure --target-list=x86_64-softmmu
cd build
make -j
iasl "$file_ssdt1"
iasl "$file_ssdt2"

sudo cp -f "$(pwd)/qemu-system-x86_64" "$QEMU_DEST"
sudo cp -f "$(pwd)/../ssdt1.aml" "$QEMU_DEST"
sudo cp -f "$(pwd)/../ssdt2.aml" "$QEMU_DEST"
echo "$QEMU_DEST/qemu-system-x86_64"
echo "$QEMU_DEST/ssdt1.aml"
echo "$QEMU_DEST/ssdt2.aml"

sudo mkdir -p /usr/local/share/qemu
#sudo cp -f "$(pwd)/../pc-bios/kvmvapic.bin" "/usr/local/share/qemu/kvmvapic.bin"
#sudo cp -f "$(pwd)/../pc-bios/efi-e1000e.rom" "/usr/local/share/qemu/efi-e1000e.rom"
#sudo cp -f "$(pwd)/../pc-bios/vgabios-stdvga.bin" "/usr/local/share/qemu/vgabios-stdvga.bin"
#sudo cp -f "$(pwd)/../pc-bios/vgabios-qxl.bin" "/usr/local/share/qemu/vgabios-qxl.bin"
sudo cp -fr "$(pwd)/../pc-bios/." "/usr/local/share/qemu"
