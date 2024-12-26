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

* [x] Press F8 to dump **r5apex** and scan for offsets
* [x] Overlay based ESP for players and items
* [x] Press INSERT / DELETE / HOME / END / PAGE_UP / PAGE_DOWN to cycle LIGHT / ENERGY / SHOTGUN / HEAVY / SNIPER / GEAR items
* [x] Map radar
* [x] Spectators list
* [x] Humanized aimbot
* [x] Hold SHIFT to **lock on target** and **triggerbot** auto fire
* [x] Increase/decrease **aimbot** strength with CURSOR_LEFT; "**<**" symbol in the upper left corner of the screen
* [x] Toggle **ADS locking** with CURSOR_RIGHT; "**>**" symbol in the upper left corner of the screen
* [ ] Disable/enable **triggerbot** auto fire with CURSOR_UP; "**^**" symbol in the upper left corner of the screen
- **Bind X in-game to fire, triggerbot will use that key** (default AIMBOT_FIRING_KEY)
- **Unbind LMB (Left Mouse Button) in-game from fire, so that the cheat will fire for you instead** (AIMBOT_ACTIVATED_BY_MOUSE default YES)
* [x] Toggle hitbox with CURSOR_DOWN; `body`/`neck`/`head` text in the upper left corner of the screen
* [ ] Hold CAPS_LOCK to **superglide**
* [x] Terminate cheat with F9

### 1. Environment set up in Linux

- Enter BIOS and enable Virtualization Technology:
  - VT-d for Intel
  - AMD-V for AMD


- Nested Virtualization for Intel:
```shell
sudo su
echo "options kvm_intel nested=1" >> /etc/modprobe.d/kvm.conf
```

- Nested Virtualization for AMD:
```shell
sudo su
echo "options kvm_amd nested=1" >> /etc/modprobe.d/kvm.conf
```

- Update initramfs:
```shell
sudo dracut --force
```


  <details>
    <summary>Install on <b>Arch Linux (EndeavourOS KDE)</b>:</summary>

    sudo pacman -S qemu-desktop
    sudo pacman -S virt-manager
  </details>

  <details>
    <summary>Install on <b>Fedora Linux (Fedora KDE)</b>:</summary>

    sudo dnf install @virtualization
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

- Download "Stable virtio-win ISO" from:
https://github.com/virtio-win/virtio-win-pkg-scripts/blob/master/README.md

### 2. New VM set up in QEMU/KVM

- Virtual Machine Manager >> File >> New Virtual Machine

- Local install media (ISO image or CDROM) >> `Windows10.iso` >> Choose Memory and CPU settings >> **Disable** storage for this virtual machine >> Customize configuration before install

  - Overview >> Chipset: Q35, **Firmware**: x64/OVMF_CODE.secboot.4m.fd >> Apply
  - Boot Options >> Boot device order: **Enable** boot menu >> Apply
  - [Add Hardware] >> Storage >> Device type: CDROM device >> Manage... `virtio-win.iso` >> [Finish]
  - [Add Hardware] >> Storage >> Device type: Disk device >> Bus type: VirtIO >> Create a disk image for the virtual machine: 140 GiB >> Advanced options >> Serial: A0B1C2D3E4F56789 >> [Finish]
  - [Begin Installation] >> Virtual Machine >> Shut Down >> Force Off

### 2.1 Configure VM

- Virtual Machine Manager >> [Open] >> View >> Details >> Overview >> XML

