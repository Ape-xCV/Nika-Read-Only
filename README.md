# Nika Read Only

- Apex Legends external cheat for Linux.

- As of Season 23, for QEMU/KVM (formerly for Proton).

```shell
+----------+    +----------+    +------------+    +--------------+
| Linux PC | -> | QEMU/KVM | -> | Windows VM | -> | Apex Legends |
+----------+    +----------+    +------------+    +--------------+
```

## Introduction

- The goal of this project is to have a working Linux cheat that can run alongside Apex Legends on my i5-6600K 4c/4t Linux PC.

![Screenshot.jpg](Screenshot.jpg)

## Features

* [x] Stable CR3 shuffle for [Windows 10 20H1](https://archive.org/details/win-10-2004-english-x-64_202010)
* [x] Overlay based ESP for players and items
* [x] Press 5 / 6 / 7 / 8 / 9 / 0 to cycle LIGHT / ENERGY / SHOTGUN / HEAVY / SNIPER / GEAR items
* [x] Map radar
* [x] Spectators list
* [x] Humanized aimbot
* [x] Inside FOV circle, hold RMB (Right Mouse Button) to aimbot **skynade** (even behind cover)
* [x] Hold SHIFT to **lock on target** or **show item names**
* [x] Toggle **aimbot** strength with CURSOR_LEFT; "**<**" symbol in the upper left corner of the screen
* [x] Toggle **ADS locking** with CURSOR_RIGHT; "**>**" symbol in the upper left corner of the screen
* [x] Disable/enable **triggerbot** auto fire with CURSOR_UP; "**^**" symbol in the upper left corner of the screen
- **Bind X in-game to fire, triggerbot will use that key** (default AIMBOT_FIRING_KEY)
- **Unbind LMB (Left Mouse Button) in-game from fire, so that the cheat will fire for you instead** (AIMBOT_ACTIVATED_BY_MOUSE default YES)
* [x] Toggle hitbox with CURSOR_DOWN; `body`/`neck`/`head` text in the upper left corner of the screen
* [ ] Hold CAPS_LOCK to **superglide**
* [x] Press F8 to dump **r5apex** and scan for offsets
* [x] Press F9 twice to terminate cheat

### 1. Environment set up in Linux

- Enter BIOS and enable Virtualization Technology:
  - VT-d for Intel (VMX)
  - AMD-Vi for AMD (SVM)
  - Enable "IOMMU"
  - Disable "Above 4G Decoding"

- Nested Virtualization for Intel:
```shell
sudo su
echo "options kvm_intel nested=0" > /etc/modprobe.d/kvm.conf
```

- Nested Virtualization for AMD:
```shell
sudo su
echo "options kvm_amd nested=0" > /etc/modprobe.d/kvm.conf
```

- Preload `vfio-pci` module so it can bind to PCI IDs:
```shell
sudo su
echo "softdep nvidia pre: vfio-pci" >> /etc/modprobe.d/kvm.conf
echo "softdep nouveau pre: vfio-pci" >> /etc/modprobe.d/kvm.conf
```

- Update initramfs:
```shell
<Fedora> sudo dracut --force
<Debian> sudo update-initramfs -c -k $(uname -r)
```


  <details>
    <summary>Install on <b>Fedora Linux (Fedora 42 KDE)</b>:</summary>

    sudo dnf install @virtualization
  </details>

  
  <details>
    <summary>Install on <b>Debian Linux (Debian 12 KDE)</b>:</summary>

    sudo apt-get update
    sudo apt install virt-manager
  </details>

### 1.1. Configure libvirt

- Edit `/etc/libvirt/qemu.conf` and uncomment (needed for **audio**):
```shell
#user = "libvirt-qemu"
user = "1000"
```

- Edit `/etc/libvirt/libvirtd.conf` and uncomment:
```shell
unix_sock_group = "libvirt"
unix_sock_rw_perms = "0770"
```

- Join **libvirt group** and enable **libvirt daemon**:
```shell
test $UID = 0 && exit
sudo usermod -aG libvirt $USER
sudo systemctl enable libvirtd.service
```

- Restart Linux PC.

- Start default virtual network:
```shell
sudo virsh net-autostart default
sudo virsh net-start default
```

- **Enable XML editing** in Virtual Machine Manager >> Edit >> Preferences >> General

### 2. New VM set up in QEMU/KVM

- Virtual Machine Manager >> File >> New Virtual Machine

- Local install media (ISO image or CDROM) >> `Windows10.iso` >> Choose Memory and CPU settings >> **Disable** storage for this virtual machine >> Customize configuration before install
  - Overview >> Chipset: Q35, **Firmware**: OVMF_CODE_4M.secboot >> [Apply]
  - [Add Hardware] >> Storage >> Device type: Disk device >> Bus type: SATA >> Create a disk image for the virtual machine: 120, 160, or 240 GiB >> Advanced options >> Serial: B4NN3D53R14L >> [Finish]
  - [Begin Installation] >> Virtual Machine >> Shut Down >> Force Off

- Virtual Machine Manager >> [Open] >> View >> Details >> Video QXL >> Model: VGA >> [Apply]

- Virtual Machine Manager >> [Open] >> View >> Details >> NIC :xx:xx:xx >> XML


- Replace `<mac address="52:54:00:xx:xx:xx"/>` and [Apply]:
  <details>
    <summary>Spoiler</summary>

  ```shell
  <mac address="xx:xx:xx:xx:xx:xx"/>
  ```
  </details>

- Virtual Machine Manager >> [Open] >> View >> Details >> SATA Disk 1 >> XML


- Replace `<driver name="qemu" type="raw"/>` and [Apply]:
  <details>
    <summary>Spoiler</summary>

  ```shell
  <driver name="qemu" type="raw" cache="none" discard="ignore"/>
  ```
  </details>

### 2.1 Configure VM

- Virtual Machine Manager >> [Open] >> View >> Details >> Overview >> XML


- Replace `<domain type="kvm">` and [Apply]:
  <details>
    <summary>Spoiler <b>(do NOT use this example, instead modify it with your own SMBIOS data; sudo dmidecode)</b></summary>

  ```shell
  <domain type="kvm" xmlns:qemu="http://libvirt.org/schemas/domain/qemu/1.0">
    <qemu:commandline>
      <qemu:arg value="-smbios"/>
      <qemu:arg value="type=0,vendor=ASUS,version=X.23,date=06/14/2024,release=12.34"/>
      <qemu:arg value="-smbios"/>
      <qemu:arg value="type=1,manufacturer=ASUS,product=ASUS Zenbook 14X UM5401,version=23.41,serial=D3E4F56789"/>
      <qemu:arg value="-smbios"/>
      <qemu:arg value="type=2,manufacturer=ASUS,product=87FD,version=34.12,serial=B1C2D3E4F56789"/>
      <qemu:arg value="-smbios"/>
      <qemu:arg value="type=3,manufacturer=ASUS,version=23.41,serial=D3E4F56789"/>
      <qemu:arg value="-smbios"/>
      <qemu:arg value="type=17,manufacturer=Samsung,loc_pfx=BANK,speed=4800,serial=E4F56789"/>
      <qemu:arg value="-smbios"/>
      <qemu:arg value="type=4,manufacturer=Advanced Micro Devices,, Inc.,version=AMD Ryzen 9 6900HX with Radeon Graphics,max-speed=4900,current-speed=3300"/>
    </qemu:commandline>
  ```
  </details>


- Replace `</metadata>` and [Apply]:
  <details>
    <summary>Spoiler</summary>

  ```shell
    <vmware xmlns="http://www.vmware.com/schema/vmware.config">
      <config>
        <entry name="hypervisor.cpuid.v0" value="FALSE"/>
      </config>
    </vmware>
  </metadata>
  ```
  </details>


- Replace from `<memory unit="KiB">4194304</memory>` to `<vcpu placement="static">2</vcpu>` and [Apply]:
  <details>
    <summary>Spoiler <b>(use a commercial module size like 12, 16, or 24 GiB; vcpu example for a 24 threads host CPU)</b></summary>

  ```shell
  <memory unit="GiB">12</memory>
  <currentMemory unit="GiB">12</currentMemory>
  <vcpu placement="static">24</vcpu>
  ```
  </details>


- Replace from `<features>` to `</clock>` and [Apply]:
  <details>
    <summary>Spoiler <b>(example for a 12 cores, 24 threads host CPU; any mismatch will be detected)</b></summary>

  ```shell
  <features>
    <acpi/>
    <apic/>
    <hyperv mode="custom">
      <relaxed state="off"/>
      <vapic state="off"/>
      <spinlocks state="off"/>
      <vpindex state="off"/>
      <runtime state="off"/>
      <synic state="off"/>
      <stimer state="off"/>
      <reset state="off"/>
      <vendor_id state="off"/>
      <frequencies state="off"/>
      <reenlightenment state="off"/>
      <tlbflush state="off"/>
      <ipi state="off"/>
      <evmcs state="off"/>
      <avic state="off"/>
    </hyperv>
    <kvm>
      <hidden state="on"/>
    </kvm>
    <pmu state="on"/>
    <vmport state="off"/>
    <smm state="on"/>
    <ioapic driver="kvm"/>
    <msrs unknown="fault"/>
  </features>
  <cpu mode="host-passthrough" check="none" migratable="off">
    <topology sockets="1" cores="12" threads="2"/>
    <cache mode="passthrough"/>
    <feature policy="disable" name="hypervisor"/>
    <feature policy="require" name="svm"/>
    <feature policy="require" name="vmx"/>
    <feature policy="disable" name="aes"/>
    <feature policy="disable" name="x2apic"/>
    <feature policy="require" name="topoext"/>
    <feature policy="require" name="invtsc"/>
    <feature policy="disable" name="amd-ssbd"/>
    <feature policy="disable" name="ssbd"/>
    <feature policy="disable" name="virt-ssbd"/>
    <feature policy="disable" name="rdpid"/>
    <feature policy="disable" name="rdtscp"/>
  </cpu>
  <clock offset="localtime">
    <timer name="tsc" present="yes" tickpolicy="discard" mode="native"/>
    <timer name="hpet" present="yes"/>
    <timer name="rtc" present="no"/>
    <timer name="pit" present="no"/>
    <timer name="kvmclock" present="no"/>
    <timer name="hypervclock" present="no"/>
  </clock>
  ```
  </details>


- Replace from `<memballoon model="virtio">` to `</memballoon>` and [Apply]:
  <details>
    <summary>Spoiler</summary>

  ```shell
  <memballoon model="none"/>
  ```
  </details>


- Replace `<audio id="1" type="spice"/>` and [Apply]:
  <details>
    <summary>Spoiler <b>(for pipewire sound, not required)</b></summary>

  ```shell
  <audio id="1" type="pipewire" runtimeDir="/run/user/1000">
    <input name="qemuinput"/>
    <output name="qemuoutput"/>
  </audio>
  ```
  </details>

- Virtual Machine Manager >> [Open] >> View >> Details >> Channel (spice) >> [Remove]

- Virtual Machine Manager >> [Open] >> View >> Details >> Controller VirtIO Serial 0 >> [Remove]

### 2.2 Install Windows

- Virtual Machine Manager >> [Open] >> View >> Details >> Boot Options >> Boot device order:
  * [x] SATA Disk 1 >> [Apply]

### 3. VFIO GPU passthrough (on Linux PC)

- Find GPU location with: `lspci -v | grep -i VGA`
```shell
00:02.0 VGA compatible controller: Intel Corporation HD Graphics 530 (rev 06) (prog-if 00 [VGA controller])
02:00.0 VGA compatible controller: NVIDIA Corporation TU106 [GeForce RTX 2070] (rev a1) (prog-if 00 [VGA controller])
```

- GeForce RTX 2070 has 4 PCI IDs: `lspci -v | grep -i NVIDIA`
```shell
02:00.0 VGA compatible controller: NVIDIA Corporation TU106 [GeForce RTX 2070] (rev a1) (prog-if 00 [VGA controller])
        Subsystem: NVIDIA Corporation TU106 [GeForce RTX 2070]
02:00.1 Audio device: NVIDIA Corporation TU106 High Definition Audio Controller (rev a1)
        Subsystem: NVIDIA Corporation Device 1f02
02:00.2 USB controller: NVIDIA Corporation TU106 USB 3.1 Host Controller (rev a1) (prog-if 30 [XHCI])
        Subsystem: NVIDIA Corporation Device 1f02
02:00.3 Serial bus controller: NVIDIA Corporation TU106 USB Type-C UCSI Controller (rev a1)
        Subsystem: NVIDIA Corporation Device 1f02
```

- Find PCI IDs with: `lspci -n -s 02:00`
```shell
02:00.0 0300: 10de:1f02 (rev a1)
02:00.1 0403: 10de:10f9 (rev a1)
02:00.2 0c03: 10de:1ada (rev a1)
02:00.3 0c80: 10de:1adb (rev a1)
```

- Edit `/etc/default/grub`, use either **intel_iommu=on** or **amd_iommu=on**:
```shell
GRUB_CMDLINE_LINUX="module_blacklist=nvidia,nouveau vfio-pci.ids=10de:1f02,10de:10f9,10de:1ada,10de:1adb intel_iommu=on iommu=pt"
```

- Update GRUB and restart Linux PC:
```shell
<Fedora> sudo grub2-mkconfig -o /boot/grub2/grub.cfg
<Debian> sudo grub-mkconfig -o /boot/grub/grub.cfg
```

- Inspect IOMMU enabled with:
```shell
if compgen -G "/sys/kernel/iommu_groups/*/devices/*" > /dev/null; then echo "IOMMU enabled."; fi
```

- Inspect kernel driver in use with: `lspci -k -s 02:00`
```lua
02:00.0 VGA compatible controller: NVIDIA Corporation TU106 [GeForce RTX 2070] (rev a1)
        Subsystem: NVIDIA Corporation TU106 [GeForce RTX 2070]
        Kernel driver in use: vfio-pci
        Kernel modules: nouveau
02:00.1 Audio device: NVIDIA Corporation TU106 High Definition Audio Controller (rev a1)
        Subsystem: NVIDIA Corporation Device 1f02
        Kernel driver in use: vfio-pci
        Kernel modules: snd_hda_intel
02:00.2 USB controller: NVIDIA Corporation TU106 USB 3.1 Host Controller (rev a1)
        Subsystem: NVIDIA Corporation Device 1f02
        Kernel driver in use: xhci_hcd
02:00.3 Serial bus controller: NVIDIA Corporation TU106 USB Type-C UCSI Controller (rev a1)
        Subsystem: NVIDIA Corporation Device 1f02
        Kernel driver in use: vfio-pci
        Kernel modules: i2c_nvidia_gpu
```

- Not loaded as a module, `xhci_hcd` will be managed by libvirt.

### 3.1 Add passthrough GPU devices to Windows VM

- Virtual Machine Manager >> [Open] >> View >> Details >> [Add Hardware] >> PCI Host Device:
  - 02:00.0 NVIDIA Corporation TU106 [GeForce RTX 2070] >> **[Finish]**
  - 02:00.1 NVIDIA Corporation TU106 High Definition Audio Controller >> **[Finish]**
  - 02:00.2 NVIDIA Corporation TU106 USB 3.1 Host Controller >> **[Finish]**
  - 02:00.3 NVIDIA Corporation TU106 USB Type-C UCSI Controller >> **[Finish]**

- Install GPU drivers on Windows VM.

### 4. Configure evdev passthrough (on Linux PC)

- Find your **mouse** and **keyboard** with:
```shell
ls -l /dev/input/by-id/

usb-COMPANY_USB_Device-event-if02 -> ../event7
usb-COMPANY_USB_Device-event-kbd -> ../event4
usb-COMPANY_USB_Device-if01-event-mouse -> ../event5
usb-COMPANY_USB_Device-if01-mouse -> ../mouse0
usb-COMPANY_USB_Device-if02-event-kbd -> ../event6
usb-SONiX_USB_DEVICE-event-if01 -> ../event9
usb-SONiX_USB_DEVICE-event-kbd -> ../event8
```

- By symlink `../mouse0` you find that `usb-COMPANY_USB_Device` is your **mouse**.

- You are looking for `event-mouse` and `event-kbd`:
  - `usb-COMPANY_USB_Device-if01-event-mouse -> ../event5` is your **mouse**.
  - `usb-SONiX_USB_DEVICE-event-kbd -> ../event8` is your **keyboard**.

- Edit `/etc/libvirt/qemu.conf` and uncomment:
```shell
cgroup_device_acl = [
        "/dev/null", "/dev/full", "/dev/zero",
        "/dev/random", "/dev/urandom",
        "/dev/ptmx", "/dev/kvm", "/dev/kqemu",
        "/dev/rtc", "/dev/hpet",
        "/dev/input/by-id/usb-COMPANY_USB_Device-if01-event-mouse",
        "/dev/input/by-id/usb-SONiX_USB_DEVICE-event-kbd",
        "/dev/input/event5",
        "/dev/input/event8",
        "/dev/userfaultfd"
]
```

- Include `cgroup_device_acl` as above, replacing `event-kbd`, `event-mouse`, and the path to each symlink `/dev/input/eventX`.

- Restart libvirtd:
```shell
sudo systemctl restart libvirtd
```

### 4.1 Configure VM

- Virtual Machine Manager >> [Open] >> View >> Details >> Overview >> XML


- Replace `</qemu:commandline>` and [Apply]:
  <details>
    <summary>Spoiler</summary>

  ```shell
    <qemu:arg value="-object"/>
    <qemu:arg value="input-linux,id=kbd1,evdev=/dev/input/by-id/usb-SONiX_USB_DEVICE-event-kbd,grab_all=on,repeat=on"/>
    <qemu:arg value="-object"/>
    <qemu:arg value="input-linux,id=mouse1,evdev=/dev/input/by-id/usb-COMPANY_USB_Device-if01-event-mouse"/>
  </qemu:commandline>
  ```
  </details>

- Join **input group**:
```shell
test $UID = 0 && exit
sudo usermod -aG input $USER
```


  <details>
    <summary>Manually stop `SELinux` every reboot on <b>Fedora Linux</b>:</summary>

    sudo setenforce 0
  </details>

  
  <details>
    <summary>Permanently disable `AppArmor` on <b>Debian Linux</b>:</summary>

    sudo systemctl stop apparmor
    sudo systemctl disable apparmor
  </details>

- Restart Linux PC.

### 5. Usage

- For **window settings**, open; System Settings >> Window Management >> Window Rules >> Import... >> GLFW.kwinrule
  - Also check; System Settings >> Display & Monitor >> Scale: 100%

- Virtual Machine Manager >> [Open] >> View >> Details >> Video VGA >> Model: None >> [Apply]

- You will be using video output from passthrough GPU instead of VGA virtual GPU.

| Method                       | Latency   | ESP          | Cons                         |
| ---------------------------- | --------- | ------------ | ---------------------------- |
| Cable                        | 0 ms      | Glow         | Overlay on 2nd monitor       |
| Capture card                 | 30-300 ms | Overlay+Glow | Investment for faster device |
| Steam Remote Play            | 10 ms     | Overlay+Glow | Encoded video                |

### 5.1 Cable

- Plug monitor into passthrough GPU.

### 5.2 Capture card

- Plug capture card into passthrough GPU.

- Open capture card raw feed with:
```shell
gst-launch-1.0 -v v4l2src device=/dev/video0 ! video/x-raw,width=1920,height=1080,framerate=60/1 ! videoconvert ! autovideosink
```

### 5.3 Steam Remote Play (if you can't connect)

- Virtual Machine Manager >> [Open] >> View >> Details >> NIC xx:xx:xx >> Network source: Bridge device... >> Device name: br0 >> [Apply]

- Find your active network interface with:
```shell
ip -br addr show

lo               UNKNOWN        127.0.0.1/8
eno1             DOWN           
wlp10s0f3u1      UP             172.16.0.100/24
```

- Manually configure `br0` every reboot:
```shell
sudo ip link add name br0 type bridge
sudo ip addr add 10.0.0.1/24 dev br0
sudo ip link set dev br0 up
sudo sysctl -w net.ipv4.ip_forward=1
sudo iptables --table nat --append POSTROUTING --out-interface wlp10s0f3u1 -j MASQUERADE
sudo iptables --insert FORWARD --in-interface br0 -j ACCEPT
```

- Windows VM static configuration (TCP/IPv4):
  - IP address: 10.0.0.100
  - Subnet mask: 255.255.255.0
  - Default gateway: 10.0.0.1
  - Preferred DNS server: 8.8.8.8
  - Alternate DNS server: 9.9.9.9

### 6. Nika Read Only (on Linux PC)

- Install:
```shell
cd path/to/extracted/repository
chmod +x nika
```

- Run:
```shell
cd path/to/extracted/repository
sudo -E ./nika
```

### 7. Spoof qemu-system-x86_64 (mandatory)

- This script is based on: [Scrut1ny/Hypervisor-Phantom](https://github.com/Scrut1ny/Hypervisor-Phantom)


  <details>
    <summary>Build on <b>Fedora Linux</b>:</summary>

  ```shell
  sudo dnf builddep qemu
  sudo dnf install acpica-tools
  ```
  </details>

- Run `qemupatch.sh` to clone, patch, and build `qemu-system-x86_64` with generated data.
  - You can edit `default_models` with real data.

- Virtual Machine Manager >> [Open] >> View >> Details >> Overview >> XML


- Replace `<devices>` and [Apply]:
  <details>
    <summary>Spoiler</summary>

  ```shell
  <pm>
    <suspend-to-mem enabled="yes"/>
    <suspend-to-disk enabled="no"/>
  </pm>
  <devices>
    <emulator>/usr/local/bin/qemu-system-x86_64</emulator>
  ```
  </details>


- Replace `</qemu:commandline>` and [Apply]:
  <details>
    <summary>Spoiler</summary>

  ```shell
    <qemu:arg value="-acpitable"/>
    <qemu:arg value="file=/usr/local/bin/ssdt1.aml"/>
    <qemu:arg value="-acpitable"/>
    <qemu:arg value="file=/usr/local/bin/ssdt2.aml"/>
  </qemu:commandline>
  ```
  </details>

### 7.1 Spoof OVMF (mandatory)

- This script is based on: [Scrut1ny/Hypervisor-Phantom](https://github.com/Scrut1ny/Hypervisor-Phantom)


  <details>
    <summary>Build on <b>Fedora Linux</b>:</summary>

  ```shell
  sudo dnf install nasm
  ```
  </details>

- Run `edk2atch.sh` to clone, patch, and build `OVMF` with generated data.

- Virtual Machine Manager >> [Open] >> View >> Details >> Overview >> XML


- Replace from `<os firmware="efi">` to `</os>` and [Apply]:
  <details>
    <summary>Spoiler</summary>

  ```shell
  <os>
    <type arch="x86_64" machine="pc-q35-9.2">hvm</type>
    <loader readonly="yes" secure="yes" type="pflash" format="raw">/usr/share/edk2/ovmf/OVMF_CODE_4M.patched.fd</loader>
    <nvram format="raw">/usr/share/edk2/ovmf/OVMF_VARS_4M.patched.fd</nvram>
    <bootmenu enable="yes"/>
  </os>
  ```
  </details>

### 8. memflow-kvm (faster VMREAD)


  <details>
    <summary>Install <b>dkms</b> on <b>Fedora Linux</b>:</summary>

    sudo dnf install kernel-devel-$(uname -r)
    sudo dnf install kernel-devel-matched-$(uname -r)
    sudo dnf install dkms
  </details>


  <details>
    <summary>Install <b>dkms</b> on <b>Debian Linux</b>:</summary>

    sudo apt install linux-headers-amd64=6.1.123-1
    sudo apt install dkms
  </details>

- Download `memflow-0.2.1-source-only.dkms.tar.gz` from:
https://github.com/memflow/memflow-kvm/releases

- Install:
```shell
sudo dkms install --archive=memflow-0.2.1-source-only.dkms.tar.gz
```

- Run:
```shell
sudo modprobe memflow
cd path/to/extracted/repository
sudo -E ./nika
```
