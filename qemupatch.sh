#!/usr/bin/env bash

if [ "$EUID" != 0 ]; then
    faillock --reset
    sudo -E "$0" "$@"
    exit $?
fi

QEMU_DEST="/usr/local/bin"

default_models=(
  "CT250MX500SSD1"                "KINGSTON SA400S37240G"
  "Crucial BX500 1TB 3D NAND SSD" "Crucial MX500 1TB 3D NAND SSD"
  "Kingston A400 SSD 1TB"         "Kingston HyperX Savage SSD 1TB"
  "Samsung SSD 970 EVO 1TB"       "Samsung SSD 860 QVO 1TB"
  "Samsung SSD 850 PRO 1TB"       "Samsung SSD 840 EVO 1TB"
  "SanDisk SSD PLUS 1TB"          "SanDisk Ultra 3D SSD 1TB"
  "Seagate BarraCuda 120 SSD 1TB" "Seagate IronWolf 110 SSD 1TB"
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
  local length=$1
  local random_string=""
  #local new_string=""
  local vowel_count=0
  while [ $vowel_count -ne $2 ]
  do
    random_string="$(get_random_string 100)"
    new_string=$(echo $random_string | sed -E 's/(.)\1+/\1/g' | head -c $length)
    vowel_count=$(echo $new_string | grep -io '[aeiou]' | wc -l)
  done
  prefix=$(echo $new_string | head -c 1)
  suffix=$(echo $new_string | tail -c ${#new_string} | tr '[A-Z]' '[a-z]')
  #echo $new_string
}

if [[ ! -d qemubackup ]]; then
  echo -e "$(pwd)/\e[1mqemubackup\e[0m does not exist, clone started..."
  git clone --single-branch --branch stable-9.2 https://github.com/qemu/qemu.git qemubackup
else
  echo -e "$(pwd)/\e[1mqemubackup\e[0m found."
fi

file_vhdx="$(pwd)/qemu/block/vhdx.c"
file_vvfat="$(pwd)/qemu/block/vvfat.c"
file_msmouse="$(pwd)/qemu/chardev/msmouse.c"
file_wctablet="$(pwd)/qemu/chardev/wctablet.c"
file_vhostusergpu="$(pwd)/qemu/contrib/vhost-user-gpu/vhost-user-gpu.c"
file_amlbuild="$(pwd)/qemu/hw/acpi/aml-build.c"
file_acpi_core="$(pwd)/qemu/hw/acpi/core.c"
file_hdacodec="$(pwd)/qemu/hw/audio/hda-codec.c"
file_escc="$(pwd)/qemu/hw/char/escc.c"
#file_serialpci="$(pwd)/qemu/hw/char/serial-pci.c"
file_qdev="$(pwd)/qemu/hw/core/qdev.c"
file_edidgenerate="$(pwd)/qemu/hw/display/edid-generate.c"
file_smbusich9="$(pwd)/qemu/hw/i2c/smbus_ich9.c"
file_acpibuild="$(pwd)/qemu/hw/i386/acpi-build.c"
file_i386_fwcfg="$(pwd)/qemu/hw/i386/fw_cfg.c"
file_multiboot="$(pwd)/qemu/hw/i386/multiboot.c"
file_pc="$(pwd)/qemu/hw/i386/pc.c"
#file_pcpiix="$(pwd)/qemu/hw/i386/pc_piix.c"
file_pcq35="$(pwd)/qemu/hw/i386/pc_q35.c"
file_atapi="$(pwd)/qemu/hw/ide/atapi.c"
file_core="$(pwd)/qemu/hw/ide/core.c"
file_ich="$(pwd)/qemu/hw/ide/ich.c"
file_adbkbd="$(pwd)/qemu/hw/input/adb-kbd.c"
file_adbmouse="$(pwd)/qemu/hw/input/adb-mouse.c"
#file_ads7846="$(pwd)/qemu/hw/input/ads7846.c"
file_hid="$(pwd)/qemu/hw/input/hid.c"
file_ps2="$(pwd)/qemu/hw/input/ps2.c"
#file_tsc2005="$(pwd)/qemu/hw/input/tsc2005.c"
#file_tsc210x="$(pwd)/qemu/hw/input/tsc210x.c"
file_virtioinputhid="$(pwd)/qemu/hw/input/virtio-input-hid.c"
file_lpcich9="$(pwd)/qemu/hw/isa/lpc_ich9.c"
file_pvpanicisa="$(pwd)/qemu/hw/misc/pvpanic-isa.c"
file_ctrl="$(pwd)/qemu/hw/nvme/ctrl.c"
file_fwcfgacpi="$(pwd)/qemu/hw/nvram/fw_cfg-acpi.c"
file_nvram_fwcfg="$(pwd)/qemu/hw/nvram/fw_cfg.c"
file_gpex="$(pwd)/qemu/hw/pci-host/gpex.c"
file_mptconfig="$(pwd)/qemu/hw/scsi/mptconfig.c"
file_scsibus="$(pwd)/qemu/hw/scsi/scsi-bus.c"
file_scsidisk="$(pwd)/qemu/hw/scsi/scsi-disk.c"
file_spaprvscsi="$(pwd)/qemu/hw/scsi/spapr_vscsi.c"
file_smbios="$(pwd)/qemu/hw/smbios/smbios.c"
file_lu="$(pwd)/qemu/hw/ufs/lu.c"
file_devaudio="$(pwd)/qemu/hw/usb/dev-audio.c"
file_devhid="$(pwd)/qemu/hw/usb/dev-hid.c"
file_devhub="$(pwd)/qemu/hw/usb/dev-hub.c"
file_devmtp="$(pwd)/qemu/hw/usb/dev-mtp.c"
file_devnetwork="$(pwd)/qemu/hw/usb/dev-network.c"
file_devserial="$(pwd)/qemu/hw/usb/dev-serial.c"
file_devsmartcardreader="$(pwd)/qemu/hw/usb/dev-smartcard-reader.c"
file_devstorage="$(pwd)/qemu/hw/usb/dev-storage.c"
file_devuas="$(pwd)/qemu/hw/usb/dev-uas.c"
file_devwacom="$(pwd)/qemu/hw/usb/dev-wacom.c"
#file_hcduhci="$(pwd)/qemu/hw/usb/hcd-uhci.c"
#file_hcdxhcipci="$(pwd)/qemu/hw/usb/hcd-xhci-pci.c"
file_u2femulated="$(pwd)/qemu/hw/usb/u2f-emulated.c"
file_u2fpassthru="$(pwd)/qemu/hw/usb/u2f-passthru.c"
file_u2f="$(pwd)/qemu/hw/usb/u2f.c"
file_ap="$(pwd)/qemu/hw/vfio/ap.c"
header_amlbuild="$(pwd)/qemu/include/hw/acpi/aml-build.h"
header_pci="$(pwd)/qemu/include/hw/pci/pci.h"
header_qemufwcfg="$(pwd)/qemu/include/standard-headers/linux/qemu_fw_cfg.h"
header_optionrom="$(pwd)/qemu/pc-bios/optionrom/optionrom.h"
file_cpu="$(pwd)/qemu/target/i386/cpu.c"
file_kvm="$(pwd)/qemu/target/i386/kvm/kvm.c"
file_battery="$(pwd)/qemu/battery.dsl"

if [[ -f "$file_vhdx" ]]; then rm "$file_vhdx"; fi
if [[ -f "$file_vvfat" ]]; then rm "$file_vvfat"; fi
if [[ -f "$file_msmouse" ]]; then rm "$file_msmouse"; fi
if [[ -f "$file_wctablet" ]]; then rm "$file_wctablet"; fi
if [[ -f "$file_vhostusergpu" ]]; then rm "$file_vhostusergpu"; fi
if [[ -f "$file_amlbuild" ]]; then rm "$file_amlbuild"; fi
if [[ -f "$file_acpi_core" ]]; then rm "$file_acpi_core"; fi
if [[ -f "$file_hdacodec" ]]; then rm "$file_hdacodec"; fi
if [[ -f "$file_escc" ]]; then rm "$file_escc"; fi
#if [[ -f "$file_serialpci" ]]; then rm "$file_serialpci"; fi
if [[ -f "$file_qdev" ]]; then rm "$file_qdev"; fi
if [[ -f "$file_edidgenerate" ]]; then rm "$file_edidgenerate"; fi
if [[ -f "$file_smbusich9" ]]; then rm "$file_smbusich9"; fi
if [[ -f "$file_acpibuild" ]]; then rm "$file_acpibuild"; fi
if [[ -f "$file_i386_fwcfg" ]]; then rm "$file_i386_fwcfg"; fi
if [[ -f "$file_multiboot" ]]; then rm "$file_multiboot"; fi
if [[ -f "$file_pc" ]]; then rm "$file_pc"; fi
#if [[ -f "$file_pcpiix" ]]; then rm "$file_pcpiix"; fi
if [[ -f "$file_pcq35" ]]; then rm "$file_pcq35"; fi
if [[ -f "$file_atapi" ]]; then rm "$file_atapi"; fi
if [[ -f "$file_core" ]]; then rm "$file_core"; fi
if [[ -f "$file_ich" ]]; then rm "$file_ich"; fi
if [[ -f "$file_adbkbd" ]]; then rm "$file_adbkbd"; fi
if [[ -f "$file_adbmouse" ]]; then rm "$file_adbmouse"; fi
#if [[ -f "$file_ads7846" ]]; then rm "$file_ads7846"; fi
if [[ -f "$file_hid" ]]; then rm "$file_hid"; fi
if [[ -f "$file_ps2" ]]; then rm "$file_ps2"; fi
#if [[ -f "$file_tsc2005" ]]; then rm "$file_tsc2005"; fi
#if [[ -f "$file_tsc210x" ]]; then rm "$file_tsc210x"; fi
if [[ -f "$file_virtioinputhid" ]]; then rm "$file_virtioinputhid"; fi
if [[ -f "$file_lpcich9" ]]; then rm "$file_lpcich9"; fi
if [[ -f "$file_pvpanicisa" ]]; then rm "$file_pvpanicisa"; fi
if [[ -f "$file_ctrl" ]]; then rm "$file_ctrl"; fi
if [[ -f "$file_fwcfgacpi" ]]; then rm "$file_fwcfgacpi"; fi
if [[ -f "$file_nvram_fwcfg" ]]; then rm "$file_nvram_fwcfg"; fi
if [[ -f "$file_gpex" ]]; then rm "$file_gpex"; fi
if [[ -f "$file_mptconfig" ]]; then rm "$file_mptconfig"; fi
if [[ -f "$file_scsibus" ]]; then rm "$file_scsibus"; fi
if [[ -f "$file_scsidisk" ]]; then rm "$file_scsidisk"; fi
if [[ -f "$file_spaprvscsi" ]]; then rm "$file_spaprvscsi"; fi
if [[ -f "$file_smbios" ]]; then rm "$file_smbios"; fi
if [[ -f "$file_lu" ]]; then rm "$file_lu"; fi
if [[ -f "$file_devaudio" ]]; then rm "$file_devaudio"; fi
if [[ -f "$file_devhid" ]]; then rm "$file_devhid"; fi
if [[ -f "$file_devhub" ]]; then rm "$file_devhub"; fi
if [[ -f "$file_devmtp" ]]; then rm "$file_devmtp"; fi
if [[ -f "$file_devnetwork" ]]; then rm "$file_devnetwork"; fi
if [[ -f "$file_devserial" ]]; then rm "$file_devserial"; fi
if [[ -f "$file_devsmartcardreader" ]]; then rm "$file_devsmartcardreader"; fi
if [[ -f "$file_devstorage" ]]; then rm "$file_devstorage"; fi
if [[ -f "$file_devuas" ]]; then rm "$file_devuas"; fi
if [[ -f "$file_devwacom" ]]; then rm "$file_devwacom"; fi
#if [[ -f "$file_hcduhci" ]]; then rm "$file_hcduhci"; fi
#if [[ -f "$file_hcdxhcipci" ]]; then rm "$file_hcdxhcipci"; fi
if [[ -f "$file_u2femulated" ]]; then rm "$file_u2femulated"; fi
if [[ -f "$file_u2fpassthru" ]]; then rm "$file_u2fpassthru"; fi
if [[ -f "$file_u2f" ]]; then rm "$file_u2f"; fi
if [[ -f "$file_ap" ]]; then rm "$file_ap"; fi
if [[ -f "$header_amlbuild" ]]; then rm "$header_amlbuild"; fi
if [[ -f "$header_pci" ]]; then rm "$header_pci"; fi
if [[ -f "$header_qemufwcfg" ]]; then rm "$header_qemufwcfg"; fi
if [[ -f "$header_optionrom" ]]; then rm "$header_optionrom"; fi
if [[ -f "$file_cpu" ]]; then rm "$file_cpu"; fi
if [[ -f "$file_kvm" ]]; then rm "$file_kvm"; fi
if [[ -f "$file_battery" ]]; then rm "$file_battery"; fi
mkdir -p qemu
cp -fr qemubackup/. qemu/.
cp -f battery.dsl qemu/.

echo "  $file_vhdx"
get_new_string $(shuf -i 5-7 -n 1) 3
echo "QEMU v                               -> $prefix$suffix v"
sed -i "$file_vhdx" -Ee "s/QEMU v/$prefix$suffix v/"

echo "  $file_vvfat"
get_new_string 4 1
echo "QEMU VVFAT                           -> $new_string VVFAT"
sed -i "$file_vvfat" -Ee "s/QEMU VVFAT/$new_string VVFAT/"

echo "  $file_msmouse"
echo "QEMU Microsoft Mouse                 -> Microsoft Mouse"
sed -i "$file_msmouse" -Ee "s/QEMU Microsoft Mouse/Microsoft Mouse/"

echo "  $file_wctablet"
echo "QEMU Wacom Pen Tablet                -> Wacom Pen Tablet"
sed -i "$file_wctablet" -Ee "s/QEMU Wacom Pen Tablet/Wacom Pen Tablet/"

echo "  $file_vhostusergpu"
echo "QEMU vhost-user-gpu                  -> Intel(R) HD Graphics"
sed -i "$file_vhostusergpu" -Ee "s/QEMU vhost-user-gpu/Intel(R) HD Graphics/"

echo "  $file_amlbuild"
chassis_type=$(sudo dmidecode --string chassis-type)
if [[ "$chassis_type" == "Desktop" ]]; then
  pm_type="1"
else
  pm_type="2"
fi
sed -i "$file_amlbuild" -e 's/build_append_int_noprefix(tbl, 0 \/\* Unspecified \*\//build_append_int_noprefix(tbl, '"$pm_type"' \/\* '"$chassis_type"' \*\//'
get_new_string 4 1
echo "\"QEMU\"                               -> \"$new_string\""
sed -i "$file_amlbuild" -Ee "s/\"QEMU\"/\"$new_string\"/"

echo "  $file_acpi_core"
echo "\"QEMU\0\0\0\0\1\0\"                   -> \"SSDT\0\0\0\0\1\0\""
sed -i "$file_acpi_core" -Ee "s/\"QEMU\\\\0\\\\0\\\\0\\\\0\\\\1\\\\0\"/\"SSDT\\\\0\\\\0\\\\0\\\\0\\\\1\\\\0\"/"
echo "\"QEMUQEQEMUQEMU\1\0\0\0\"             -> \"${oem_id}${table_id}\0\0\0\0\1\0\""
sed -i "$file_acpi_core" -Ee "s/\"QEMUQEQEMUQEMU\\\\1\\\\0\\\\0\\\\0\"/\"${oem_id}${table_id}\\\\1\\\\0\\\\0\\\\0\"/"
echo "\"QEMU\1\0\0\0\"                       -> \"INTL\1\0\0\0\""
sed -i "$file_acpi_core" -Ee "s/\"QEMU\\\\1\\\\0\\\\0\\\\0\"/\"INTL\\\\1\\\\0\\\\0\\\\0\"/"

echo "  $file_hdacodec"
echo "0x1af4                               -> 0x10ec"
sed -i "$file_hdacodec" -Ee "s/0x1af4/0x10ec/"

echo "  $file_escc"
echo "QEMU Sun Mouse                       -> Sun Mouse"
sed -i "$file_escc" -Ee "s/QEMU Sun Mouse/Sun Mouse/"

#echo "  $file_serialpci"

echo "  $file_qdev"
echo "hotpluggable = true                  -> hotpluggable = false"
sed -i "$file_qdev" -Ee "s/hotpluggable = true/hotpluggable = false/"

echo "  $file_edidgenerate"
get_new_string $(shuf -i 5-7 -n 1) 3
word=$(get_random_hex 4)
week=$(shuf -i 1-52 -n 1)
year=$(shuf -i 25-35 -n 1)
echo "RHT                                  -> $prefix$suffix"
echo "QEMU Monitor                         -> $prefix$suffix Monitor"
echo "prefx = 1280                         -> prefx = 1920"
echo "prefy = 800                          -> prefy = 1080"
echo "0x1234                               -> 0x$word"
echo "edid[16] = 42                        -> edid[16] = $week"
echo "edid[17] = 2014 - 1990               -> edid[17] = $year"
sed -i "$file_edidgenerate" -Ee "s/RHT/$prefix$suffix/"
sed -i "$file_edidgenerate" -Ee "s/QEMU Monitor/$prefix$suffix Monitor/"
sed -i "$file_edidgenerate" -Ee "s/prefx = 1280/prefx = 1920/"
sed -i "$file_edidgenerate" -Ee "s/prefy = 800/prefy = 1080/"
sed -i "$file_edidgenerate" -Ee "s/0x1234/0x$word/"
sed -i "$file_edidgenerate" -Ee "s/edid\[16\] = 42/edid\[16\] = $week/"
sed -i "$file_edidgenerate" -Ee "s/edid\[17\] = 2014 - 1990/edid\[17\] = $year/"

echo "  $file_smbusich9"
IFS=':'
cpu_vendor=( $(cat /proc/cpuinfo | grep 'vendor_id' | uniq) )
cpu_vendor="${cpu_vendor[1]}"
if [[ "${cpu_vendor:1}" == "AuthenticAMD" ]]; then
  echo "PCI_VENDOR_ID_INTEL                  -> PCI_VENDOR_ID_AMD"
  echo "PCI_DEVICE_ID_INTEL_ICH9_6           -> 0x790b" #FCH SMBus Controller
  echo "ICH9 SMBUS Bridge                    -> AMD SMBUS Bridge"
#  sed -i "$file_smbusich9" -Ee "s/PCI_VENDOR_ID_INTEL/PCI_VENDOR_ID_AMD/"
#  sed -i "$file_smbusich9" -Ee "s/PCI_DEVICE_ID_INTEL_ICH9_6/0x790b/"
  sed -i "$file_smbusich9" -Ee "s/ICH9 SMBUS Bridge/AMD SMBUS Bridge/"
else
  echo "PCI_DEVICE_ID_INTEL_ICH9_6           -> 0x51a3" #Alder Lake PCH-P SMBus Host Controller
  echo "ICH9 SMBUS Bridge                    -> Intel SMBUS Bridge"
#  sed -i "$file_smbusich9" -Ee "s/PCI_DEVICE_ID_INTEL_ICH9_6/0x51a3/"
  sed -i "$file_smbusich9" -Ee "s/ICH9 SMBUS Bridge/Intel SMBUS Bridge/"
fi

echo "  $file_acpibuild"
sed -i "$file_acpibuild" -e '/Helpful/{n;n;N;N;N;N;N;N;N;N;N;N;N;N;N;N;N;N;N;d;}'
sed -i "$file_acpibuild" -e '/x86ms->oem_id, x86ms->oem_table_id, &pcms->cxl_devices_state);/{n;n;N;N;d;}'
echo "    acpi_add_table(table_offsets, tables_blob);"
echo "    AcpiTable table = { .sig = \"BGRT\", .rev = 1,"
echo "        .oem_id = x86ms->oem_id, .oem_table_id = x86ms->oem_table_id };"
echo "    acpi_table_begin(&table, tables_blob);"
echo "    build_append_int_noprefix(tables_blob,0x00000000,4);"
echo "    acpi_table_end(tables->linker, &table);"
echo "    ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^"
echo "    /* RSDT is pointed to by RSDP */"
sed -i "$file_acpibuild" -Ee "/\/\* RSDT is pointed to by RSDP \*\//i\    acpi_add_table(table_offsets, tables_blob);"
sed -i "$file_acpibuild" -Ee "/\/\* RSDT is pointed to by RSDP \*\//i\    AcpiTable table = { .sig = \"BGRT\", .rev = 1,"
sed -i "$file_acpibuild" -Ee "/\/\* RSDT is pointed to by RSDP \*\//i\        .oem_id = x86ms->oem_id, .oem_table_id = x86ms->oem_table_id };"
sed -i "$file_acpibuild" -Ee "/\/\* RSDT is pointed to by RSDP \*\//i\    acpi_table_begin(&table, tables_blob);"
sed -i "$file_acpibuild" -Ee "/\/\* RSDT is pointed to by RSDP \*\//i\    build_append_int_noprefix(tables_blob,0x00000000,4);"
sed -i "$file_acpibuild" -Ee "/\/\* RSDT is pointed to by RSDP \*\//i\    acpi_table_end(tables->linker, &table);"

echo "  $file_i386_fwcfg"
get_new_string $(shuf -i 5-7 -n 1) 3
echo "\"QEMU\"                               -> \"$prefix$suffix\""
sed -i "$file_i386_fwcfg" -Ee "s/\"QEMU\"/\"$prefix$suffix\"/"
get_new_string 4 1
echo "\"FWCF\"                               -> \"${new_string}\""
sed -i "$file_i386_fwcfg" -Ee "s/\"FWCF\"/\"${new_string}\"/"
echo "QEMU0002                             -> ${new_string}0002"
sed -i "$file_i386_fwcfg" -Ee "s/QEMU0002/${new_string}0002/"

echo "  $file_multiboot"
echo "\"qemu\"                               -> \"Windows Boot Manager\""
sed -i "$file_multiboot" -Ee "s/\"qemu\"/\"Windows Boot Manager\"/"

echo "  $file_pc"
echo "\"QEMU Virtual CPU version \"          -> \"CPU version \""
echo "\"QEMU Virtual CPU version \"          -> \"CPU version \""
echo "\"QEMU Virtual CPU version \"          -> \"CPU version \""
sed -i "$file_pc" -Ee "s/\"QEMU Virtual CPU version \"/\"CPU version \"/"
sed -i "$file_pc" -Ee "s/\"QEMU Virtual CPU version \"/\"CPU version \"/"
sed -i "$file_pc" -Ee "s/\"QEMU Virtual CPU version \"/\"CPU version \"/"

#echo "  $file_pcpiix"

echo "  $file_pcq35"
cpu_family=( $(cat /proc/cpuinfo | grep 'cpu family' | uniq) )
cpu_family="${cpu_family[1]}"
cpu_name=( $(cat /proc/cpuinfo | grep 'model name' | uniq) )
cpu_name="${cpu_name[1]}"
echo "\"pc_q35\"                             -> \"${cpu_family:1}\""
echo "Standard PC (Q35 + ICH9, 2009)       -> ${cpu_name:1}"
sed -i "$file_pcq35" -Ee "s/\"pc_q35\"/\"${cpu_family:1}\"/"
sed -i "$file_pcq35" -Ee "s/Standard PC \(Q35 \+ ICH9, 2009\)/${cpu_name:1}/"

echo "  $file_atapi"
get_new_string 4 1
echo "\"QEMU\"                               -> \"$new_string\""
echo "QEMU DVD-ROM                         -> $new_string DVD-ROM"
sed -i "$file_atapi" -Ee "s/\"QEMU\"/\"$new_string\"/"
sed -i "$file_atapi" -Ee "s/QEMU DVD-ROM/$new_string DVD-ROM/"

echo "  $file_core"
echo "QEMU DVD-ROM                         -> $new_ide_cd_model"
echo "QEMU MICRODRIVE                      -> $new_ide_cfata_model"
echo "QEMU HARDDISK                        -> $new_default_model"
sed -i "$file_core" -Ee "s/QEMU DVD-ROM/$new_ide_cd_model/"
sed -i "$file_core" -Ee "s/QEMU MICRODRIVE/$new_ide_cfata_model/"
sed -i "$file_core" -Ee "s/QEMU HARDDISK/$new_default_model/"

echo "  $file_ich"
if [[ "${cpu_vendor:1}" == "AuthenticAMD" ]]; then
  echo "PCI_VENDOR_ID_INTEL                  -> PCI_VENDOR_ID_AMD"
  echo "PCI_DEVICE_ID_INTEL_82801IR          -> 0x43c8" #400 Series Chipset SATA Controller
#  sed -i "$file_ich" -Ee "s/PCI_VENDOR_ID_INTEL/PCI_VENDOR_ID_AMD/"
#  sed -i "$file_ich" -Ee "s/PCI_DEVICE_ID_INTEL_82801IR/0x43c8/"
else
  echo "PCI_DEVICE_ID_INTEL_82801IR          -> 0x02d3" #Comet Lake SATA AHCI Controller
#  sed -i "$file_ich" -Ee "s/PCI_DEVICE_ID_INTEL_82801IR/0x02d3/"
fi

echo "  $file_adbkbd"
get_new_string $(shuf -i 5-7 -n 1) 3
echo "QEMU ADB Keyboard                    -> $prefix$suffix ADB Keyboard"
sed -i "$file_adbkbd" -Ee "s/QEMU ADB Keyboard/$prefix$suffix ADB Keyboard/"

echo "  $file_adbmouse"
get_new_string $(shuf -i 5-7 -n 1) 3
echo "QEMU ADB Mouse                       -> $prefix$suffix ADB Mouse"
sed -i "$file_adbmouse" -Ee "s/QEMU ADB Mouse/$prefix$suffix ADB Mouse/"

#echo "  $file_ads7846"
#get_new_string $(shuf -i 5-7 -n 1) 3
#echo "QEMU ADS7846-driven Touchscreen -> $prefix$suffix ADS7846-driven Touchscreen"

echo "  $file_hid"
get_new_string $(shuf -i 5-7 -n 1) 3
echo "QEMU HID Keyboard                    -> $prefix$suffix HID Keyboard"
echo "QEMU HID Mouse                       -> $prefix$suffix HID Mouse"
echo "QEMU HID Tablet                      -> $prefix$suffix HID Tablet"
sed -i "$file_hid" -Ee "s/QEMU HID Keyboard/$prefix$suffix HID Keyboard/"
sed -i "$file_hid" -Ee "s/QEMU HID Mouse/$prefix$suffix HID Mouse/"
sed -i "$file_hid" -Ee "s/QEMU HID Tablet/$prefix$suffix HID Tablet/"

echo "  $file_ps2"
get_new_string $(shuf -i 5-7 -n 1) 3
echo "QEMU PS/2 Keyboard                   -> $prefix$suffix PS/2 Keyboard"
echo "QEMU PS/2 Mouse                      -> $prefix$suffix PS/2 Mouse"
sed -i "$file_ps2" -Ee "s/QEMU PS\/2 Keyboard/$prefix$suffix PS\/2 Keyboard/"
sed -i "$file_ps2" -Ee "s/QEMU PS\/2 Mouse/$prefix$suffix PS\/2 Mouse/"

#echo "  $file_tsc2005"
#get_new_string $(shuf -i 5-7 -n 1) 3
#echo "QEMU TSC2005-driven Touchscreen -> $prefix$suffix TSC2005-driven Touchscreen"

#echo "  $file_tsc210x"
#get_new_string $(shuf -i 5-7 -n 1) 3
#echo "QEMU TSC2102-driven Touchscreen -> $prefix$suffix TSC2102-driven Touchscreen"
#echo "QEMU TSC2301-driven Touchscreen -> $prefix$suffix TSC2301-driven Touchscreen"

echo "  $file_virtioinputhid"
get_new_string $(shuf -i 5-7 -n 1) 3
echo "QEMU Virtio Keyboard                 -> $prefix$suffix Keyboard"
echo "QEMU Virtio Mouse                    -> $prefix$suffix Mouse"
echo "QEMU Virtio Tablet                   -> $prefix$suffix Tablet"
echo "QEMU Virtio MultiTouch               -> $prefix$suffix MultiTouch"
sed -i "$file_virtioinputhid" -Ee "s/QEMU Virtio Keyboard/$prefix$suffix Keyboard/"
sed -i "$file_virtioinputhid" -Ee "s/QEMU Virtio Mouse/$prefix$suffix Mouse/"
sed -i "$file_virtioinputhid" -Ee "s/QEMU Virtio Tablet/$prefix$suffix Tablet/"
sed -i "$file_virtioinputhid" -Ee "s/QEMU Virtio MultiTouch/$prefix$suffix MultiTouch/"
if [[ "${cpu_vendor:1}" == "AuthenticAMD" ]]; then
  echo "0x0627                               -> 0x1022"
  echo "0x0627                               -> 0x1022"
  echo "0x0627                               -> 0x1022"
  echo "0x0627                               -> 0x1022"
  echo "0x0627                               -> 0x1022"
  echo "0x0627                               -> 0x1022"
  sed -i "$file_virtioinputhid" -Ee "s/0x0627/0x1022/"
  sed -i "$file_virtioinputhid" -Ee "s/0x0627/0x1022/"
  sed -i "$file_virtioinputhid" -Ee "s/0x0627/0x1022/"
  sed -i "$file_virtioinputhid" -Ee "s/0x0627/0x1022/"
  sed -i "$file_virtioinputhid" -Ee "s/0x0627/0x1022/"
  sed -i "$file_virtioinputhid" -Ee "s/0x0627/0x1022/"
else
  echo "0x0627                               -> 0x8086"
  echo "0x0627                               -> 0x8086"
  echo "0x0627                               -> 0x8086"
  echo "0x0627                               -> 0x8086"
  echo "0x0627                               -> 0x8086"
  echo "0x0627                               -> 0x8086"
  sed -i "$file_virtioinputhid" -Ee "s/0x0627/0x8086/"
  sed -i "$file_virtioinputhid" -Ee "s/0x0627/0x8086/"
  sed -i "$file_virtioinputhid" -Ee "s/0x0627/0x8086/"
  sed -i "$file_virtioinputhid" -Ee "s/0x0627/0x8086/"
  sed -i "$file_virtioinputhid" -Ee "s/0x0627/0x8086/"
  sed -i "$file_virtioinputhid" -Ee "s/0x0627/0x8086/"
fi

echo "  $file_lpcich9"
if [[ "${cpu_vendor:1}" == "AuthenticAMD" ]]; then
  echo "ICH9 LPC bridge                      -> AMD LPC bridge"
  echo "PCI_VENDOR_ID_INTEL                  -> PCI_VENDOR_ID_AMD"
  echo "PCI_DEVICE_ID_INTEL_ICH9_8           -> 0x790e" #FCH LPC Bridge
  sed -i "$file_lpcich9" -Ee "s/ICH9 LPC bridge/AMD LPC bridge/"
#  sed -i "$file_lpcich9" -Ee "s/PCI_VENDOR_ID_INTEL/PCI_VENDOR_ID_AMD/"
#  sed -i "$file_lpcich9" -Ee "s/PCI_DEVICE_ID_INTEL_ICH9_8/0x790e/"
else
  echo "ICH9 LPC bridge                      -> Intel LPC bridge"
  echo "PCI_DEVICE_ID_INTEL_ICH9_8           -> 0xa30e" #Cannon Lake LPC Controller
  sed -i "$file_lpcich9" -Ee "s/ICH9 LPC bridge/Intel LPC bridge/"
#  sed -i "$file_lpcich9" -Ee "s/PCI_DEVICE_ID_INTEL_ICH9_8/0xa30e/"
fi

echo "  $file_pvpanicisa"
echo "QEMU0001                             -> UEFI0001"
sed -i "$file_pvpanicisa" -Ee "s/QEMU0001/UEFI0001/"

echo "  $file_ctrl"
get_new_string 4 1
echo "QEMU NVMe Ctrl                       -> $new_string NVMe Ctrl"
sed -i "$file_ctrl" -Ee "s/QEMU NVMe Ctrl/$new_string NVMe Ctrl/"

echo "  $file_fwcfgacpi"
get_new_string 4 1
echo "\"FWCF\"                               -> \"${new_string}\""
sed -i "$file_fwcfgacpi" -Ee "s/\"FWCF\"/\"${new_string}\"/"
echo "QEMU0002                             -> ${new_string}0002"
sed -i "$file_fwcfgacpi" -Ee "s/QEMU0002/${new_string}0002/"

#signature=$(get_random_hex 16)
signature="0x41204D2049202020ULL"
echo "  $file_nvram_fwcfg"
echo "0x51454d5520434647ULL                -> $signature"
sed -i "$file_nvram_fwcfg" -Ee "s/0x51454d5520434647ULL/$signature/"
#get_new_string 4 1
#echo "\"QEMU\"                               -> \"$new_string\""
#sed -i "$file_nvram_fwcfg" -Ee "s/\"QEMU\"/\"$new_string\"/"

echo "  $file_gpex"
get_new_string 4 1
echo "QEMU generic PCIe host bridge        -> $new_string generic PCIe host bridge"
sed -i "$file_gpex" -Ee "s/QEMU generic PCIe host bridge/$new_string generic PCIe host bridge/"

echo "  $file_mptconfig"
get_new_string $(shuf -i 5-7 -n 1) 3
number=$(get_random_dec 16)
echo "QEMU MPT Fusion                      -> $prefix$suffix MPT Fusion"
echo "QEMU MPT Fusion                      -> $prefix$suffix MPT Fusion"
echo "\"QEMU\"                               -> \"$prefix$suffix\""
echo "0000111122223333                     -> $number"
sed -i "$file_mptconfig" -Ee "s/QEMU MPT Fusion/$prefix$suffix MPT Fusion/"
sed -i "$file_mptconfig" -Ee "s/QEMU MPT Fusion/$prefix$suffix MPT Fusion/"
sed -i "$file_mptconfig" -Ee "s/\"QEMU\"/\"$prefix$suffix\"/"
sed -i "$file_mptconfig" -Ee "s/0000111122223333/$number/"

echo "  $file_scsibus"
get_new_string 4 1
echo "\"QEMU    \"                           -> \"${new_string}    \""
echo "\"QEMU TARGET     \"                   -> \"${new_string} TARGET     \""
sed -i "$file_scsibus" -Ee "s/\"QEMU    \"/\"${new_string}    \"/"
sed -i "$file_scsibus" -Ee "s/\"QEMU TARGET     \"/\"${new_string} TARGET     \"/"

echo "  $file_scsidisk"
get_new_string $(shuf -i 5-7 -n 1) 3
echo "\"QEMU\"                               -> \"$new_string\""
echo "\"QEMU HARDDISK\"                      -> \"$new_string HARDDISK\""
echo "\"QEMU CD-ROM\"                        -> \"$new_string CD-ROM\""
sed -i "$file_scsidisk" -Ee "s/\"QEMU\"/\"$new_string\"/"
sed -i "$file_scsidisk" -Ee "s/\"QEMU HARDDISK\"/\"$new_string HARDDISK\"/"
sed -i "$file_scsidisk" -Ee "s/\"QEMU CD-ROM\"/\"$new_string CD-ROM\"/"

echo "  $file_spaprvscsi"
get_new_string 4 1
nocaps=$(echo $new_string | tr '[A-Z]' '[a-z]')
echo "\"QEMU EMPTY      \"                   -> \"${new_string} EMPTY      \""
echo "\"QEMU    \"                           -> \"${new_string}    \""
echo "\"qemu\"                               -> \"$nocaps\""
echo "\"qemu\"                               -> \"$nocaps\""
sed -i "$file_spaprvscsi" -Ee "s/\"QEMU EMPTY      \"/\"${new_string} EMPTY      \"/"
sed -i "$file_spaprvscsi" -Ee "s/\"QEMU    \"/\"${new_string}    \"/"
sed -i "$file_spaprvscsi" -Ee "s/\"qemu\"/\"$nocaps\"/"
sed -i "$file_spaprvscsi" -Ee "s/\"qemu\"/\"$nocaps\"/"

echo "  $file_smbios"
echo "characteristics = cpu_to_le64(0x08)  -> characteristics = cpu_to_le64(0)"
echo "extension_bytes[1] = 0x14            -> extension_bytes[1] = 0x0F"
echo "extension_bytes[1] |= 0x08           -> extension_bytes[1] |= 0"
echo "processor_family = 0xfe              -> processor_family = 0xC6"
echo "voltage = 0                          -> voltage = 0x8B"
echo "external_clock = cpu_to_le16(0)      -> external_clock = cpu_to_le16(100)"
echo "1_cache_handle = cpu_to_le16(0xFFFF) -> 1_cache_handle = cpu_to_le16(0x0039)"
echo "2_cache_handle = cpu_to_le16(0xFFFF) -> 2_cache_handle = cpu_to_le16(0x003A)"
echo "3_cache_handle = cpu_to_le16(0xFFFF) -> 3_cache_handle = cpu_to_le16(0x003B)"
echo "characteristics = cpu_to_le16(0x02)  -> characteristics = cpu_to_le16(0x04)"
echo "location = 0x01                      -> location = 0x03"
echo "error_correction = 0x06              -> error_correction = 0x03"
echo "total_width = cpu_to_le16(0xFFFF)    -> total_width = cpu_to_le16(64)"
echo "data_width = cpu_to_le16(0xFFFF)     -> data_width = cpu_to_le16(64)"
echo "memory_type = 0x07                   -> memory_type = 0x1A"
echo "minimum_voltage = cpu_to_le16(0)     -> minimum_voltage = cpu_to_le16(1200)"
echo "maximum_voltage = cpu_to_le16(0)     -> maximum_voltage = cpu_to_le16(1350)"
echo "configured_voltage = cpu_to_le16(0)  -> configured_voltage = cpu_to_le16(1200)"
sed -i "$file_smbios" -Ee "s/characteristics = cpu_to_le64\(0x08\)/characteristics = cpu_to_le64\(0\)/"
sed -i "$file_smbios" -Ee "s/extension_bytes\[1\] = 0x14/extension_bytes\[1\] = 0x0F/"
sed -i "$file_smbios" -Ee "s/extension_bytes\[1\] \|= 0x08/extension_bytes\[1\] \|= 0/"
sed -i "$file_smbios" -Ee "s/processor_family = 0xfe/processor_family = 0xC6/"
sed -i "$file_smbios" -Ee "s/voltage = 0/voltage = 0x8B/"
sed -i "$file_smbios" -Ee "s/external_clock = cpu_to_le16\(0\)/external_clock = cpu_to_le16\(100\)/"
sed -i "$file_smbios" -Ee "s/1_cache_handle = cpu_to_le16\(0xFFFF\)/1_cache_handle = cpu_to_le16\(0x0039\)/"
sed -i "$file_smbios" -Ee "s/2_cache_handle = cpu_to_le16\(0xFFFF\)/2_cache_handle = cpu_to_le16\(0x003A\)/"
sed -i "$file_smbios" -Ee "s/3_cache_handle = cpu_to_le16\(0xFFFF\)/3_cache_handle = cpu_to_le16\(0x003B\)/"
sed -i "$file_smbios" -Ee "s/characteristics = cpu_to_le16\(0x02\)/characteristics = cpu_to_le16\(0x04\)/"
sed -i "$file_smbios" -Ee "s/location = 0x01/location = 0x03/"
sed -i "$file_smbios" -Ee "s/error_correction = 0x06/error_correction = 0x03/"
sed -i "$file_smbios" -Ee "s/total_width = cpu_to_le16\(0xFFFF\)/total_width = cpu_to_le16\(64\)/"
sed -i "$file_smbios" -Ee "s/data_width = cpu_to_le16\(0xFFFF\)/data_width = cpu_to_le16\(64\)/"
sed -i "$file_smbios" -Ee "s/memory_type = 0x07/memory_type = 0x1A/"
sed -i "$file_smbios" -Ee "s/minimum_voltage = cpu_to_le16\(0\)/minimum_voltage = cpu_to_le16\(1200\)/"
sed -i "$file_smbios" -Ee "s/maximum_voltage = cpu_to_le16\(0\)/maximum_voltage = cpu_to_le16\(1350\)/"
sed -i "$file_smbios" -Ee "s/configured_voltage = cpu_to_le16\(0\)/configured_voltage = cpu_to_le16\(1200\)/"

echo "  $file_lu"
get_new_string 4 1
echo "\"QEMU\"                               -> \"$new_string\""
echo "\"QEMU UFS\"                           -> \"$new_string UFS\""
sed -i "$file_lu" -Ee "s/\"QEMU\"/\"$new_string\"/"
sed -i "$file_lu" -Ee "s/\"QEMU UFS\"/\"$new_string UFS\"/"

echo "  $file_devaudio"
get_new_string $(shuf -i 5-7 -n 1) 3
number=$(get_random_dec 10)
echo "\"QEMU\",                              -> \"$prefix$suffix\","
echo "\"QEMU USB Audio\"                     -> \"$prefix$suffix USB Audio\""
echo "\"1\"                                  -> \"$number\""
echo "\"Audio Configuration\"                -> \"USB Audio Config\""
echo "\"Audio Device\"                       -> \"USB Audio Control\""
echo "\"Audio Output Pipe\"                  -> \"USB Audio Input Terminal\""
echo "\"Audio Output Volume Control\"        -> \"USB Audio Feature Unit\""
echo "\"Audio Output Terminal\"              -> \"USB Audio Output Terminal\""
echo "\"Audio Output - Disabled\"            -> \"USB Audio Null Stream\""
echo "\"Audio Output - 48 kHz Stereo\"       -> \"USB Audio Real Stream\""
echo "QEMU USB Audio Interface             -> $prefix$suffix USB Audio"
sed -i "$file_devaudio" -Ee "s/\"QEMU\",/\"$prefix$suffix\",/"
sed -i "$file_devaudio" -Ee "s/\"QEMU USB Audio\"/\"$prefix$suffix USB Audio\"/"
sed -i "$file_devaudio" -Ee "s/\"1\"/\"$number\"/"
sed -i "$file_devaudio" -Ee "s/\"Audio Configuration\"/\"USB Audio Config\"/"
sed -i "$file_devaudio" -Ee "s/\"Audio Device\"/\"USB Audio Control\"/"
sed -i "$file_devaudio" -Ee "s/\"Audio Output Pipe\"/\"USB Audio Input Terminal\"/"
sed -i "$file_devaudio" -Ee "s/\"Audio Output Volume Control\"/\"USB Audio Feature Unit\"/"
sed -i "$file_devaudio" -Ee "s/\"Audio Output Terminal\"/\"USB Audio Output Terminal\"/"
sed -i "$file_devaudio" -Ee "s/\"Audio Output - Disabled\"/\"USB Audio Null Stream\"/"
sed -i "$file_devaudio" -Ee "s/\"Audio Output - 48 kHz Stereo\"/\"USB Audio Real Stream\"/"
sed -i "$file_devaudio" -Ee "s/QEMU USB Audio Interface/$prefix$suffix USB Audio/"

echo "  $file_devhid"
get_new_string $(shuf -i 5-7 -n 1) 3
echo "\"QEMU\"                               -> \"$prefix$suffix\""
echo "_MOUSE]    = \"QEMU USB Mouse\"        -> _MOUSE]    = \"$prefix$suffix USB Mouse\""
echo "_TABLET]   = \"QEMU USB Tablet\"       -> _TABLET]   = \"$prefix$suffix USB Tablet\""
echo "_KEYBOARD] = \"QEMU USB Keyboard\"     -> _KEYBOARD] = \"$prefix$suffix USB Keyboard\""
sed -i "$file_devhid" -Ee "s/\"QEMU\"/\"$prefix$suffix\"/"
sed -i "$file_devhid" -Ee "s/_MOUSE]    = \"QEMU USB Mouse\"/_MOUSE]    = \"$prefix$suffix USB Mouse\"/"
sed -i "$file_devhid" -Ee "s/_TABLET]   = \"QEMU USB Tablet\"/_TABLET]   = \"$prefix$suffix USB Tablet\"/"
sed -i "$file_devhid" -Ee "s/_KEYBOARD] = \"QEMU USB Keyboard\"/_KEYBOARD] = \"$prefix$suffix USB Keyboard\"/"
number=$(get_random_dec 10)
echo "\"89126\"                              -> \"$number\""
sed -i "$file_devhid" -Ee "s/\"89126\"/\"$number\"/"
number=$(get_random_dec 10)
echo "\"28754\"                              -> \"$number\""
sed -i "$file_devhid" -Ee "s/\"28754\"/\"$number\"/"
number=$(get_random_dec 10)
echo "\"68284\"                              -> \"$number\""
sed -i "$file_devhid" -Ee "s/\"68284\"/\"$number\"/"
echo "_desc   = \"QEMU USB Tablet\"          -> _desc   = \"$prefix$suffix USB Tablet\""
echo "_desc   = \"QEMU USB Mouse\"           -> _desc   = \"$prefix$suffix USB Mouse\""
echo "_desc   = \"QEMU USB Keyboard\"        -> _desc   = \"$prefix$suffix USB Keyboard\""
sed -i "$file_devhid" -Ee "s/_desc   = \"QEMU USB Tablet\"/_desc   = \"$prefix$suffix USB Tablet\"/"
sed -i "$file_devhid" -Ee "s/_desc   = \"QEMU USB Mouse\"/_desc   = \"$prefix$suffix USB Mouse\"/"
sed -i "$file_devhid" -Ee "s/_desc   = \"QEMU USB Keyboard\"/_desc   = \"$prefix$suffix USB Keyboard\"/"
if [[ "${cpu_vendor:1}" == "AuthenticAMD" ]]; then
  echo "0x0627                               -> 0x1022"
  echo "0x0627                               -> 0x1022"
  echo "0x0627                               -> 0x1022"
  echo "0x0627                               -> 0x1022"
  echo "0x0627                               -> 0x1022"
  echo "0x0627                               -> 0x1022"
  sed -i "$file_devhid" -Ee "s/0x0627/0x1022/"
  sed -i "$file_devhid" -Ee "s/0x0627/0x1022/"
  sed -i "$file_devhid" -Ee "s/0x0627/0x1022/"
  sed -i "$file_devhid" -Ee "s/0x0627/0x1022/"
  sed -i "$file_devhid" -Ee "s/0x0627/0x1022/"
  sed -i "$file_devhid" -Ee "s/0x0627/0x1022/"
else
  echo "0x0627                               -> 0x8086"
  echo "0x0627                               -> 0x8086"
  echo "0x0627                               -> 0x8086"
  echo "0x0627                               -> 0x8086"
  echo "0x0627                               -> 0x8086"
  echo "0x0627                               -> 0x8086"
  sed -i "$file_devhid" -Ee "s/0x0627/0x8086/"
  sed -i "$file_devhid" -Ee "s/0x0627/0x8086/"
  sed -i "$file_devhid" -Ee "s/0x0627/0x8086/"
  sed -i "$file_devhid" -Ee "s/0x0627/0x8086/"
  sed -i "$file_devhid" -Ee "s/0x0627/0x8086/"
  sed -i "$file_devhid" -Ee "s/0x0627/0x8086/"
fi

echo "  $file_devhub"
get_new_string $(shuf -i 5-7 -n 1) 3
number=$(get_random_dec 10)
echo "\"QEMU\"                               -> \"$prefix$suffix\""
echo "_PRODUCT]      = \"QEMU USB Hub\"      -> _PRODUCT]      = \"$prefix$suffix USB Hub\""
echo "\"314159\"                             -> \"$number\""
echo "_desc   = \"QEMU USB Hub\"             -> _desc   = \"$prefix$suffix USB Hub\""
sed -i "$file_devhub" -Ee "s/\"QEMU\"/\"$prefix$suffix\"/"
sed -i "$file_devhub" -Ee "s/_PRODUCT]      = \"QEMU USB Hub\"/_PRODUCT]      = \"$prefix$suffix USB Hub\"/"
sed -i "$file_devhub" -Ee "s/\"314159\"/\"$number\"/"
sed -i "$file_devhub" -Ee "s/_desc   = \"QEMU USB Hub\"/_desc   = \"$prefix$suffix USB Hub\"/"

echo "  $file_devmtp"
get_new_string $(shuf -i 5-7 -n 1) 3
number=$(get_random_dec 10)
echo "MTP_MANUFACTURER  \"QEMU\"             -> MTP_MANUFACTURER  \"$prefix$suffix\""
echo "QEMU filesharing                     -> $prefix$suffix USB MTP"
echo "\"34617\"                              -> \"$number\""
echo "_desc   = \"QEMU USB MTP\"             -> _desc   = \"$prefix$suffix USB MTP\""
sed -i "$file_devmtp" -Ee "s/MTP_MANUFACTURER  \"QEMU\"/MTP_MANUFACTURER  \"$prefix$suffix\"/"
sed -i "$file_devmtp" -Ee "s/QEMU filesharing/$prefix$suffix USB MTP/"
sed -i "$file_devmtp" -Ee "s/\"34617\"/\"$number\"/"
sed -i "$file_devmtp" -Ee "s/_desc   = \"QEMU USB MTP\"/_desc   = \"$prefix$suffix USB MTP\"/"

echo "  $file_devnetwork"
get_new_string 4 1
word=$(get_random_hex 12)
number=$(get_random_dec 10)
echo "\"QEMU\"                               -> \"$new_string\""
echo "RNDIS/QEMU USB Network Device        -> $new_string RNDIS USB Network Adapter"
echo "\"400102030405\"                       -> \"$word\""
echo "QEMU USB Net Data Interface          -> USB Net Data"
echo "QEMU USB Net Control Interface       -> USB Net Control"
echo "QEMU USB Net RNDIS Control Interface -> USB Net RNDIS Control"
echo "QEMU USB Net CDC                     -> USB Net CDC"
echo "QEMU USB Net Subset                  -> USB Net Subset"
echo "QEMU USB Net RNDIS                   -> USB Net RNDIS"
echo "\"1\"                                  -> \"$number\""
echo "QEMU USB RNDIS Net                   -> $new_string RNDIS USB Net"
echo "QEMU USB Network Interface           -> $new_string RNDIS USB Network Adapter"
sed -i "$file_devnetwork" -Ee "s/\"QEMU\"/\"$new_string\"/"
sed -i "$file_devnetwork" -Ee "s/RNDIS\/QEMU USB Network Device/$new_string RNDIS USB Network Adapter/"
sed -i "$file_devnetwork" -Ee "s/\"400102030405\"/\"$word\"/"
sed -i "$file_devnetwork" -Ee "s/QEMU USB Net Data Interface/USB Net Data/"
sed -i "$file_devnetwork" -Ee "s/QEMU USB Net Control Interface/USB Net Control/"
sed -i "$file_devnetwork" -Ee "s/QEMU USB Net RNDIS Control Interface/USB Net RNDIS Control/"
sed -i "$file_devnetwork" -Ee "s/QEMU USB Net CDC/USB Net CDC/"
sed -i "$file_devnetwork" -Ee "s/QEMU USB Net Subset/USB Net Subset/"
sed -i "$file_devnetwork" -Ee "s/QEMU USB Net RNDIS/USB Net RNDIS/"
sed -i "$file_devnetwork" -Ee "s/\"1\"/\"$number\"/"
sed -i "$file_devnetwork" -Ee "s/QEMU USB RNDIS Net/$new_string RNDIS USB Net/"
sed -i "$file_devnetwork" -Ee "s/QEMU USB Network Interface/$new_string RNDIS USB Network Adapter/"

echo "  $file_devserial"
get_new_string $(shuf -i 5-7 -n 1) 3
number=$(get_random_dec 10)
echo "\"QEMU\"                               -> \"$prefix$suffix\""
echo "_SERIAL]  = \"QEMU USB SERIAL\"        -> $prefix$suffix USB Serial"
echo "_BRAILLE]  = \"QEMU USB BAUM BRAILLE\" -> $prefix$suffix USB Braille"
echo "\"1\"                                  -> \"$number\""
echo "_desc   = \"QEMU USB Serial\"          -> _desc   = \"$prefix$suffix USB Serial\""
echo "_desc   = \"QEMU USB Braille\"         -> _desc   = \"$prefix$suffix USB Braille\""
sed -i "$file_devserial" -Ee "s/\"QEMU\"/\"$prefix$suffix\"/"
sed -i "$file_devserial" -Ee "s/_SERIAL\]  = \"QEMU USB SERIAL\"/_SERIAL\]  = \"$prefix$suffix USB Serial\"/"
sed -i "$file_devserial" -Ee "s/_BRAILLE\] = \"QEMU USB BAUM BRAILLE\"/_BRAILLE\] = \"$prefix$suffix USB Braille\"/"
sed -i "$file_devserial" -Ee "s/\"1\"/\"$number\"/"
sed -i "$file_devserial" -Ee "s/_desc   = \"QEMU USB Serial\"/_desc   = \"$prefix$suffix USB Serial\"/"
sed -i "$file_devserial" -Ee "s/_desc   = \"QEMU USB Braille\"/_desc   = \"$prefix$suffix USB Braille\"/"

echo "  $file_devsmartcardreader"
get_new_string $(shuf -i 5-7 -n 1) 3
number=$(get_random_dec 10)
echo "_MANUFACTURER]  = \"QEMU\"             -> _MANUFACTURER]  = \"$prefix$suffix\""
echo "_PRODUCT]       = \"QEMU USB CCID\"    -> _PRODUCT]       = \"$prefix$suffix CCID\""
echo "_SERIALNUMBER]  = \"1\"                -> _SERIALNUMBER]  = \"$number\""
echo "_desc   = \"QEMU USB CCID\"            -> _desc   = \"$prefix$suffix CCID\""
sed -i "$file_devsmartcardreader" -Ee "s/_MANUFACTURER]  = \"QEMU\"/_MANUFACTURER]  = \"$prefix$suffix\"/"
sed -i "$file_devsmartcardreader" -Ee "s/_PRODUCT]       = \"QEMU USB CCID\"/_PRODUCT]       = \"$prefix$suffix USB CCID\"/"
sed -i "$file_devsmartcardreader" -Ee "s/_SERIALNUMBER]  = \"1\"/_SERIALNUMBER]  = \"$number\"/"
sed -i "$file_devsmartcardreader" -Ee "s/_desc   = \"QEMU USB CCID\"/_desc   = \"$prefix$suffix USB CCID\"/"

echo "  $file_devstorage"
get_new_string $(shuf -i 5-7 -n 1) 3
serial=$(get_random_serial 16)
echo "\"QEMU\",                              -> \"$new_string\","
echo "QEMU USB HARDDRIVE                   -> $new_string USB HARDDISK"
echo "\"1\"                                  -> \"$serial\""
echo "_desc   = \"QEMU USB MSD\"             -> _desc   = \"$new_string USB HARDDISK\""
sed -i "$file_devstorage" -Ee "s/\"QEMU\",/\"$new_string\",/"
sed -i "$file_devstorage" -Ee "s/QEMU USB HARDDRIVE/$new_string USB HARDDISK/"
sed -i "$file_devstorage" -Ee "s/\"1\"/\"$serial\"/"
sed -i "$file_devstorage" -Ee "s/_desc   = \"QEMU USB MSD\"/_desc   = \"$new_string USB HARDDISK\"/"

echo "  $file_devuas"
get_new_string $(shuf -i 5-7 -n 1) 3
number=$(get_random_dec 10)
echo "\"QEMU\",                              -> \"$prefix$suffix\","
echo "USB Attached SCSI HBA                -> $prefix$suffix USB Attached SCSI HBA"
echo "\"27842\"                              -> \"$number\""
sed -i "$file_devuas" -Ee "s/\"QEMU\",/\"$prefix$suffix\",/"
sed -i "$file_devuas" -Ee "s/USB Attached SCSI HBA/$prefix$suffix USB Attached SCSI HBA/"
sed -i "$file_devuas" -Ee "s/\"27842\"/\"$number\"/"

echo "  $file_devwacom"
number=$(get_random_dec 10)
echo "\"QEMU\"                               -> \"Wacom\""
echo "Wacom PenPartner                     -> Wacom PenPartner Tablet"
echo "\"1\"                                  -> \"$number\""
echo "QEMU PenPartner tablet               -> Wacom PenPartner Tablet"
echo "QEMU PenPartner tablet               -> Wacom PenPartner Tablet"
echo "_desc   = \"QEMU PenPartner Tablet\"   -> _desc   = \"Wacom PenPartner Tablet\""
echo "desc = \"QEMU PenPartner Tablet\"      -> desc = \"Wacom PenPartner Tablet\""
sed -i "$file_devwacom" -Ee "s/\"QEMU\"/\"Wacom\"/"
sed -i "$file_devwacom" -Ee "s/Wacom PenPartner/Wacom PenPartner Tablet/"
sed -i "$file_devwacom" -Ee "s/\"1\"/\"$number\"/"
sed -i "$file_devwacom" -Ee "s/QEMU PenPartner tablet/Wacom PenPartner Tablet/"
sed -i "$file_devwacom" -Ee "s/QEMU PenPartner tablet/Wacom PenPartner Tablet/"
sed -i "$file_devwacom" -Ee "s/_desc   = \"QEMU PenPartner Tablet\"/_desc   = \"Wacom PenPartner Tablet\"/"
sed -i "$file_devwacom" -Ee "s/desc = \"QEMU PenPartner Tablet\"/desc = \"Wacom PenPartner Tablet\"/"

echo "  $file_u2femulated"
get_new_string $(shuf -i 5-7 -n 1) 3
echo "desc = \"QEMU U2F emulated key\"       -> desc = \"$prefix$suffix U2F emulated key\""
sed -i "$file_u2femulated" -Ee "s/desc = \"QEMU U2F emulated key\"/desc = \"$prefix$suffix U2F emulated key\"/"

echo "  $file_u2fpassthru"
get_new_string $(shuf -i 5-7 -n 1) 3
echo "desc = \"QEMU U2F passthrough key\"    -> desc = \"$prefix$suffix U2F passthrough key\""
sed -i "$file_u2fpassthru" -Ee "s/desc = \"QEMU U2F passthrough key\"/desc = \"$prefix$suffix U2F passthrough key\"/"

echo "  $file_u2f"
get_new_string $(shuf -i 5-7 -n 1) 3
number=$(get_random_dec 10)
echo "\"QEMU\",                              -> \"$prefix$suffix\","
echo "\"U2F USB key\"                        -> \"$prefix$suffix U2F USB key\""
echo "\"0\"                                  -> \"$number\""
echo "_desc   = \"QEMU U2F USB key\"         -> _desc   = \"$prefix$suffix U2F USB key\""
echo "desc           = \"QEMU U2F key\"      -> desc           = \"$prefix$suffix U2F USB key\""
sed -i "$file_u2f" -Ee "s/\"QEMU\",/\"$prefix$suffix\",/"
sed -i "$file_u2f" -Ee "s/\"U2F USB key\"/\"$prefix$suffix U2F USB key\"/"
sed -i "$file_u2f" -Ee "s/\"0\"/\"$number\"/"
sed -i "$file_u2f" -Ee "s/_desc   = \"QEMU U2F USB key\"/_desc   = \"$prefix$suffix U2F USB key\"/"
sed -i "$file_u2f" -Ee "s/desc           = \"QEMU U2F key\"/desc           = \"$prefix$suffix U2F USB key\"/"

echo "  $file_ap"
echo "hotpluggable = true                  -> hotpluggable = false"
sed -i "$file_ap" -Ee "s/hotpluggable = true/hotpluggable = false/"

echo "  $header_amlbuild"
get_new_string 6 2
app_name_6="$new_string"
get_new_string 8 3
app_name_8="$new_string"
echo "APPNAME6 \"BOCHS \"                    -> APPNAME6 \"$app_name_6\""
echo "APPNAME8 \"BXPC    \"                  -> APPNAME8 \"$app_name_8\""
sed -i "$header_amlbuild" -Ee "s/APPNAME6 \"BOCHS \"/APPNAME6 \"$app_name_6\"/"
sed -i "$header_amlbuild" -Ee "s/APPNAME8 \"BXPC    \"/APPNAME8 \"$app_name_8\"/"

echo "  $header_pci"
echo "QUMRANET    0x1af4                   -> QUMRANET    0x8086"
echo "QUMRANET 0x1af4                      -> QUMRANET 0x8086"
echo "QEMU            0x1100               -> QEMU            0x8086"
echo "REDHAT             0x1b36            -> REDHAT             0x8086"
sed -i "$header_pci" -Ee "s/QUMRANET    0x1af4/QUMRANET    0x8086/"
sed -i "$header_pci" -Ee "s/QUMRANET 0x1af4/QUMRANET 0x8086/"
sed -i "$header_pci" -Ee "s/QEMU            0x1100/QEMU            0x8086/"
sed -i "$header_pci" -Ee "s/REDHAT             0x1b36/REDHAT             0x8086/"

echo "  $header_qemufwcfg"
get_new_string 4 1
echo "QEMU0002                             -> ${new_string}0002"
echo "0x51454d5520434647ULL                -> $signature"
sed -i "$header_qemufwcfg" -Ee "s/QEMU0002/${new_string}0002/"
sed -i "$header_qemufwcfg" -Ee "s/0x51454d5520434647ULL/$signature/"

echo "  $header_optionrom"
echo "0x51454d5520434647ULL                -> $signature"
sed -i "$header_optionrom" -Ee "s/0x51454d5520434647ULL/$signature/"

echo "  $file_cpu"
if [[ "${cpu_vendor:1}" == "AuthenticAMD" ]]; then
  echo "\"QEMU Virtual CPU version \"          -> \"AMD CPU version \""
  echo "\"Common KVM processor\"               -> \"Common AMD processor\""
  echo "\"QEMU Virtual CPU version \"          -> \"AMD CPU version \""
  echo "\"Common 32-bit KVM processor\"        -> \"Common 32-bit AMD processor\""
  echo "\"QEMU Virtual CPU version \"          -> \"AMD CPU version \""
  echo "\"QEMU TCG CPU version \"              -> \"AMD CPU version \""
  sed -i "$file_cpu" -Ee "s/\"QEMU Virtual CPU version \"/\"AMD CPU version \"/"
  sed -i "$file_cpu" -Ee "s/\"Common KVM processor\"/\"Common AMD processor\"/"
  sed -i "$file_cpu" -Ee "s/\"QEMU Virtual CPU version \"/\"AMD CPU version \"/"
  sed -i "$file_cpu" -Ee "s/\"Common 32-bit KVM processor\"/\"Common 32-bit AMD processor\"/"
  sed -i "$file_cpu" -Ee "s/\"QEMU Virtual CPU version \"/\"AMD CPU version \"/"
  sed -i "$file_cpu" -Ee "s/\"QEMU TCG CPU version \"/\"AMD CPU version \"/"
else
  echo "\"QEMU Virtual CPU version \"          -> \"Intel CPU version \""
  echo "\"Common KVM processor\"               -> \"Common Intel processor\""
  echo "\"QEMU Virtual CPU version \"          -> \"Intel CPU version \""
  echo "\"Common 32-bit KVM processor\"        -> \"Common 32-bit Intel processor\""
  echo "\"QEMU Virtual CPU version \"          -> \"Intel CPU version \""
  echo "\"QEMU TCG CPU version \"              -> \"Intel CPU version \""
  sed -i "$file_cpu" -Ee "s/\"QEMU Virtual CPU version \"/\"Intel CPU version \"/"
  sed -i "$file_cpu" -Ee "s/\"Common KVM processor\"/\"Common Intel processor\"/"
  sed -i "$file_cpu" -Ee "s/\"QEMU Virtual CPU version \"/\"Intel CPU version \"/"
  sed -i "$file_cpu" -Ee "s/\"Common 32-bit KVM processor\"/\"Common 32-bit Intel processor\"/"
  sed -i "$file_cpu" -Ee "s/\"QEMU Virtual CPU version \"/\"Intel CPU version \"/"
  sed -i "$file_cpu" -Ee "s/\"QEMU TCG CPU version \"/\"Intel CPU version \"/"
fi

echo "  $file_kvm"
echo "\"Microsoft VS\"                       -> 0"
sed -i "$file_kvm" -Ee "s/\"Microsoft VS\"/\"\\\\0\\\\0\\\\0\\\\0\\\\0\\\\0\\\\0\\\\0\\\\0\\\\0\\\\0\\\\0\"/"
echo "\"VS#1\0\0\0\0\0\0\0\0\"               -> 0"
sed -i "$file_kvm" -Ee "s/\"VS#1\\\\0\\\\0\\\\0\\\\0\\\\0\\\\0\\\\0\\\\0\"/\"\\\\0\\\\0\\\\0\\\\0\\\\0\\\\0\\\\0\\\\0\\\\0\\\\0\\\\0\\\\0\"/"
echo "\"XenVMMXenVMM\"                       -> 0"
sed -i "$file_kvm" -Ee "s/\"XenVMMXenVMM\"/\"\\\\0\\\\0\\\\0\\\\0\\\\0\\\\0\\\\0\\\\0\\\\0\\\\0\\\\0\\\\0\"/"
echo "KVMKVMKVM\0\0\0                      -> ${cpu_vendor:1}"
sed -i "$file_kvm" -Ee "s/KVMKVMKVM\\\\0\\\\0\\\\0/${cpu_vendor:1}/"

echo "  $file_battery"
echo "BOCHS                                -> $app_name_6"
echo "BXPCSSDT                             -> $app_name_8"
sed -i "$file_battery" -Ee "s/BOCHS/$app_name_6/"
sed -i "$file_battery" -Ee "s/BXPCSSDT/$app_name_8/"

read -p $'Continue? [y/\e[1mN\e[0m]> ' -n 1 -r
if [[ $REPLY =~ ^[Yy]$ ]]; then
  echo ""
else
  echo ""
  exit 0
fi

cd qemu
./configure --target-list=x86_64-softmmu \
  --enable-libusb \
  --enable-usb-redir \
  --enable-spice \
  --enable-spice-protocol \
  --disable-werror
cd build
make
iasl "$file_battery"

sudo cp -f "$(pwd)/qemu-system-x86_64" "$QEMU_DEST"
sudo cp -f "$(pwd)/battery.aml" "$QEMU_DEST"
echo "$QEMU_DEST/qemu-system-x86_64"
echo "$QEMU_DEST/battery.aml"

sudo mkdir -p /usr/local/share/qemu
sudo cp -f "../pc-bios/kvmvapic.bin" "/usr/local/share/qemu/kvmvapic.bin"
sudo cp -f "../pc-bios/efi-e1000e.rom" "/usr/local/share/qemu/efi-e1000e.rom"