- Replace `<domain type="kvm">` and [Apply]:
  <details>
    <summary>Spoiler</summary>

  ```shell
  <domain type="kvm" xmlns:qemu="http://libvirt.org/schemas/domain/qemu/1.0">
    <qemu:commandline>
      <qemu:arg value="-smbios"/>
      <qemu:arg value="type=0,vendor=ASUS,version=X.23,date=06/14/2024,release=12.34"/>
      <qemu:arg value="-smbios"/>
      <qemu:arg value="type=1,manufacturer=ASUS,product=ASUS Zenbook 14X UX1337,version=23.41,serial=D3E4F56789"/>
      <qemu:arg value="-smbios"/>
      <qemu:arg value="type=2,manufacturer=ASUS,product=87FD,version=34.21,serial=B1C2D3E4F56789"/>
      <qemu:arg value="-smbios"/>
      <qemu:arg value="type=3,manufacturer=ASUS,version=23.41,serial=D3E4F56789"/>
      <qemu:arg value="-smbios"/>
      <qemu:arg value="type=17,manufacturer=Samsung,loc_pfx=BANK,speed=4800,serial=E4F56789"/>
      <qemu:arg value="-smbios"/>
      <qemu:arg value="type=4,manufacturer=Intel(R) Corporation,version=13th Gen Intel(R) Core(TM) i9-13900H @ 2.60GHz,max-speed=5400,current-speed=2600"/>
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
    <summary>Spoiler</summary>

  ```shell
  <memory unit="KiB">12582912</memory>
  <currentMemory unit="KiB">12582912</currentMemory>
  <vcpu placement="static">4</vcpu>
  ```
  </details>


- Replace from `<features>` to `</clock>` and [Apply]:
  <details>
    <summary>Spoiler</summary>

  ```shell
  <features>
    <acpi/>
    <apic/>
    <hyperv mode="passthrough">
      <relaxed state="on"/>
      <vapic state="on"/>
      <spinlocks state="on" retries="8191"/>
      <vpindex state="on"/>
      <synic state="on"/>
      <stimer state="on">
        <direct state="on"/>
      </stimer>
      <reset state="on"/>
      <vendor_id state="on" value="GenuineIntel"/>
      <frequencies state="on"/>
      <reenlightenment state="off"/>
      <tlbflush state="on"/>
      <ipi state="on"/>
      <evmcs state="off"/>
      <avic state="on"/>
    </hyperv>
    <kvm>
      <hidden state="on"/>
    </kvm>
    <vmport state="off"/>
    <smm state="on"/>
    <ioapic driver="kvm"/>
  </features>
  <cpu mode="host-passthrough" check="none" migratable="off">
    <topology sockets="1" dies="1" cores="4" threads="1"/>
    <cache mode="passthrough"/>
    <feature policy="require" name="hypervisor"/>
    <feature policy="disable" name="vmx"/>
    <feature policy="disable" name="svm"/>
    <feature policy="disable" name="aes"/>
    <feature policy="disable" name="x2apic"/>
    <feature policy="require" name="ibpb"/>
    <feature policy="require" name="invtsc"/>
    <feature policy="require" name="pdpe1gb"/>
    <feature policy="require" name="ssbd"/>
    <feature policy="require" name="amd-ssbd"/>
    <feature policy="require" name="stibp"/>
    <feature policy="require" name="amd-stibp"/>

    <feature policy="require" name="tsc-deadline"/>
    <feature policy="require" name="tsc_adjust"/>
    <feature policy="require" name="arch-capabilities"/>
    <feature policy="require" name="rdctl-no"/>
    <feature policy="require" name="skip-l1dfl-vmentry"/>
    <feature policy="require" name="mds-no"/>
    <feature policy="require" name="pschange-mc-no"/>

    <feature policy="require" name="cmp_legacy"/>
    <feature policy="require" name="xsaves"/>
    <feature policy="require" name="perfctr_core"/>
    <feature policy="require" name="clzero"/>
    <feature policy="require" name="xsaveerptr"/>
  </cpu>
  <clock offset="timezone" timezone="Europe/London">
    <timer name="rtc" present="no" tickpolicy="catchup"/>
    <timer name="pit" tickpolicy="discard"/>
    <timer name="hpet" present="no"/>
    <timer name="kvmclock" present="no"/>
    <timer name="hypervclock" present="yes"/>
    <timer name="tsc" present="yes" mode="native"/>
  </clock>
  ```
  </details>


- Replace `</devices>` and [Apply]:
  <details>
    <summary>Spoiler</summary>

  ```shell
    <shmem name="looking-glass">
      <model type="ivshmem-plain"/>
      <size unit="M">32</size>
    </shmem>
  </devices>
  ```
  </details>

### 2.2 Install Windows

- Where do you want to install Windows?
  - Load driver >> OK >> `E:\amd64\w10\viostor.inf`


- Virtual Machine Manager >> [Open] >> View >> Details >> Boot Options >> Boot device order:
  * [x] VirtIO Disk 1 >> [Apply]

### 3. VFIO GPU passthrough (on Linux PC)

- Find GPU location with: `lspci -v | grep VGA`
```shell
00:02.0 VGA compatible controller: Intel Corporation HD Graphics 530 (rev 06) (prog-if 00 [VGA controller])
02:00.0 VGA compatible controller: NVIDIA Corporation TU106 [GeForce RTX 2070] (rev a1) (prog-if 00 [VGA controller])
```

- GeForce RTX 2070 has 4 PCI IDs: `lspci -v | grep NVIDIA`
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
GRUB_CMDLINE_LINUX="module_blacklist=nvidia,nouveau vfio-pci.ids=10de:1f02,10de:10f9,10de:1ada,10de:1adb intel_iommu=on iommu=pt pcie_port_pm=off pcie_aspm.policy=performance"
```

- Update GRUB and restart Linux PC:
```shell
sudo grub-mkconfig -o /boot/grub/grub.cfg
sudo grub2-mkconfig -o /boot/grub2/grub.cfg
```

### 3.1 Fedora KDE extra isolation
- GPU on `02:00.0` is isolated. Find path for GPU on `00:02.0` with: `ls -l /dev/dri/by-path/ | grep 00:02.0-card`
```shell
lrwxrwxrwx. 1 root root  8 Dec 26 21:38 pci-0000:00:02.0-card -> ../card1
```

- Set KWIN to use GPU on `00:02.0` with:
```shell
sudo su
echo export KWIN_DRM_DEVICES=/dev/dri/card1 > /etc/profile.d/vfio-kwin.sh
```

- Restart Linux PC.

### 3.2 Add passthrough GPU devices to Windows VM

- Virtual Machine Manager >> [Open] >> View >> Details >> [Add Hardware] >> PCI Host Device:
  - 02:00.0 NVIDIA Corporation TU106 [GeForce RTX 2070] >> **[Finish]**
  - 02:00.1 NVIDIA Corporation TU106 High Definition Audio Controller >> **[Finish]**
  - 02:00.2 NVIDIA Corporation TU106 USB 3.1 Host Controller >> **[Finish]**
  - 02:00.3 NVIDIA Corporation TU106 USB Type-C UCSI Controller >> **[Finish]**


- Install GPU drivers on Windows VM.

### 4. Looking Glass B6 (on Windows VM)

- If your `Windows10.iso` is updated to poop level:
  - Search >> Reputation-based protection >> Check apps and files >> Off
- https://looking-glass.io/downloads >> Windows Host Binary
  - At least one GPU display port needs to be populated, shop online for HDMI Dummy Plug if needed.
  - Windows Host Binary will not start without it.

### 4.1 Looking Glass B6 (on Linux PC)

  <details>
    <summary>Install <u>dependencies</u> on <b>Arch Linux (EndeavourOS KDE)</b>:</summary>

    sudo pacman -S cmake
  </details>

  <details>
    <summary>Install <u>dependencies</u> on <b>Fedora Linux (Fedora KDE)</b>:</summary>

    sudo dnf install cmake g++ fontconfig-devel spice-protocol nettle-devel wayland-devel libxkbcommon-x11-devel libXi-devel libXScrnSaver-devel libXinerama-devel libXcursor-devel libXpresent-devel libglvnd-devel pipewire-devel pulseaudio-libs-devel libsamplerate-devel binutils-devel libXrandr-devel
  </details>

- https://looking-glass.io/downloads >> Source

- Build Looking Glass B6:
```shell
sudo pacman -S cmake
cd path/to/extracted/repository
cd client
mkdir build
cd build
cmake ..
make
```

- Virtual Machine Manager >> [Open] >> View >> Details >> Video QXL >> Model: None >> [Apply]

- Start your Windows VM and connect to it using Looking Glass B6:
```shell
cd path/to/extracted/repository
cd client/build
./looking-glass-client
```

### 5. Install Hyper-V (on Windows VM)

- Open a Command Prompt as Administrator:
```shell
DISM /Online /Enable-Feature /FeatureName:Microsoft-Hyper-V /All
```

### 6. Nika Read Only (on Linux PC)

- Install:
```shell
cd path/to/extracted/repository
chmod +x nika
```

- Run:
```shell
cd path/to/extracted/repository
sudo ./nika
```

### 7. memflow-kvm

- Download `memflow-0.2.1-source-only.dkms.tar.gz` from:
https://github.com/memflow/memflow-kvm/releases

- Install:
```shell
sudo dnf install dkms
sudo dnf install kernel-devel-$(uname -r)
sudo dkms install --archive=memflow-0.2.1-source-only.dkms.tar.gz
```

- Run:
```shell
sudo modprobe memflow
cd path/to/extracted/repository
sudo ./nika
```
