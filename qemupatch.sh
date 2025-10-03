#!/usr/bin/env bash

if [ "$EUID" != 0 ]; then
    faillock --reset
    sudo -E "$0" "$@"
    exit $?
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
  local vowel_count=0
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
  local data=$(sudo hexdump -v -e '/1 "%02X"' "/sys/firmware/dmi/entries/4-0/raw")
  t4_processor_family="${data:12:2}"
  t4_voltage="${data:34:2}"
  t4_external_clock="${data:38:2}${data:36:2}"
  t4_max_speed="${data:42:2}${data:40:2}"
  t4_current_speed="${data:46:2}${data:44:2}"
  t4_processor_upgrade="${data:50:2}"
  t4_processor_characteristics="${data:78:2}${data:76:2}"
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
#file_intelhda="$(pwd)/qemu/hw/audio/intel-hda.c"
file_escc="$(pwd)/qemu/hw/char/escc.c"
#file_serialpci="$(pwd)/qemu/hw/char/serial-pci.c"
file_edidgenerate="$(pwd)/qemu/hw/display/edid-generate.c"
#file_smbusich9="$(pwd)/qemu/hw/i2c/smbus_ich9.c"
file_acpibuild="$(pwd)/qemu/hw/i386/acpi-build.c"
file_piix="$(pwd)/qemu/hw/isa/piix.c"
file_lpcich9="$(pwd)/qemu/hw/isa/lpc_ich9.c"
file_i386_fwcfg="$(pwd)/qemu/hw/i386/fw_cfg.c"
file_multiboot="$(pwd)/qemu/hw/i386/multiboot.c"
file_pc="$(pwd)/qemu/hw/i386/pc.c"
#file_pcpiix="$(pwd)/qemu/hw/i386/pc_piix.c"
file_pcq35="$(pwd)/qemu/hw/i386/pc_q35.c"
file_atapi="$(pwd)/qemu/hw/ide/atapi.c"
file_core="$(pwd)/qemu/hw/ide/core.c"
#file_ich="$(pwd)/qemu/hw/ide/ich.c"
file_adbkbd="$(pwd)/qemu/hw/input/adb-kbd.c"
file_adbmouse="$(pwd)/qemu/hw/input/adb-mouse.c"
#file_ads7846="$(pwd)/qemu/hw/input/ads7846.c"
file_hid="$(pwd)/qemu/hw/input/hid.c"
file_ps2="$(pwd)/qemu/hw/input/ps2.c"
#file_tsc2005="$(pwd)/qemu/hw/input/tsc2005.c"
#file_tsc210x="$(pwd)/qemu/hw/input/tsc210x.c"
file_virtioinputhid="$(pwd)/qemu/hw/input/virtio-input-hid.c"
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
header_smbios="$(pwd)/qemu/include/hw/firmware/smbios.h"
header_pci="$(pwd)/qemu/include/hw/pci/pci.h"
header_pciids="$(pwd)/qemu/include/hw/pci/pci_ids.h"
header_qemufwcfg="$(pwd)/qemu/include/standard-headers/linux/qemu_fw_cfg.h"
header_optionrom="$(pwd)/qemu/pc-bios/optionrom/optionrom.h"
file_cpu="$(pwd)/qemu/target/i386/cpu.c"
file_kvm="$(pwd)/qemu/target/i386/kvm/kvm.c"
file_ssdt1="$(pwd)/qemu/ssdt1.dsl"
file_ssdt2="$(pwd)/qemu/ssdt2.dsl"

if [[ -f "$file_vhdx" ]]; then rm "$file_vhdx"; fi
if [[ -f "$file_vvfat" ]]; then rm "$file_vvfat"; fi
if [[ -f "$file_msmouse" ]]; then rm "$file_msmouse"; fi
if [[ -f "$file_wctablet" ]]; then rm "$file_wctablet"; fi
if [[ -f "$file_vhostusergpu" ]]; then rm "$file_vhostusergpu"; fi
if [[ -f "$file_amlbuild" ]]; then rm "$file_amlbuild"; fi
if [[ -f "$file_acpi_core" ]]; then rm "$file_acpi_core"; fi
if [[ -f "$file_hdacodec" ]]; then rm "$file_hdacodec"; fi
#if [[ -f "$file_intelhda" ]]; then rm "$file_intelhda"; fi
if [[ -f "$file_escc" ]]; then rm "$file_escc"; fi
#if [[ -f "$file_serialpci" ]]; then rm "$file_serialpci"; fi
if [[ -f "$file_edidgenerate" ]]; then rm "$file_edidgenerate"; fi
#if [[ -f "$file_smbusich9" ]]; then rm "$file_smbusich9"; fi
if [[ -f "$file_acpibuild" ]]; then rm "$file_acpibuild"; fi
if [[ -f "$file_piix" ]]; then rm "$file_piix"; fi
if [[ -f "$file_lpcich9" ]]; then rm "$file_lpcich9"; fi
if [[ -f "$file_i386_fwcfg" ]]; then rm "$file_i386_fwcfg"; fi
if [[ -f "$file_multiboot" ]]; then rm "$file_multiboot"; fi
if [[ -f "$file_pc" ]]; then rm "$file_pc"; fi
#if [[ -f "$file_pcpiix" ]]; then rm "$file_pcpiix"; fi
if [[ -f "$file_pcq35" ]]; then rm "$file_pcq35"; fi
if [[ -f "$file_atapi" ]]; then rm "$file_atapi"; fi
if [[ -f "$file_core" ]]; then rm "$file_core"; fi
#if [[ -f "$file_ich" ]]; then rm "$file_ich"; fi
if [[ -f "$file_adbkbd" ]]; then rm "$file_adbkbd"; fi
if [[ -f "$file_adbmouse" ]]; then rm "$file_adbmouse"; fi
#if [[ -f "$file_ads7846" ]]; then rm "$file_ads7846"; fi
if [[ -f "$file_hid" ]]; then rm "$file_hid"; fi
if [[ -f "$file_ps2" ]]; then rm "$file_ps2"; fi
#if [[ -f "$file_tsc2005" ]]; then rm "$file_tsc2005"; fi
#if [[ -f "$file_tsc210x" ]]; then rm "$file_tsc210x"; fi
if [[ -f "$file_virtioinputhid" ]]; then rm "$file_virtioinputhid"; fi
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
if [[ -f "$header_smbios" ]]; then rm "$header_smbios"; fi
if [[ -f "$header_pci" ]]; then rm "$header_pci"; fi
if [[ -f "$header_pciids" ]]; then rm "$header_pciids"; fi
if [[ -f "$header_qemufwcfg" ]]; then rm "$header_qemufwcfg"; fi
if [[ -f "$header_optionrom" ]]; then rm "$header_optionrom"; fi
if [[ -f "$file_cpu" ]]; then rm "$file_cpu"; fi
if [[ -f "$file_kvm" ]]; then rm "$file_kvm"; fi
if [[ -f "$file_ssdt1" ]]; then rm "$file_ssdt1"; fi
if [[ -f "$file_ssdt2" ]]; then rm "$file_ssdt2"; fi
mkdir -p qemu
cp -fr qemubackup/. qemu/.
#cp -f *.dsl qemu/.
cp -f *.aml qemu/.

echo "  $file_vhdx"
get_new_string $(shuf -i 5-7 -n 1) 3
echo "QEMU v                                            -> $prefix$suffix v"
sed -i "$file_vhdx" -Ee "s/QEMU v/$prefix$suffix v/"

echo "  $file_vvfat"
get_new_string 4 1
echo "QEMU VVFAT                                        -> $new_string VVFAT"
sed -i "$file_vvfat" -Ee "s/QEMU VVFAT/$new_string VVFAT/"

echo "  $file_msmouse"
echo "QEMU Microsoft Mouse                              -> Microsoft Mouse"
sed -i "$file_msmouse" -Ee "s/QEMU Microsoft Mouse/Microsoft Mouse/"

echo "  $file_wctablet"
echo "QEMU Wacom Pen Tablet                             -> Wacom Pen Tablet"
sed -i "$file_wctablet" -Ee "s/QEMU Wacom Pen Tablet/Wacom Pen Tablet/"

echo "  $file_vhostusergpu"
echo "QEMU vhost-user-gpu                               -> Intel(R) HD Graphics"
sed -i "$file_vhostusergpu" -Ee "s/QEMU vhost-user-gpu/Intel(R) HD Graphics/"

echo "  $file_amlbuild"
#chassis_type=$(sudo dmidecode --string chassis-type)
chassis_type="Desktop"
if [[ "$chassis_type" == "Desktop" ]]; then
  pm_type="1"
else
  pm_type="2"
fi
sed -i "$file_amlbuild" -e  's/build_append_int_noprefix(tbl, 0 \/\* Unspecified \*\//build_append_int_noprefix(tbl, '"$pm_type"' \/\* '"$chassis_type"' \*\//'
sed -i "$file_amlbuild" -Ee "/if \(f->rev <= 4\) \{/i\    build_append_int_noprefix(tbl, 0, 1); /* Reserved */"
get_new_string 4 1
echo "\"QEMU\"                                            -> \"$new_string\""
sed -i "$file_amlbuild" -Ee "s/\"QEMU\"/\"$new_string\"/"

echo "  $file_acpi_core"
get_new_string 6 2
app_name_6="$new_string"
get_new_string 8 3
app_name_8="$new_string"
echo "\"QEMU\0\0\0\0\1\0\"                                -> \"SSDT\0\0\0\0\2\0\""
sed -i "$file_acpi_core" -Ee "s/\"QEMU\\\\0\\\\0\\\\0\\\\0\\\\1\\\\0\"/\"SSDT\\\\0\\\\0\\\\0\\\\0\\\\2\\\\0\"/"
echo "\"QEMUQEQEMUQEMU\1\0\0\0\"                          -> \"$app_name_6$app_name_8\1\0\0\0\""
sed -i "$file_acpi_core" -Ee "s/\"QEMUQEQEMUQEMU\\\\1\\\\0\\\\0\\\\0\"/\"$app_name_6$app_name_8\\\\1\\\\0\\\\0\\\\0\"/"
echo "\"QEMU\1\0\0\0\"                                    -> \"INTL\1\0\0\0\""
sed -i "$file_acpi_core" -Ee "s/\"QEMU\\\\1\\\\0\\\\0\\\\0\"/\"INTL\\\\1\\\\0\\\\0\\\\0\"/"

echo "  $file_hdacodec"
echo "0x1af4                                            -> 0x10ec"
sed -i "$file_hdacodec" -Ee "s/0x1af4/0x10ec/"

#echo "  $file_intelhda"

echo "  $file_escc"
echo "QEMU Sun Mouse                                    -> Sun Mouse"
sed -i "$file_escc" -Ee "s/QEMU Sun Mouse/Sun Mouse/"

#echo "  $file_serialpci"

echo "  $file_edidgenerate"
get_new_string $(shuf -i 5-7 -n 1) 3
word=$(get_random_hex 4)
week=$(shuf -i 1-52 -n 1)
year=$(shuf -i 25-35 -n 1)
echo "RHT                                               -> $prefix$suffix"
echo "QEMU Monitor                                      -> $prefix$suffix Monitor"
echo "prefx = 1280                                      -> prefx = 1024"
echo "prefy = 800                                       -> prefy = 768"
echo "0x1234                                            -> 0x$word"
echo "edid[16] = 42                                     -> edid[16] = $week"
echo "edid[17] = 2014 - 1990                            -> edid[17] = $year"
sed -i "$file_edidgenerate" -Ee "s/RHT/$prefix$suffix/"
sed -i "$file_edidgenerate" -Ee "s/QEMU Monitor/$prefix$suffix Monitor/"
sed -i "$file_edidgenerate" -Ee "s/prefx = 1280/prefx = 1024/"
sed -i "$file_edidgenerate" -Ee "s/prefy = 800/prefy = 768/"
sed -i "$file_edidgenerate" -Ee "s/0x1234/0x$word/"
sed -i "$file_edidgenerate" -Ee "s/edid\[16\] = 42/edid\[16\] = $week/"
sed -i "$file_edidgenerate" -Ee "s/edid\[17\] = 2014 - 1990/edid\[17\] = $year/"

#echo "  $file_smbusich9"

echo "  $file_acpibuild"
c2=$(shuf -i 7-9 -n 1)$(get_random_hex 1)
c3=$(shuf -i 4-6 -n 1)$(get_random_hex 2)
echo ".rev = 3,                                         -> .rev = 4,"
sed -i "$file_acpibuild" -Ee "s/.rev = 3,/.rev = 4,/"
sed -i "$file_acpibuild" -Ee "s/.plvl2_lat = 0xfff/.plvl2_lat = 0x00$c2/"
sed -i "$file_acpibuild" -Ee "s/.plvl3_lat = 0xfff/.plvl3_lat = 0x0$c3/"
path=$(head /dev/urandom | tr -dc 'AEIOU' | head -c 1)$(head /dev/urandom | tr -dc 'B-DF-HJ-NP-RTV-Z' | head -c 1)
echo "S%.02X                                            -> $path%.02X"
sed -i "$file_acpibuild" -Ee "s/S%.02X/$path%.02X/"
get_new_string 2 1
echo "\"VMBS\"                                            -> \"${new_string}BS\""
echo "\"VMBus\"                                           -> \"${new_string}BUS\""
echo "\"VMBUS\"                                           -> \"${new_string}BUS\""
sed -i "$file_acpibuild" -Ee "s/\"VMBS\"/\"${new_string}BS\"/"
sed -i "$file_acpibuild" -Ee "s/\"VMBus\"/\"${new_string}BUS\"/"
sed -i "$file_acpibuild" -Ee "s/\"VMBUS\"/\"${new_string}BUS\"/"
echo "    if (i440fx) {"
echo "        sb_scope = aml_scope(\"_SB\");"
echo "    v v v v v v v"
echo "        /*"
echo "         * Emulate Windows ACPI OSYS/_OSI logic in DSDT."
echo "         * Adds Windows 2001/2006/2009/2012/2013/2015."
echo "         */"
sed -i "$file_acpibuild" -e  '/    if (i440fx) {/{n;d;}'
sed -i "$file_acpibuild" -Ee "/    if \(i440fx\) \{/a\        aml_append(sb_scope, osi);"
sed -i "$file_acpibuild" -Ee "/    if \(i440fx\) \{/a\        aml_append(osi, aml_store(aml_int(0x07DF), aml_name(\"OSYS\")));"
sed -i "$file_acpibuild" -Ee "/    if \(i440fx\) \{/a\        );"
sed -i "$file_acpibuild" -Ee "/    if \(i440fx\) \{/a\            aml_equal(aml_call1(\"_OSI\", aml_string(\"Windows 2015\")), aml_int(1))"
sed -i "$file_acpibuild" -Ee "/    if \(i440fx\) \{/a\        osi = aml_if("
sed -i "$file_acpibuild" -Ee "/    if \(i440fx\) \{/a\        aml_append(sb_scope, osi);"
sed -i "$file_acpibuild" -Ee "/    if \(i440fx\) \{/a\        aml_append(osi, aml_store(aml_int(0x07DD), aml_name(\"OSYS\")));"
sed -i "$file_acpibuild" -Ee "/    if \(i440fx\) \{/a\        );"
sed -i "$file_acpibuild" -Ee "/    if \(i440fx\) \{/a\            aml_equal(aml_call1(\"_OSI\", aml_string(\"Windows 2013\")), aml_int(1))"
sed -i "$file_acpibuild" -Ee "/    if \(i440fx\) \{/a\        osi = aml_if("
sed -i "$file_acpibuild" -Ee "/    if \(i440fx\) \{/a\        aml_append(sb_scope, osi);"
sed -i "$file_acpibuild" -Ee "/    if \(i440fx\) \{/a\        aml_append(osi, aml_store(aml_int(0x07DC), aml_name(\"OSYS\")));"
sed -i "$file_acpibuild" -Ee "/    if \(i440fx\) \{/a\        );"
sed -i "$file_acpibuild" -Ee "/    if \(i440fx\) \{/a\            aml_equal(aml_call1(\"_OSI\", aml_string(\"Windows 2012\")), aml_int(1))"
sed -i "$file_acpibuild" -Ee "/    if \(i440fx\) \{/a\        osi = aml_if("
sed -i "$file_acpibuild" -Ee "/    if \(i440fx\) \{/a\        aml_append(sb_scope, osi);"
sed -i "$file_acpibuild" -Ee "/    if \(i440fx\) \{/a\        aml_append(osi, aml_store(aml_int(0x07D9), aml_name(\"OSYS\")));"
sed -i "$file_acpibuild" -Ee "/    if \(i440fx\) \{/a\        );"
sed -i "$file_acpibuild" -Ee "/    if \(i440fx\) \{/a\            aml_equal(aml_call1(\"_OSI\", aml_string(\"Windows 2009\")), aml_int(1))"
sed -i "$file_acpibuild" -Ee "/    if \(i440fx\) \{/a\        osi = aml_if("
sed -i "$file_acpibuild" -Ee "/    if \(i440fx\) \{/a\        aml_append(sb_scope, osi);"
sed -i "$file_acpibuild" -Ee "/    if \(i440fx\) \{/a\        aml_append(osi, aml_store(aml_int(0x07D6), aml_name(\"OSYS\")));"
sed -i "$file_acpibuild" -Ee "/    if \(i440fx\) \{/a\        );"
sed -i "$file_acpibuild" -Ee "/    if \(i440fx\) \{/a\            aml_equal(aml_call1(\"_OSI\", aml_string(\"Windows 2006\")), aml_int(1))"
sed -i "$file_acpibuild" -Ee "/    if \(i440fx\) \{/a\        osi = aml_if("
sed -i "$file_acpibuild" -Ee "/    if \(i440fx\) \{/a\        aml_append(sb_scope, osi);"
sed -i "$file_acpibuild" -Ee "/    if \(i440fx\) \{/a\        aml_append(osi, aml_store(aml_int(0x07D1), aml_name(\"OSYS\")));"
sed -i "$file_acpibuild" -Ee "/    if \(i440fx\) \{/a\        );"
sed -i "$file_acpibuild" -Ee "/    if \(i440fx\) \{/a\            aml_equal(aml_call1(\"_OSI\", aml_string(\"Windows 2001\")), aml_int(1))"
sed -i "$file_acpibuild" -Ee "/    if \(i440fx\) \{/a\        Aml *osi = aml_if("
sed -i "$file_acpibuild" -Ee "/    if \(i440fx\) \{/a\        aml_append(sb_scope, aml_name_decl(\"OSYS\", aml_int(0x03E8)));"
sed -i "$file_acpibuild" -Ee "/    if \(i440fx\) \{/a\         */"
sed -i "$file_acpibuild" -Ee "/    if \(i440fx\) \{/a\         * Adds Windows 2001/2006/2009/2012/2013/2015."
sed -i "$file_acpibuild" -Ee "/    if \(i440fx\) \{/a\         * Emulate Windows ACPI OSYS/_OSI logic in DSDT."
sed -i "$file_acpibuild" -Ee "/    if \(i440fx\) \{/a\        /*"
sed -i "$file_acpibuild" -Ee "/    if \(i440fx\) \{/a\        sb_scope = aml_scope(\"_SB\");"
echo "    } else if (q35) {"
echo "        sb_scope = aml_scope(\"_SB\");"
echo "    v v v v v v v v v"
echo "        /*"
echo "         * Emulate Windows ACPI OSYS/_OSI logic in DSDT."
echo "         * Adds Windows 2001/2006/2009/2012/2013/2015."
echo "         */"
sed -i "$file_acpibuild" -e  '/    } else if (q35) {/{n;d;}'
sed -i "$file_acpibuild" -Ee "/    \} else if \(q35\) \{/a\        aml_append(sb_scope, osi);"
sed -i "$file_acpibuild" -Ee "/    \} else if \(q35\) \{/a\        aml_append(osi, aml_store(aml_int(0x07DF), aml_name(\"OSYS\")));"
sed -i "$file_acpibuild" -Ee "/    \} else if \(q35\) \{/a\        );"
sed -i "$file_acpibuild" -Ee "/    \} else if \(q35\) \{/a\            aml_equal(aml_call1(\"_OSI\", aml_string(\"Windows 2015\")), aml_int(1))"
sed -i "$file_acpibuild" -Ee "/    \} else if \(q35\) \{/a\        osi = aml_if("
sed -i "$file_acpibuild" -Ee "/    \} else if \(q35\) \{/a\        aml_append(sb_scope, osi);"
sed -i "$file_acpibuild" -Ee "/    \} else if \(q35\) \{/a\        aml_append(osi, aml_store(aml_int(0x07DD), aml_name(\"OSYS\")));"
sed -i "$file_acpibuild" -Ee "/    \} else if \(q35\) \{/a\        );"
sed -i "$file_acpibuild" -Ee "/    \} else if \(q35\) \{/a\            aml_equal(aml_call1(\"_OSI\", aml_string(\"Windows 2013\")), aml_int(1))"
sed -i "$file_acpibuild" -Ee "/    \} else if \(q35\) \{/a\        osi = aml_if("
sed -i "$file_acpibuild" -Ee "/    \} else if \(q35\) \{/a\        aml_append(sb_scope, osi);"
sed -i "$file_acpibuild" -Ee "/    \} else if \(q35\) \{/a\        aml_append(osi, aml_store(aml_int(0x07DC), aml_name(\"OSYS\")));"
sed -i "$file_acpibuild" -Ee "/    \} else if \(q35\) \{/a\        );"
sed -i "$file_acpibuild" -Ee "/    \} else if \(q35\) \{/a\            aml_equal(aml_call1(\"_OSI\", aml_string(\"Windows 2012\")), aml_int(1))"
sed -i "$file_acpibuild" -Ee "/    \} else if \(q35\) \{/a\        osi = aml_if("
sed -i "$file_acpibuild" -Ee "/    \} else if \(q35\) \{/a\        aml_append(sb_scope, osi);"
sed -i "$file_acpibuild" -Ee "/    \} else if \(q35\) \{/a\        aml_append(osi, aml_store(aml_int(0x07D9), aml_name(\"OSYS\")));"
sed -i "$file_acpibuild" -Ee "/    \} else if \(q35\) \{/a\        );"
sed -i "$file_acpibuild" -Ee "/    \} else if \(q35\) \{/a\            aml_equal(aml_call1(\"_OSI\", aml_string(\"Windows 2009\")), aml_int(1))"
sed -i "$file_acpibuild" -Ee "/    \} else if \(q35\) \{/a\        osi = aml_if("
sed -i "$file_acpibuild" -Ee "/    \} else if \(q35\) \{/a\        aml_append(sb_scope, osi);"
sed -i "$file_acpibuild" -Ee "/    \} else if \(q35\) \{/a\        aml_append(osi, aml_store(aml_int(0x07D6), aml_name(\"OSYS\")));"
sed -i "$file_acpibuild" -Ee "/    \} else if \(q35\) \{/a\        );"
sed -i "$file_acpibuild" -Ee "/    \} else if \(q35\) \{/a\            aml_equal(aml_call1(\"_OSI\", aml_string(\"Windows 2006\")), aml_int(1))"
sed -i "$file_acpibuild" -Ee "/    \} else if \(q35\) \{/a\        osi = aml_if("
sed -i "$file_acpibuild" -Ee "/    \} else if \(q35\) \{/a\        aml_append(sb_scope, osi);"
sed -i "$file_acpibuild" -Ee "/    \} else if \(q35\) \{/a\        aml_append(osi, aml_store(aml_int(0x07D1), aml_name(\"OSYS\")));"
sed -i "$file_acpibuild" -Ee "/    \} else if \(q35\) \{/a\        );"
sed -i "$file_acpibuild" -Ee "/    \} else if \(q35\) \{/a\            aml_equal(aml_call1(\"_OSI\", aml_string(\"Windows 2001\")), aml_int(1))"
sed -i "$file_acpibuild" -Ee "/    \} else if \(q35\) \{/a\        Aml *osi = aml_if("
sed -i "$file_acpibuild" -Ee "/    \} else if \(q35\) \{/a\        aml_append(sb_scope, aml_name_decl(\"OSYS\", aml_int(0x03E8)));"
sed -i "$file_acpibuild" -Ee "/    \} else if \(q35\) \{/a\         */"
sed -i "$file_acpibuild" -Ee "/    \} else if \(q35\) \{/a\         * Adds Windows 2001/2006/2009/2012/2013/2015."
sed -i "$file_acpibuild" -Ee "/    \} else if \(q35\) \{/a\         * Emulate Windows ACPI OSYS/_OSI logic in DSDT."
sed -i "$file_acpibuild" -Ee "/    \} else if \(q35\) \{/a\        /*"
sed -i "$file_acpibuild" -Ee "/    \} else if \(q35\) \{/a\        sb_scope = aml_scope(\"_SB\");"
sed -i "$file_acpibuild" -e  '/create fw_cfg node/{n;N;N;N;N;d;}'
sed -i "$file_acpibuild" -e  '/Helpful to speedup Windows guests/{n;n;N;N;N;N;N;N;N;N;N;N;N;N;N;N;N;N;N;d;}'
sed -i "$file_acpibuild" -e  '/x86ms->oem_id, x86ms->oem_table_id, &pcms->cxl_devices_state);/{n;n;N;N;d;}'
echo "    acpi_add_table(table_offsets, tables_blob);"
echo "    AcpiTable table = { .sig = \"BGRT\", .rev = 1,"
echo "        .oem_id = x86ms->oem_id, .oem_table_id = x86ms->oem_table_id };"
echo "    acpi_table_begin(&table, tables_blob);"
echo "    build_append_int_noprefix(tables_blob,0x00000000,4);"
echo "    acpi_table_end(tables->linker, &table);"
echo "    ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^"
echo "    /* RSDT is pointed to by RSDP */"
sed -i "$file_acpibuild" -Ee "/\/\* RSDT is pointed to by RSDP \*\//i\    acpi_add_table(table_offsets, tables_blob);"
sed -i "$file_acpibuild" -Ee "/\/\* RSDT is pointed to by RSDP \*\//i\    AcpiTable table = { .sig = \"BGRT\", .rev = 1,"
sed -i "$file_acpibuild" -Ee "/\/\* RSDT is pointed to by RSDP \*\//i\        .oem_id = x86ms->oem_id, .oem_table_id = x86ms->oem_table_id };"
sed -i "$file_acpibuild" -Ee "/\/\* RSDT is pointed to by RSDP \*\//i\    acpi_table_begin(&table, tables_blob);"
sed -i "$file_acpibuild" -Ee "/\/\* RSDT is pointed to by RSDP \*\//i\    build_append_int_noprefix(tables_blob,0x00000000,4);"
sed -i "$file_acpibuild" -Ee "/\/\* RSDT is pointed to by RSDP \*\//i\    acpi_table_end(tables->linker, &table);"

echo "  $file_piix"
echo ".S08.                                             -> .${path}08."
sed -i "$file_piix" -Ee "s/.S08./.${path}08./"

echo "  $file_lpcich9"
echo ".SF8.                                             -> .${path}F8."
sed -i "$file_lpcich9" -Ee "s/.SF8./.${path}F8./"

echo "  $file_i386_fwcfg"
get_new_string $(shuf -i 5-7 -n 1) 3
echo "\"QEMU\"                                            -> \"$prefix$suffix\""
sed -i "$file_i386_fwcfg" -Ee "s/\"QEMU\"/\"$prefix$suffix\"/"
#echo "#ifdef CONFIG_ACPI                              -> #if defined (CONFIG_ACPI) && false"
#sed -i "$file_i386_fwcfg" -Ee "s/#ifdef CONFIG_ACPI/#if defined (CONFIG_ACPI) \&\& false/"
get_new_string 4 1
fwcf=$new_string
echo "\"FWCF\"                                            -> \"$fwcf\""
sed -i "$file_i386_fwcfg" -Ee "s/\"FWCF\"/\"$fwcf\"/"
echo "\"QEMU0002\"                                        -> \"UEFI0002\""
sed -i "$file_i386_fwcfg" -Ee "s/\"QEMU0002\"/\"UEFI0002\"/"

echo "  $file_multiboot"
echo "\"qemu\"                                            -> \"Windows Boot Manager\""
sed -i "$file_multiboot" -Ee "s/\"qemu\"/\"Windows Boot Manager\"/"

echo "  $file_pc"
echo "\"QEMU Virtual CPU version \"                       -> \"CPU version \""
echo "\"QEMU Virtual CPU version \"                       -> \"CPU version \""
echo "\"QEMU Virtual CPU version \"                       -> \"CPU version \""
sed -i "$file_pc" -Ee "s/\"QEMU Virtual CPU version \"/\"CPU version \"/"
sed -i "$file_pc" -Ee "s/\"QEMU Virtual CPU version \"/\"CPU version \"/"
sed -i "$file_pc" -Ee "s/\"QEMU Virtual CPU version \"/\"CPU version \"/"

#echo "  $file_pcpiix"

echo "  $file_pcq35"
#index=$(shuf -i 1-${#cpu_models[@]} -n 1)
IFS=':'
cpu_vendor=( $(cat /proc/cpuinfo | grep 'vendor_id' | uniq) )
cpu_vendor="${cpu_vendor[1]}"
cpu_name=( $(cat /proc/cpuinfo | grep 'model name' | uniq) )
cpu_name="${cpu_name[1]}"
#echo "Standard PC (Q35 + ICH9, 2009)                    -> ${cpu_models[$index-1]}"
echo "m->default_nic = \"e1000e\";                        -> m->default_nic = \"rtl8139\";"
#sed -i "$file_pcq35" -Ee "s/Standard PC \(Q35 \+ ICH9, 2009\)/${cpu_models[$index-1]}/"
sed -i "$file_pcq35" -Ee "s/m->default_nic = \"e1000e\";/m->default_nic = \"rtl8139\";/"
echo "    m->alias = \"q35\";"
echo "    v v v v v v v v v v v v v v v v v v v v"
echo "    m->smbios_memory_device_size = 8 * GiB;"
sed -i "$file_pcq35" -Ee "/    m->alias = \"q35\";/a\    m->smbios_memory_device_size = 8 * GiB;"
echo "smbios_memory_device_size = 16                    -> smbios_memory_device_size = 8"
sed -i "$file_pcq35" -Ee "s/smbios_memory_device_size = 16/smbios_memory_device_size = 8/"

echo "  $file_atapi"
get_new_string 4 1
echo "\"QEMU\"                                            -> \"$new_string\""
echo "QEMU DVD-ROM                                      -> $new_string DVD-ROM"
sed -i "$file_atapi" -Ee "s/\"QEMU\"/\"$new_string\"/"
sed -i "$file_atapi" -Ee "s/QEMU DVD-ROM/$new_string DVD-ROM/"

echo "  $file_core"
echo "QEMU DVD-ROM                                      -> $new_ide_cd_model"
echo "QEMU MICRODRIVE                                   -> $new_ide_cfata_model"
echo "QEMU HARDDISK                                     -> $new_default_model"
sed -i "$file_core" -Ee "s/QEMU DVD-ROM/$new_ide_cd_model/"
sed -i "$file_core" -Ee "s/QEMU MICRODRIVE/$new_ide_cfata_model/"
sed -i "$file_core" -Ee "s/QEMU HARDDISK/$new_default_model/"

#echo "  $file_ich"

echo "  $file_adbkbd"
get_new_string $(shuf -i 5-7 -n 1) 3
echo "QEMU ADB Keyboard                                 -> $prefix$suffix ADB Keyboard"
sed -i "$file_adbkbd" -Ee "s/QEMU ADB Keyboard/$prefix$suffix ADB Keyboard/"

echo "  $file_adbmouse"
get_new_string $(shuf -i 5-7 -n 1) 3
echo "QEMU ADB Mouse                                    -> $prefix$suffix ADB Mouse"
sed -i "$file_adbmouse" -Ee "s/QEMU ADB Mouse/$prefix$suffix ADB Mouse/"

#echo "  $file_ads7846"
#get_new_string $(shuf -i 5-7 -n 1) 3
#echo "QEMU ADS7846-driven Touchscreen -> $prefix$suffix ADS7846-driven Touchscreen"

echo "  $file_hid"
get_new_string $(shuf -i 5-7 -n 1) 3
echo "QEMU HID Keyboard                                 -> $prefix$suffix HID Keyboard"
echo "QEMU HID Mouse                                    -> $prefix$suffix HID Mouse"
echo "QEMU HID Tablet                                   -> $prefix$suffix HID Tablet"
sed -i "$file_hid" -Ee "s/QEMU HID Keyboard/$prefix$suffix HID Keyboard/"
sed -i "$file_hid" -Ee "s/QEMU HID Mouse/$prefix$suffix HID Mouse/"
sed -i "$file_hid" -Ee "s/QEMU HID Tablet/$prefix$suffix HID Tablet/"

echo "  $file_ps2"
get_new_string $(shuf -i 5-7 -n 1) 3
echo "QEMU PS/2 Keyboard                                -> $prefix$suffix PS/2 Keyboard"
echo "QEMU PS/2 Mouse                                   -> $prefix$suffix PS/2 Mouse"
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
echo "QEMU Virtio Keyboard                              -> $prefix$suffix Keyboard"
echo "QEMU Virtio Mouse                                 -> $prefix$suffix Mouse"
echo "QEMU Virtio Tablet                                -> $prefix$suffix Tablet"
echo "QEMU Virtio MultiTouch                            -> $prefix$suffix MultiTouch"
sed -i "$file_virtioinputhid" -Ee "s/QEMU Virtio Keyboard/$prefix$suffix Keyboard/"
sed -i "$file_virtioinputhid" -Ee "s/QEMU Virtio Mouse/$prefix$suffix Mouse/"
sed -i "$file_virtioinputhid" -Ee "s/QEMU Virtio Tablet/$prefix$suffix Tablet/"
sed -i "$file_virtioinputhid" -Ee "s/QEMU Virtio MultiTouch/$prefix$suffix MultiTouch/"
echo "0x0627                                            -> 0x045e"
sed -i "$file_virtioinputhid" -Ee "s/0x0627/0x045e/"

echo "  $file_pvpanicisa"
echo "QEMU0001                                          -> UEFI0001"
sed -i "$file_pvpanicisa" -Ee "s/QEMU0001/UEFI0001/"

echo "  $file_ctrl"
get_new_string 4 1
echo "QEMU NVMe Ctrl                                    -> $new_string NVMe Ctrl"
sed -i "$file_ctrl" -Ee "s/QEMU NVMe Ctrl/$new_string NVMe Ctrl/"

echo "  $file_fwcfgacpi"
echo "\"FWCF\"                                            -> \"$fwcf\""
sed -i "$file_fwcfgacpi" -Ee "s/\"FWCF\"/\"$fwcf\"/"
echo "\"QEMU0002\"                                        -> \"UEFI0002\""
sed -i "$file_fwcfgacpi" -Ee "s/\"QEMU0002\"/\"UEFI0002\"/"

#signature=$(get_random_hex 16)
signature="41204D2049202020"
echo "  $file_nvram_fwcfg"
echo "0x51454d5520434647ULL                             -> 0x${signature}ULL"
sed -i "$file_nvram_fwcfg" -Ee "s/0x51454d5520434647ULL/0x${signature}ULL/"
#get_new_string 4 1
#echo "\"QEMU\"                                            -> \"$new_string\""
#sed -i "$file_nvram_fwcfg" -Ee "s/\"QEMU\"/\"$new_string\"/"

echo "  $file_gpex"
get_new_string 4 1
echo "QEMU generic PCIe host bridge                     -> $new_string generic PCIe host bridge"
sed -i "$file_gpex" -Ee "s/QEMU generic PCIe host bridge/$new_string generic PCIe host bridge/"

echo "  $file_mptconfig"
get_new_string $(shuf -i 5-7 -n 1) 3
serial=$(get_random_serial 16)
echo "QEMU MPT Fusion                                   -> $prefix$suffix MPT Fusion"
echo "\"QEMU\"                                            -> \"$prefix$suffix\""
echo "0000111122223333                                  -> $serial"
sed -i "$file_mptconfig" -Ee "s/QEMU MPT Fusion/$prefix$suffix MPT Fusion/"
sed -i "$file_mptconfig" -Ee "s/\"QEMU\"/\"$prefix$suffix\"/"
sed -i "$file_mptconfig" -Ee "s/0000111122223333/$number/"

echo "  $file_scsibus"
get_new_string 4 1
echo "\"QEMU    \"                                        -> \"$new_string    \""
echo "\"QEMU TARGET     \"                                -> \"$new_string TARGET     \""
sed -i "$file_scsibus" -Ee "s/\"QEMU    \"/\"$new_string    \"/"
sed -i "$file_scsibus" -Ee "s/\"QEMU TARGET     \"/\"$new_string TARGET     \"/"

echo "  $file_scsidisk"
get_new_string $(shuf -i 5-7 -n 1) 3
echo "\"QEMU\"                                            -> \"$new_string\""
echo "\"QEMU HARDDISK\"                                   -> \"$new_string HARDDISK\""
echo "\"QEMU CD-ROM\"                                     -> \"$new_string CD-ROM\""
sed -i "$file_scsidisk" -Ee "s/\"QEMU\"/\"$new_string\"/"
sed -i "$file_scsidisk" -Ee "s/\"QEMU HARDDISK\"/\"$new_string HARDDISK\"/"
sed -i "$file_scsidisk" -Ee "s/\"QEMU CD-ROM\"/\"$new_string CD-ROM\"/"

echo "  $file_spaprvscsi"
get_new_string 4 1
nocaps=$(echo $new_string | tr '[A-Z]' '[a-z]')
echo "\"QEMU EMPTY      \"                                -> \"$new_string EMPTY      \""
echo "\"QEMU    \"                                        -> \"$new_string    \""
echo "\"qemu\"                                            -> \"$nocaps\""
sed -i "$file_spaprvscsi" -Ee "s/\"QEMU EMPTY      \"/\"$new_string EMPTY      \"/"
sed -i "$file_spaprvscsi" -Ee "s/\"QEMU    \"/\"$new_string    \"/"
sed -i "$file_spaprvscsi" -Ee "s/\"qemu\"/\"$nocaps\"/g"

echo "  $file_smbios"
echo "static struct {"
echo "    const char *socket_designation_l1;"
echo "    const char *socket_designation_l2;"
echo "    const char *socket_designation_l3;"
#echo "    const char *socket_designation;"
echo "} type7;"
echo "^ ^ ^ ^ ^ ^ ^ ^"
echo "struct type8_instance {"
sed -i "$file_smbios" -Ee "/struct type8_instance \{/istatic struct {"
sed -i "$file_smbios" -Ee "/struct type8_instance \{/i\    const char *socket_designation_l1;"
sed -i "$file_smbios" -Ee "/struct type8_instance \{/i\    const char *socket_designation_l2;"
sed -i "$file_smbios" -Ee "/struct type8_instance \{/i\    const char *socket_designation_l3;"
#sed -i "$file_smbios" -Ee "/struct type8_instance \{/i\    const char *socket_designation;"
sed -i "$file_smbios" -Ee "/struct type8_instance \{/i} type7;\\n"
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
sed -i "$file_smbios" -Ee "/static QEnumLookup type41_kind_lookup = \{/istatic struct {"
sed -i "$file_smbios" -Ee "/static QEnumLookup type41_kind_lookup = \{/i\    const char *description;"
sed -i "$file_smbios" -Ee "/static QEnumLookup type41_kind_lookup = \{/i} type26;\\n"
sed -i "$file_smbios" -Ee "/static QEnumLookup type41_kind_lookup = \{/istatic struct {"
sed -i "$file_smbios" -Ee "/static QEnumLookup type41_kind_lookup = \{/i\    const char *description;"
sed -i "$file_smbios" -Ee "/static QEnumLookup type41_kind_lookup = \{/i} type27;\\n"
sed -i "$file_smbios" -Ee "/static QEnumLookup type41_kind_lookup = \{/istatic struct {"
sed -i "$file_smbios" -Ee "/static QEnumLookup type41_kind_lookup = \{/i\    const char *description;"
sed -i "$file_smbios" -Ee "/static QEnumLookup type41_kind_lookup = \{/i} type28;\\n"
echo "#define T7_BASE 0x700"
echo "#define T8_BASE 0x800"
echo "^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^"
echo "#define T9_BASE 0x900"
sed -i "$file_smbios" -Ee "/#define T9_BASE 0x900/i#define T7_BASE 0x700"
sed -i "$file_smbios" -Ee "/#define T9_BASE 0x900/i#define T8_BASE 0x800"
echo "#define T20_BASE 0x1400"
echo "#define T26_BASE 0x1A00"
echo "#define T27_BASE 0x1B00"
echo "#define T28_BASE 0x1C00"
echo "^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^"
echo "#define T32_BASE 0x2000"
sed -i "$file_smbios" -Ee "/#define T32_BASE 0x2000/i#define T20_BASE 0x1400"
sed -i "$file_smbios" -Ee "/#define T32_BASE 0x2000/i#define T26_BASE 0x1A00"
sed -i "$file_smbios" -Ee "/#define T32_BASE 0x2000/i#define T27_BASE 0x1B00"
sed -i "$file_smbios" -Ee "/#define T32_BASE 0x2000/i#define T28_BASE 0x1C00"
echo "uint8_t g_type4_family;"
echo "uint8_t g_type4_upgrade;"
echo "^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^"
echo "static void smbios_build_type_4_table(MachineState *ms, unsigned instance,"
sed -i "$file_smbios" -Ee "/static void smbios_build_type_4_table\(MachineState \*ms, unsigned instance,/iuint8_t g_type4_family;"
sed -i "$file_smbios" -Ee "/static void smbios_build_type_4_table\(MachineState \*ms, unsigned instance,/iuint8_t g_type4_upgrade;"
echo "    if (instance > 0)"
echo "        snprintf(sock_str, sizeof(sock_str), \"%s%2x\", type4.sock_pfx, instance + 1);"
echo "    else"
echo "        snprintf(sock_str, sizeof(sock_str), \"%s\", type4.sock_pfx);"
echo "    ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^"
echo "    SMBIOS_TABLE_SET_STR(4, socket_designation_str, sock_str);"
sed -i "$file_smbios" -e  '/type4.sock_pfx, instance);/{d;}'
sed -i "$file_smbios" -Ee "/    SMBIOS_TABLE_SET_STR\(4, socket_designation_str, sock_str\);/i\    if (instance > 0)"
sed -i "$file_smbios" -Ee "/    SMBIOS_TABLE_SET_STR\(4, socket_designation_str, sock_str\);/i\        snprintf(sock_str, sizeof(sock_str), \"%s%2x\", type4.sock_pfx, instance + 1);"
sed -i "$file_smbios" -Ee "/    SMBIOS_TABLE_SET_STR\(4, socket_designation_str, sock_str\);/i\    else"
sed -i "$file_smbios" -Ee "/    SMBIOS_TABLE_SET_STR\(4, socket_designation_str, sock_str\);/i\        snprintf(sock_str, sizeof(sock_str), \"%s\", type4.sock_pfx);"
voltage=$(shuf -i 1350-1550 -n 1)
get_type_4_data
echo "    t->processor_family = 0xfe; /* use Processor Family 2 field */"
echo "    v v v v v v v v v v v v v v v v v v v v v v v v v v v v v v v"
echo "    if (g_type4_family > 0) t->processor_family = g_type4_family;"
sed -i "$file_smbios" -Ee "/    t->processor_family = 0xfe; \/\* use Processor Family 2 field \*\//a\    if (g_type4_family > 0) t->processor_family = g_type4_family;"
echo "t->processor_family = 0xfe;                       -> t->processor_family = 0x$t4_processor_family;"
#echo "t->voltage = 0;                                   -> t->voltage = 0x$t4_voltage;"
echo "t->voltage = 0;                                   -> t->voltage = $((128 + voltage/100));"
echo "t->external_clock = cpu_to_le16(0);               -> t->external_clock = cpu_to_le16(0x$t4_external_clock);"
echo "t->max_speed = cpu_to_le16(type4.max_speed);      -> t->max_speed = cpu_to_le16(0x$t4_max_speed);"
echo "current_speed = cpu_to_le16(type4.current_speed)  -> current_speed = cpu_to_le16(0x$t4_current_speed)"
sed -i "$file_smbios" -Ee "s/t->processor_family = 0xfe;/t->processor_family = 0x$t4_processor_family;/"
#sed -i "$file_smbios" -Ee "s/t->voltage = 0;/t->voltage = 0x$t4_voltage;/"
sed -i "$file_smbios" -Ee "s/t->voltage = 0;/t->voltage = $((128 + voltage/100));/"
sed -i "$file_smbios" -Ee "s/t->external_clock = cpu_to_le16\(0\);/t->external_clock = cpu_to_le16(0x$t4_external_clock);/"
sed -i "$file_smbios" -Ee "s/t->max_speed = cpu_to_le16\(type4.max_speed\);/t->max_speed = cpu_to_le16(0x$t4_max_speed);/"
sed -i "$file_smbios" -Ee "s/current_speed = cpu_to_le16\(type4.current_speed\)/current_speed = cpu_to_le16(0x$t4_current_speed)/"
echo "    t->processor_upgrade = 0x01; /* Other */"
echo "    v v v v v v v v v v v v v v v v v v v v v v v v v v v v v v v v"
echo "    if (g_type4_upgrade > 0) t->processor_upgrade = g_type4_upgrade;"
sed -i "$file_smbios" -Ee "/    t->processor_upgrade = 0x01; \/\* Other \*\//a\    if (g_type4_upgrade > 0) t->processor_upgrade = g_type4_upgrade;"
echo "t->processor_upgrade = 0x01;                      -> t->processor_upgrade = 0x$t4_processor_upgrade;"
echo "t->processor_characteristics = cpu_to_le16(0x02); -> t->processor_characteristics = cpu_to_le16(0x$t4_processor_characteristics);"
echo "family2 = cpu_to_le16(type4.processor_family);    -> family2 = cpu_to_le16(t->processor_family);"
sed -i "$file_smbios" -Ee "s/t->processor_upgrade = 0x01;/t->processor_upgrade = 0x$t4_processor_upgrade;/"
sed -i "$file_smbios" -Ee "s/t->processor_characteristics = cpu_to_le16\(0x02\);/t->processor_characteristics = cpu_to_le16(0x$t4_processor_characteristics);/"
sed -i "$file_smbios" -Ee "s/family2 = cpu_to_le16\(type4.processor_family\);/family2 = cpu_to_le16\(t->processor_family\);/"
echo "l1_cache_handle = cpu_to_le16(0xFFFF)             -> l1_cache_handle = cpu_to_le16(T7_BASE + 1)"
echo "l2_cache_handle = cpu_to_le16(0xFFFF)             -> l2_cache_handle = cpu_to_le16(T7_BASE + 2)"
echo "l3_cache_handle = cpu_to_le16(0xFFFF)             -> l3_cache_handle = cpu_to_le16(T7_BASE + 3)"
sed -i "$file_smbios" -Ee "s/l1_cache_handle = cpu_to_le16\(0xFFFF\)/l1_cache_handle = cpu_to_le16(T7_BASE + 1)/"
sed -i "$file_smbios" -Ee "s/l2_cache_handle = cpu_to_le16\(0xFFFF\)/l2_cache_handle = cpu_to_le16(T7_BASE + 2)/"
sed -i "$file_smbios" -Ee "s/l3_cache_handle = cpu_to_le16\(0xFFFF\)/l3_cache_handle = cpu_to_le16(T7_BASE + 3)/"
echo "    SMBIOS_TABLE_SET_STR(7, socket_designation, type7.socket_designation);"
echo "    SMBIOS_BUILD_TABLE_POST;"
echo "}"
echo "^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^"
echo "static void smbios_build_type_8_table(void)"
sed -i "$file_smbios" -Ee "/static void smbios_build_type_8_table\(void\)/istatic void smbios_build_type_7_table(unsigned offset, uint8_t level, uint8_t system_cache_type, uint16_t installed_size, uint32_t installed_size_2)"
sed -i "$file_smbios" -Ee "/static void smbios_build_type_8_table\(void\)/i{"
sed -i "$file_smbios" -Ee "/static void smbios_build_type_8_table\(void\)/i\    SMBIOS_BUILD_TABLE_PRE(7, T7_BASE + offset, true); /* required */"
sed -i "$file_smbios" -Ee "/static void smbios_build_type_8_table\(void\)/i\    t->cache_configuration = 0b0000000100000000 | level; // 000000 WriteBack(01) Disabled(0) Internal(00) 0 NotSocketed(0) L1(000)"
sed -i "$file_smbios" -Ee "/static void smbios_build_type_8_table\(void\)/i\    t->maximum_cache_size = installed_size;"
sed -i "$file_smbios" -Ee "/static void smbios_build_type_8_table\(void\)/i\    t->installed_size = installed_size;"
sed -i "$file_smbios" -Ee "/static void smbios_build_type_8_table\(void\)/i\    t->supported_sram_type = 0b0000000000100000;            // 0000000000 Synchronous(1) 00000"
sed -i "$file_smbios" -Ee "/static void smbios_build_type_8_table\(void\)/i\    t->current_sram_type = 0b0000000000100000;"
sed -i "$file_smbios" -Ee "/static void smbios_build_type_8_table\(void\)/i\    t->cache_speed = 0;"
sed -i "$file_smbios" -Ee "/static void smbios_build_type_8_table\(void\)/i\    t->error_correction_type = 0x06;                        // Multi-bit ECC"
sed -i "$file_smbios" -Ee "/static void smbios_build_type_8_table\(void\)/i\    t->system_cache_type = system_cache_type;"
sed -i "$file_smbios" -Ee "/static void smbios_build_type_8_table\(void\)/i\    t->associativity = 0x06;                                // Fully Associative"
sed -i "$file_smbios" -Ee "/static void smbios_build_type_8_table\(void\)/i\    t->maximum_cache_size_2 = installed_size_2;"
sed -i "$file_smbios" -Ee "/static void smbios_build_type_8_table\(void\)/i\    t->installed_size_2 = installed_size_2;"
sed -i "$file_smbios" -Ee "/static void smbios_build_type_8_table\(void\)/i\    if      (level == 0b000) SMBIOS_TABLE_SET_STR(7, socket_designation, type7.socket_designation_l1);"
sed -i "$file_smbios" -Ee "/static void smbios_build_type_8_table\(void\)/i\    else if (level == 0b001) SMBIOS_TABLE_SET_STR(7, socket_designation, type7.socket_designation_l2);"
sed -i "$file_smbios" -Ee "/static void smbios_build_type_8_table\(void\)/i\    else if (level == 0b010) SMBIOS_TABLE_SET_STR(7, socket_designation, type7.socket_designation_l3);"
#sed -i "$file_smbios" -Ee "/static void smbios_build_type_8_table\(void\)/i\    SMBIOS_TABLE_SET_STR(7, socket_designation, type7.socket_designation);"
sed -i "$file_smbios" -Ee "/static void smbios_build_type_8_table\(void\)/i\    SMBIOS_BUILD_TABLE_POST;"
sed -i "$file_smbios" -Ee "/static void smbios_build_type_8_table\(void\)/i}\\n"
echo "SMBIOS_BUILD_TABLE_PRE(8, T0_BASE                 -> SMBIOS_BUILD_TABLE_PRE(8, T8_BASE"
sed -i "$file_smbios" -Ee "s/SMBIOS_BUILD_TABLE_PRE\(8, T0_BASE/SMBIOS_BUILD_TABLE_PRE(8, T8_BASE/"
echo "t->segment_group_number = 0xff;                   -> t->segment_group_number = cpu_to_le16(0);"
echo "t->bus_number = 0xff;                             -> t->bus_number = 0x00;"
sed -i "$file_smbios" -Ee "s/t->segment_group_number = 0xff;/t->segment_group_number = cpu_to_le16(0);/"
sed -i "$file_smbios" -Ee "s/t->bus_number = 0xff;/t->bus_number = 0x00;/"
echo "            t->device_number = 0xff;"
echo "            v v v v v v v v v v v v v v v"
echo "            if (t9->current_usage == 0x04)"
echo "                t->device_number = t9->slot_id << 3;"
sed -i "$file_smbios" -Ee "/            t->device_number = 0xff;/a\                t->device_number = t9->slot_id << 3;"
sed -i "$file_smbios" -Ee "/            t->device_number = 0xff;/a\            if (t9->current_usage == 0x04)"
echo "uint64_t start, uint64_t size)                    -> uint64_t start, uint64_t size, unsigned dimm_cnt)"
sed -i "$file_smbios" -Ee "s/uint64_t start, uint64_t size\)/uint64_t start, uint64_t size, unsigned dimm_cnt)/"
echo "partition_width = 1; /* One device per row */     -> partition_width = dimm_cnt;"
sed -i "$file_smbios" -Ee "s/partition_width = 1; \/\* One device per row \*\//partition_width = dimm_cnt;/"
echo "static void smbios_build_type_20_table(unsigned instance, uint64_t size)"
echo "{"
echo "    uint64_t start, end, start_kb, end_kb;"
echo "    SMBIOS_BUILD_TABLE_PRE(20, T20_BASE + instance, true); /* required */"
echo "    t->memory_device_handle = cpu_to_le16(T17_BASE + instance);"
echo "    t->memory_array_mapped_address_handle = cpu_to_le16(T19_BASE);"
echo "    SMBIOS_BUILD_TABLE_POST;"
echo "}"
sed -i "$file_smbios" -Ee "/static void smbios_build_type_32_table\(void\)/istatic void smbios_build_type_20_table(unsigned instance, uint64_t size)"
sed -i "$file_smbios" -Ee "/static void smbios_build_type_32_table\(void\)/i{"
sed -i "$file_smbios" -Ee "/static void smbios_build_type_32_table\(void\)/i\    uint64_t start, end, start_kb, end_kb;"
sed -i "$file_smbios" -Ee "/static void smbios_build_type_32_table\(void\)/i\    SMBIOS_BUILD_TABLE_PRE(20, T20_BASE + instance, true); /* required */"
sed -i "$file_smbios" -Ee "/static void smbios_build_type_32_table\(void\)/i\    start = instance * size;"
sed -i "$file_smbios" -Ee "/static void smbios_build_type_32_table\(void\)/i\    end = start + size - 1;"
sed -i "$file_smbios" -Ee "/static void smbios_build_type_32_table\(void\)/i\    assert(end > start);"
sed -i "$file_smbios" -Ee "/static void smbios_build_type_32_table\(void\)/i\    start_kb = start / KiB;"
sed -i "$file_smbios" -Ee "/static void smbios_build_type_32_table\(void\)/i\    end_kb = end / KiB;"
sed -i "$file_smbios" -Ee "/static void smbios_build_type_32_table\(void\)/i\    if (start_kb < UINT32_MAX && end_kb < UINT32_MAX) {"
sed -i "$file_smbios" -Ee "/static void smbios_build_type_32_table\(void\)/i\        t->starting_address = cpu_to_le32(start_kb);"
sed -i "$file_smbios" -Ee "/static void smbios_build_type_32_table\(void\)/i\        t->ending_address = cpu_to_le32(end_kb);"
sed -i "$file_smbios" -Ee "/static void smbios_build_type_32_table\(void\)/i\        t->extended_starting_address = t->extended_ending_address = cpu_to_le64(0);"
sed -i "$file_smbios" -Ee "/static void smbios_build_type_32_table\(void\)/i\    } else {"
sed -i "$file_smbios" -Ee "/static void smbios_build_type_32_table\(void\)/i\        t->starting_address = t->ending_address = cpu_to_le32(UINT32_MAX);"
sed -i "$file_smbios" -Ee "/static void smbios_build_type_32_table\(void\)/i\        t->extended_starting_address = cpu_to_le64(start);"
sed -i "$file_smbios" -Ee "/static void smbios_build_type_32_table\(void\)/i\        t->extended_ending_address = cpu_to_le64(end);"
sed -i "$file_smbios" -Ee "/static void smbios_build_type_32_table\(void\)/i\    }"
sed -i "$file_smbios" -Ee "/static void smbios_build_type_32_table\(void\)/i\    t->memory_device_handle = cpu_to_le16(T17_BASE + instance);"
sed -i "$file_smbios" -Ee "/static void smbios_build_type_32_table\(void\)/i\    t->memory_array_mapped_address_handle = cpu_to_le16(T19_BASE);"
sed -i "$file_smbios" -Ee "/static void smbios_build_type_32_table\(void\)/i\    t->partition_row_position = 0xFF; /* Unknown */"
sed -i "$file_smbios" -Ee "/static void smbios_build_type_32_table\(void\)/i\    t->interleave_position = 0; /* Not interleaved */"
sed -i "$file_smbios" -Ee "/static void smbios_build_type_32_table\(void\)/i\    t->interleaved_data_depth = 0; /* Not interleaved */"
sed -i "$file_smbios" -Ee "/static void smbios_build_type_32_table\(void\)/i\    SMBIOS_BUILD_TABLE_POST;"
sed -i "$file_smbios" -Ee "/static void smbios_build_type_32_table\(void\)/i}\\n"
rpm=$(shuf -i 1450-1850 -n 1)
temperature=$(shuf -i 350-550 -n 1)
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
sed -i "$file_smbios" -Ee "/static void smbios_build_type_32_table\(void\)/istatic void smbios_build_type_26_table(void)"
sed -i "$file_smbios" -Ee "/static void smbios_build_type_32_table\(void\)/i{"
sed -i "$file_smbios" -Ee "/static void smbios_build_type_32_table\(void\)/i\    SMBIOS_BUILD_TABLE_PRE(26, T26_BASE, true); /* required */"
sed -i "$file_smbios" -Ee "/static void smbios_build_type_32_table\(void\)/i\    t->location_and_status = 0b01100011; // OK (011) Processor (00011)"
sed -i "$file_smbios" -Ee "/static void smbios_build_type_32_table\(void\)/i\    t->maximum_value = 0x8000;           // in millivolts"
sed -i "$file_smbios" -Ee "/static void smbios_build_type_32_table\(void\)/i\    t->minimum_value = 0x8000;           // in millivolts"
sed -i "$file_smbios" -Ee "/static void smbios_build_type_32_table\(void\)/i\    t->resolution = 10;                  // in 1/10 mV"
sed -i "$file_smbios" -Ee "/static void smbios_build_type_32_table\(void\)/i\    t->tolerance = 0x8000;"
sed -i "$file_smbios" -Ee "/static void smbios_build_type_32_table\(void\)/i\    t->accuracy = 0x8000;"
sed -i "$file_smbios" -Ee "/static void smbios_build_type_32_table\(void\)/i\    t->oem_defined = 0;"
sed -i "$file_smbios" -Ee "/static void smbios_build_type_32_table\(void\)/i\    t->nominal_value = $voltage;             // in millivolts"
sed -i "$file_smbios" -Ee "/static void smbios_build_type_32_table\(void\)/i\    SMBIOS_TABLE_SET_STR(26, description, type26.description);"
sed -i "$file_smbios" -Ee "/static void smbios_build_type_32_table\(void\)/i\    SMBIOS_BUILD_TABLE_POST;"
sed -i "$file_smbios" -Ee "/static void smbios_build_type_32_table\(void\)/i}\\n"
sed -i "$file_smbios" -Ee "/static void smbios_build_type_32_table\(void\)/istatic void smbios_build_type_27_table(void)"
sed -i "$file_smbios" -Ee "/static void smbios_build_type_32_table\(void\)/i{"
sed -i "$file_smbios" -Ee "/static void smbios_build_type_32_table\(void\)/i\    SMBIOS_BUILD_TABLE_PRE(27, T27_BASE, true); /* required */"
sed -i "$file_smbios" -Ee "/static void smbios_build_type_32_table\(void\)/i\    t->temperature_probe_handle = T28_BASE;"
sed -i "$file_smbios" -Ee "/static void smbios_build_type_32_table\(void\)/i\    t->device_type_and_status = 0b01100011; // OK (011) Fan (00011)"
sed -i "$file_smbios" -Ee "/static void smbios_build_type_32_table\(void\)/i\    t->cooling_unit_group = 0;"
sed -i "$file_smbios" -Ee "/static void smbios_build_type_32_table\(void\)/i\    t->oem_defined = 0;"
sed -i "$file_smbios" -Ee "/static void smbios_build_type_32_table\(void\)/i\    t->nominal_speed = $rpm;                // in RPM"
sed -i "$file_smbios" -Ee "/static void smbios_build_type_32_table\(void\)/i\    SMBIOS_TABLE_SET_STR(27, description, type27.description);"
sed -i "$file_smbios" -Ee "/static void smbios_build_type_32_table\(void\)/i\    SMBIOS_BUILD_TABLE_POST;"
sed -i "$file_smbios" -Ee "/static void smbios_build_type_32_table\(void\)/i}\\n"
sed -i "$file_smbios" -Ee "/static void smbios_build_type_32_table\(void\)/istatic void smbios_build_type_28_table(void)"
sed -i "$file_smbios" -Ee "/static void smbios_build_type_32_table\(void\)/i{"
sed -i "$file_smbios" -Ee "/static void smbios_build_type_32_table\(void\)/i\    SMBIOS_BUILD_TABLE_PRE(28, T28_BASE, true); /* required */"
sed -i "$file_smbios" -Ee "/static void smbios_build_type_32_table\(void\)/i\    t->location_and_status = 0b01100011; // OK (011) Processor (00011)"
sed -i "$file_smbios" -Ee "/static void smbios_build_type_32_table\(void\)/i\    t->maximum_value = 1270;             // in 1/10 °C"
sed -i "$file_smbios" -Ee "/static void smbios_build_type_32_table\(void\)/i\    t->minimum_value = -550;             // in 1/10 °C"
sed -i "$file_smbios" -Ee "/static void smbios_build_type_32_table\(void\)/i\    t->resolution = 100;                 // in 1/1000 °C"
sed -i "$file_smbios" -Ee "/static void smbios_build_type_32_table\(void\)/i\    t->tolerance = 0x8000;"
sed -i "$file_smbios" -Ee "/static void smbios_build_type_32_table\(void\)/i\    t->accuracy = 0x8000;"
sed -i "$file_smbios" -Ee "/static void smbios_build_type_32_table\(void\)/i\    t->oem_defined = 0;"
sed -i "$file_smbios" -Ee "/static void smbios_build_type_32_table\(void\)/i\    t->nominal_value = $temperature;              // in 1/10 °C"
sed -i "$file_smbios" -Ee "/static void smbios_build_type_32_table\(void\)/i\    SMBIOS_TABLE_SET_STR(28, description, type28.description);"
sed -i "$file_smbios" -Ee "/static void smbios_build_type_32_table\(void\)/i\    SMBIOS_BUILD_TABLE_POST;"
sed -i "$file_smbios" -Ee "/static void smbios_build_type_32_table\(void\)/i}\\n"
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
sed -i "$file_smbios" -Ee "/    SMBIOS_SET_DEFAULT\(type17.loc_pfx, \"DIMM\"\);/i\    SMBIOS_SET_DEFAULT(type7.socket_designation_l1, \"L1 Cache\");"
sed -i "$file_smbios" -Ee "/    SMBIOS_SET_DEFAULT\(type17.loc_pfx, \"DIMM\"\);/i\    SMBIOS_SET_DEFAULT(type7.socket_designation_l2, \"L2 Cache\");"
sed -i "$file_smbios" -Ee "/    SMBIOS_SET_DEFAULT\(type17.loc_pfx, \"DIMM\"\);/i\    SMBIOS_SET_DEFAULT(type7.socket_designation_l3, \"L3 Cache\");"
echo "    SMBIOS_SET_DEFAULT(type17.bank, \"BANK\");"
echo "    ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^"
echo "    SMBIOS_SET_DEFAULT(type17.manufacturer, manufacturer);"
sed -i "$file_smbios" -Ee "/    SMBIOS_SET_DEFAULT\(type17.manufacturer, manufacturer\);/i\    SMBIOS_SET_DEFAULT(type17.bank, \"BANK\");"
echo "    SMBIOS_SET_DEFAULT(type17.manufacturer, manufacturer);"
echo "    v v v v v v v v v v v v v v v v v v v v v v v v v"
echo "    SMBIOS_SET_DEFAULT(type26.description, \"VPROBE0\");"
echo "    SMBIOS_SET_DEFAULT(type27.description, \"FAN0\");"
echo "    SMBIOS_SET_DEFAULT(type28.description, \"TPROBE0\");"
sed -i "$file_smbios" -Ee "/    SMBIOS_SET_DEFAULT\(type17.manufacturer, manufacturer\);/a\    SMBIOS_SET_DEFAULT(type28.description, \"TPROBE0\");"
sed -i "$file_smbios" -Ee "/    SMBIOS_SET_DEFAULT\(type17.manufacturer, manufacturer\);/a\    SMBIOS_SET_DEFAULT(type27.description, \"FAN0\");"
sed -i "$file_smbios" -Ee "/    SMBIOS_SET_DEFAULT\(type17.manufacturer, manufacturer\);/a\    SMBIOS_SET_DEFAULT(type26.description, \"VPROBE0\");"
echo "unsigned i, dimm_cnt, offset;                     -> unsigned i, dimm_cnt, slot_cnt, offset;"
sed -i "$file_smbios" -Ee "s/unsigned i, dimm_cnt, offset;/unsigned i, dimm_cnt, slot_cnt, offset;/"
echo "    smbios_build_type_7_table(0 ,0b000, 0x03, 0x0080, 0x00000080); // L1 Instruction 128 KiB"
echo "    smbios_build_type_7_table(1, 0b000, 0x04, 0x0080, 0x00000080); // L1 Data        128 KiB"
echo "    smbios_build_type_7_table(2, 0b001, 0x05, 0x3000, 0x00003000); // L2 Unified      12 MiB"
echo "    smbios_build_type_7_table(3, 0b010, 0x05, 0x8400, 0x80000400); // L3 Unified      64 MiB"
echo "    ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^"
echo "    smbios_build_type_8_table();"
sed -i "$file_smbios" -Ee "/    smbios_build_type_8_table\(\);/i\    smbios_build_type_7_table(0, 0b000, 0x03, 0x0080, 0x00000080); // L1 Instruction 128 KiB"
sed -i "$file_smbios" -Ee "/    smbios_build_type_8_table\(\);/i\    smbios_build_type_7_table(1, 0b000, 0x04, 0x0080, 0x00000080); // L1 Data        128 KiB"
sed -i "$file_smbios" -Ee "/    smbios_build_type_8_table\(\);/i\    smbios_build_type_7_table(2, 0b001, 0x05, 0x3000, 0x00003000); // L2 Unified      12 MiB"
sed -i "$file_smbios" -Ee "/    smbios_build_type_8_table\(\);/i\    smbios_build_type_7_table(3, 0b010, 0x05, 0x8400, 0x80000400); // L3 Unified      64 MiB"
echo "               mc->smbios_memory_device_size;"
echo "    v v v v v v v"
echo "    slot_cnt = 4;"
echo "    if (slot_cnt < dimm_cnt)"
echo "        slot_cnt = dimm_cnt;"
sed -i "$file_smbios" -Ee "/               mc->smbios_memory_device_size;/a\        slot_cnt = dimm_cnt;"
sed -i "$file_smbios" -Ee "/               mc->smbios_memory_device_size;/a\    if (slot_cnt < dimm_cnt)"
sed -i "$file_smbios" -Ee "/               mc->smbios_memory_device_size;/a\    slot_cnt = 4;"
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
sed -i "$file_smbios" -Ee "/    for \(i = 0; i < mem_array_size; i\+\+\) \{/i\    if (slot_cnt > dimm_cnt)"
sed -i "$file_smbios" -Ee "/    for \(i = 0; i < mem_array_size; i\+\+\) \{/i\        for (i = dimm_cnt; i < slot_cnt; i++)"
sed -i "$file_smbios" -Ee "/    for \(i = 0; i < mem_array_size; i\+\+\) \{/i\            smbios_build_type_17_table(i, 0);\\n"
echo "mem_array[i].length);                             -> mem_array[i].length, dimm_cnt);"
sed -i "$file_smbios" -Ee "s/mem_array\[i\].length\);/mem_array[i].length, dimm_cnt);/"
echo "    for (i = 0; i < dimm_cnt; i++)"
echo "        smbios_build_type_20_table(i, GET_DIMM_SZ);"
echo "    smbios_build_type_26_table();"
echo "    smbios_build_type_27_table();"
echo "    smbios_build_type_28_table();"
echo "    ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^"
echo "    smbios_build_type_32_table();"
sed -i "$file_smbios" -Ee "/    smbios_build_type_32_table\(\);/i\    for (i = 0; i < dimm_cnt; i++)"
sed -i "$file_smbios" -Ee "/    smbios_build_type_32_table\(\);/i\        smbios_build_type_20_table(i, GET_DIMM_SZ);\\n"
sed -i "$file_smbios" -Ee "/    smbios_build_type_32_table\(\);/i\    smbios_build_type_26_table();"
sed -i "$file_smbios" -Ee "/    smbios_build_type_32_table\(\);/i\    smbios_build_type_27_table();"
sed -i "$file_smbios" -Ee "/    smbios_build_type_32_table\(\);/i\    smbios_build_type_28_table();"
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
sed -i "$file_smbios" -Ee "/    char loc_str\[128\];/a\    char serial_str[128];"
sed -i "$file_smbios" -Ee "/    char loc_str\[128\];/a\    char bank_str[128];"
echo "total_width = cpu_to_le16(0xFFFF);                -> total_width = cpu_to_le16(64); /* 64-bit no ECC */"
echo "data_width = cpu_to_le16(0xFFFF);                 -> data_width = cpu_to_le16(64); /* 64-bit no ECC */"
echo "type17.loc_pfx, instance);                        -> type17.loc_pfx, instance % 2);"
sed -i "$file_smbios" -Ee "s/bios_starting_address_segment = cpu_to_le16\(0xE800\)/bios_starting_address_segment = cpu_to_le16(0xE000)/"
sed -i "$file_smbios" -Ee "s/t->bios_rom_size = 0/t->bios_rom_size = 0xFF/"
sed -i "$file_smbios" -Ee "s/bios_characteristics = cpu_to_le64\(0x08\)/bios_characteristics = cpu_to_le64(0x0040001330099880)/"
sed -i "$file_smbios" -Ee "s/bios_characteristics_extension_bytes\[0\] = 0/bios_characteristics_extension_bytes[0] = 0x03/"
sed -i "$file_smbios" -Ee "s/bios_characteristics_extension_bytes\[1\] = 0x14/bios_characteristics_extension_bytes[1] = 0x0D/"
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
sed -i "$file_smbios" -Ee "s/bank_locator_str, type17.bank\);/bank_locator_str, bank_str);/"
echo "memory_type = 0x07; /* RAM */                     -> memory_type = 0x18; /* DDR3 */"
echo "type_detail = cpu_to_le16(0x02); /* Other */      -> type_detail = cpu_to_le16(0x80); /* Synchronous */"
echo "    SMBIOS_TABLE_SET_STR(17, manufacturer_str, type17.manufacturer);"
echo "    v v v v v v v v v v v v v v v v v v v v v v v v v v v v"
echo "    snprintf(serial_str, 11, \"%s%d\", type17.serial, rand());"
sed -i "$file_smbios" -Ee "/    SMBIOS_TABLE_SET_STR\(17, manufacturer_str, type17.manufacturer\);/a\    snprintf(serial_str, 11, \"%s%d\", type17.serial, rand());"
echo "serial_number_str, type17.serial);                -> serial_number_str, serial_str);"
sed -i "$file_smbios" -Ee "s/serial_number_str, type17.serial\);/serial_number_str, serial_str);/"
echo "attributes = 0; /* Unknown */                     -> attributes = 0x01; /* Single rank */"
echo "minimum_voltage = cpu_to_le16(0); /* Unknown */   -> minimum_voltage = cpu_to_le16(1200);"
echo "maximum_voltage = cpu_to_le16(0); /* Unknown */   -> maximum_voltage = cpu_to_le16(1350);"
echo "configured_voltage = cpu_to_le16(0);              -> configured_voltage = cpu_to_le16(1200);"
sed -i "$file_smbios" -Ee "s/memory_type = 0x07; \/\* RAM \*\//memory_type = 0x18; \/* DDR3 *\//"
sed -i "$file_smbios" -Ee "s/type_detail = cpu_to_le16\(0x02\); \/\* Other \*\//type_detail = cpu_to_le16\(0x80\); \/* Synchronous *\//"
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
sed -i "$file_smbios" -Ee "/    size_mb = QEMU_ALIGN_UP\(size, MiB\) \/ MiB;/i\    if (size == 0) {"
sed -i "$file_smbios" -Ee "/    size_mb = QEMU_ALIGN_UP\(size, MiB\) \/ MiB;/i\        t->total_width = cpu_to_le16(0xFFFF); /* Unknown */"
sed -i "$file_smbios" -Ee "/    size_mb = QEMU_ALIGN_UP\(size, MiB\) \/ MiB;/i\        t->data_width = cpu_to_le16(0xFFFF); /* Unknown */"
sed -i "$file_smbios" -Ee "/    size_mb = QEMU_ALIGN_UP\(size, MiB\) \/ MiB;/i\        t->size = cpu_to_le16(0); /* Not installed */"
sed -i "$file_smbios" -Ee "/    size_mb = QEMU_ALIGN_UP\(size, MiB\) \/ MiB;/i\        t->form_factor = 0x02; /* Unknown */"
sed -i "$file_smbios" -Ee "/    size_mb = QEMU_ALIGN_UP\(size, MiB\) \/ MiB;/i\        t->device_set = 0; /* Not in a set */"
sed -i "$file_smbios" -Ee "/    size_mb = QEMU_ALIGN_UP\(size, MiB\) \/ MiB;/i\        snprintf(loc_str, sizeof(loc_str), \"%s %d\", type17.loc_pfx, instance % 2);"
sed -i "$file_smbios" -Ee "/    size_mb = QEMU_ALIGN_UP\(size, MiB\) \/ MiB;/i\        SMBIOS_TABLE_SET_STR(17, device_locator_str, loc_str);"
sed -i "$file_smbios" -Ee "/    size_mb = QEMU_ALIGN_UP\(size, MiB\) \/ MiB;/i\        snprintf(bank_str, sizeof(bank_str), \"%s %d\", type17.bank, instance / 2);"
sed -i "$file_smbios" -Ee "/    size_mb = QEMU_ALIGN_UP\(size, MiB\) \/ MiB;/i\        SMBIOS_TABLE_SET_STR(17, bank_locator_str, bank_str);"
sed -i "$file_smbios" -Ee "/    size_mb = QEMU_ALIGN_UP\(size, MiB\) \/ MiB;/i\        t->memory_type = 0x02; /* Unknown */"
sed -i "$file_smbios" -Ee "/    size_mb = QEMU_ALIGN_UP\(size, MiB\) \/ MiB;/i\        t->type_detail = cpu_to_le16(0x04); /* Unknown */"
sed -i "$file_smbios" -Ee "/    size_mb = QEMU_ALIGN_UP\(size, MiB\) \/ MiB;/i\        t->speed = cpu_to_le16(0); /* Unknown */"
sed -i "$file_smbios" -Ee "/    size_mb = QEMU_ALIGN_UP\(size, MiB\) \/ MiB;/i\        t->manufacturer_str = 0;"
sed -i "$file_smbios" -Ee "/    size_mb = QEMU_ALIGN_UP\(size, MiB\) \/ MiB;/i\        t->serial_number_str = 0;"
sed -i "$file_smbios" -Ee "/    size_mb = QEMU_ALIGN_UP\(size, MiB\) \/ MiB;/i\        t->asset_tag_number_str = 0;"
sed -i "$file_smbios" -Ee "/    size_mb = QEMU_ALIGN_UP\(size, MiB\) \/ MiB;/i\        t->part_number_str = 0;"
sed -i "$file_smbios" -Ee "/    size_mb = QEMU_ALIGN_UP\(size, MiB\) \/ MiB;/i\        t->attributes = 0; /* Unknown */"
sed -i "$file_smbios" -Ee "/    size_mb = QEMU_ALIGN_UP\(size, MiB\) \/ MiB;/i\        t->extended_size = cpu_to_le32(0); /* Unknown */"
sed -i "$file_smbios" -Ee "/    size_mb = QEMU_ALIGN_UP\(size, MiB\) \/ MiB;/i\        t->configured_clock_speed = 0; /* Unknown */"
sed -i "$file_smbios" -Ee "/    size_mb = QEMU_ALIGN_UP\(size, MiB\) \/ MiB;/i\        t->minimum_voltage = cpu_to_le16(0); /* Unknown */"
sed -i "$file_smbios" -Ee "/    size_mb = QEMU_ALIGN_UP\(size, MiB\) \/ MiB;/i\        t->maximum_voltage = cpu_to_le16(0); /* Unknown */"
sed -i "$file_smbios" -Ee "/    size_mb = QEMU_ALIGN_UP\(size, MiB\) \/ MiB;/i\        t->configured_voltage = cpu_to_le16(0); /* Unknown */\\n"
sed -i "$file_smbios" -Ee "/    size_mb = QEMU_ALIGN_UP\(size, MiB\) \/ MiB;/i\        SMBIOS_BUILD_TABLE_POST;"
sed -i "$file_smbios" -Ee "/    size_mb = QEMU_ALIGN_UP\(size, MiB\) \/ MiB;/i\        return;"
sed -i "$file_smbios" -Ee "/    size_mb = QEMU_ALIGN_UP\(size, MiB\) \/ MiB;/i\    }"
sed -i "$file_smbios" -Ee "/    size_mb = QEMU_ALIGN_UP\(size, MiB\) \/ MiB;/i\    t->total_width = cpu_to_le16(64); /* 64-bit no ECC */"
sed -i "$file_smbios" -Ee "/    size_mb = QEMU_ALIGN_UP\(size, MiB\) \/ MiB;/i\    t->data_width = cpu_to_le16(64); /* 64-bit no ECC */"

echo "  $file_lu"
get_new_string 4 1
echo "\"QEMU\"                                            -> \"$new_string\""
echo "\"QEMU UFS\"                                        -> \"$new_string UFS\""
sed -i "$file_lu" -Ee "s/\"QEMU\"/\"$new_string\"/"
sed -i "$file_lu" -Ee "s/\"QEMU UFS\"/\"$new_string UFS\"/"

echo "  $file_devaudio"
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
echo "\"QEMU\"                                            -> \"$prefix$suffix\""
echo "_MOUSE]    = \"QEMU USB Mouse\"                     -> _MOUSE]    = \"$prefix$suffix USB Mouse\""
echo "_TABLET]   = \"QEMU USB Tablet\"                    -> _TABLET]   = \"$prefix$suffix USB Tablet\""
echo "_KEYBOARD] = \"QEMU USB Keyboard\"                  -> _KEYBOARD] = \"$prefix$suffix USB Keyboard\""
sed -i "$file_devhid" -Ee "s/\"QEMU\"/\"$prefix$suffix\"/"
sed -i "$file_devhid" -Ee "s/_MOUSE]    = \"QEMU USB Mouse\"/_MOUSE]    = \"$prefix$suffix USB Mouse\"/"
sed -i "$file_devhid" -Ee "s/_TABLET]   = \"QEMU USB Tablet\"/_TABLET]   = \"$prefix$suffix USB Tablet\"/"
sed -i "$file_devhid" -Ee "s/_KEYBOARD] = \"QEMU USB Keyboard\"/_KEYBOARD] = \"$prefix$suffix USB Keyboard\"/"
number=$(get_random_dec 10)
echo "\"89126\"                                           -> \"$number\""
sed -i "$file_devhid" -Ee "s/\"89126\"/\"$number\"/"
number=$(get_random_dec 10)
echo "\"28754\"                                           -> \"$number\""
sed -i "$file_devhid" -Ee "s/\"28754\"/\"$number\"/"
number=$(get_random_dec 10)
echo "\"68284\"                                           -> \"$number\""
sed -i "$file_devhid" -Ee "s/\"68284\"/\"$number\"/"
echo "_desc   = \"QEMU USB Tablet\"                       -> _desc   = \"$prefix$suffix USB Tablet\""
echo "_desc   = \"QEMU USB Mouse\"                        -> _desc   = \"$prefix$suffix USB Mouse\""
echo "_desc   = \"QEMU USB Keyboard\"                     -> _desc   = \"$prefix$suffix USB Keyboard\""
sed -i "$file_devhid" -Ee "s/_desc   = \"QEMU USB Tablet\"/_desc   = \"$prefix$suffix USB Tablet\"/"
sed -i "$file_devhid" -Ee "s/_desc   = \"QEMU USB Mouse\"/_desc   = \"$prefix$suffix USB Mouse\"/"
sed -i "$file_devhid" -Ee "s/_desc   = \"QEMU USB Keyboard\"/_desc   = \"$prefix$suffix USB Keyboard\"/"
echo "0x0627                                            -> 0x045e"
sed -i "$file_devhid" -Ee "s/0x0627/0x045e/"

echo "  $file_devhub"
get_new_string $(shuf -i 5-7 -n 1) 3
number=$(get_random_dec 10)
echo "\"QEMU\"                                            -> \"$prefix$suffix\""
echo "_PRODUCT]      = \"QEMU USB Hub\"                   -> _PRODUCT]      = \"$prefix$suffix USB Hub\""
echo "\"314159\"                                          -> \"$number\""
echo "_desc   = \"QEMU USB Hub\"                          -> _desc   = \"$prefix$suffix USB Hub\""
sed -i "$file_devhub" -Ee "s/\"QEMU\"/\"$prefix$suffix\"/"
sed -i "$file_devhub" -Ee "s/_PRODUCT]      = \"QEMU USB Hub\"/_PRODUCT]      = \"$prefix$suffix USB Hub\"/"
sed -i "$file_devhub" -Ee "s/\"314159\"/\"$number\"/"
sed -i "$file_devhub" -Ee "s/_desc   = \"QEMU USB Hub\"/_desc   = \"$prefix$suffix USB Hub\"/"

echo "  $file_devmtp"
get_new_string $(shuf -i 5-7 -n 1) 3
number=$(get_random_dec 10)
echo "MTP_MANUFACTURER  \"QEMU\"                          -> MTP_MANUFACTURER  \"$prefix$suffix\""
echo "QEMU filesharing                                  -> $prefix$suffix USB MTP"
echo "\"34617\"                                           -> \"$number\""
echo "_desc   = \"QEMU USB MTP\"                          -> _desc   = \"$prefix$suffix USB MTP\""
sed -i "$file_devmtp" -Ee "s/MTP_MANUFACTURER  \"QEMU\"/MTP_MANUFACTURER  \"$prefix$suffix\"/"
sed -i "$file_devmtp" -Ee "s/QEMU filesharing/$prefix$suffix USB MTP/"
sed -i "$file_devmtp" -Ee "s/\"34617\"/\"$number\"/"
sed -i "$file_devmtp" -Ee "s/_desc   = \"QEMU USB MTP\"/_desc   = \"$prefix$suffix USB MTP\"/"

echo "  $file_devnetwork"
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
echo "\"QEMU\"                                            -> \"$prefix$suffix\""
echo "_SERIAL]  = \"QEMU USB SERIAL\"                     -> $prefix$suffix USB Serial"
echo "_BRAILLE]  = \"QEMU USB BAUM BRAILLE\"              -> $prefix$suffix USB Braille"
echo "\"1\"                                               -> \"$number\""
echo "_desc   = \"QEMU USB Serial\"                       -> _desc   = \"$prefix$suffix USB Serial\""
echo "_desc   = \"QEMU USB Braille\"                      -> _desc   = \"$prefix$suffix USB Braille\""
sed -i "$file_devserial" -Ee "s/\"QEMU\"/\"$prefix$suffix\"/"
sed -i "$file_devserial" -Ee "s/_SERIAL\]  = \"QEMU USB SERIAL\"/_SERIAL\]  = \"$prefix$suffix USB Serial\"/"
sed -i "$file_devserial" -Ee "s/_BRAILLE\] = \"QEMU USB BAUM BRAILLE\"/_BRAILLE\] = \"$prefix$suffix USB Braille\"/"
sed -i "$file_devserial" -Ee "s/\"1\"/\"$number\"/"
sed -i "$file_devserial" -Ee "s/_desc   = \"QEMU USB Serial\"/_desc   = \"$prefix$suffix USB Serial\"/"
sed -i "$file_devserial" -Ee "s/_desc   = \"QEMU USB Braille\"/_desc   = \"$prefix$suffix USB Braille\"/"

echo "  $file_devsmartcardreader"
get_new_string $(shuf -i 5-7 -n 1) 3
number=$(get_random_dec 10)
echo "_MANUFACTURER]  = \"QEMU\"                          -> _MANUFACTURER]  = \"$prefix$suffix\""
echo "_PRODUCT]       = \"QEMU USB CCID\"                 -> _PRODUCT]       = \"$prefix$suffix CCID\""
echo "_SERIALNUMBER]  = \"1\"                             -> _SERIALNUMBER]  = \"$number\""
echo "_desc   = \"QEMU USB CCID\"                         -> _desc   = \"$prefix$suffix CCID\""
sed -i "$file_devsmartcardreader" -Ee "s/_MANUFACTURER]  = \"QEMU\"/_MANUFACTURER]  = \"$prefix$suffix\"/"
sed -i "$file_devsmartcardreader" -Ee "s/_PRODUCT]       = \"QEMU USB CCID\"/_PRODUCT]       = \"$prefix$suffix USB CCID\"/"
sed -i "$file_devsmartcardreader" -Ee "s/_SERIALNUMBER]  = \"1\"/_SERIALNUMBER]  = \"$number\"/"
sed -i "$file_devsmartcardreader" -Ee "s/_desc   = \"QEMU USB CCID\"/_desc   = \"$prefix$suffix USB CCID\"/"

echo "  $file_devstorage"
get_new_string $(shuf -i 5-7 -n 1) 3
serial=$(get_random_serial 16)
echo "\"QEMU\",                                           -> \"$new_string\","
echo "QEMU USB HARDDRIVE                                -> $new_string USB HARDDISK"
echo "\"1\"                                               -> \"$serial\""
echo "_desc   = \"QEMU USB MSD\"                          -> _desc   = \"$new_string USB HARDDISK\""
sed -i "$file_devstorage" -Ee "s/\"QEMU\",/\"$new_string\",/"
sed -i "$file_devstorage" -Ee "s/QEMU USB HARDDRIVE/$new_string USB HARDDISK/"
sed -i "$file_devstorage" -Ee "s/\"1\"/\"$serial\"/"
sed -i "$file_devstorage" -Ee "s/_desc   = \"QEMU USB MSD\"/_desc   = \"$new_string USB HARDDISK\"/"

echo "  $file_devuas"
get_new_string $(shuf -i 5-7 -n 1) 3
number=$(get_random_dec 10)
echo "\"QEMU\",                                           -> \"$prefix$suffix\","
echo "USB Attached SCSI HBA                             -> $prefix$suffix USB Attached SCSI HBA"
echo "\"27842\"                                           -> \"$number\""
sed -i "$file_devuas" -Ee "s/\"QEMU\",/\"$prefix$suffix\",/"
sed -i "$file_devuas" -Ee "s/USB Attached SCSI HBA/$prefix$suffix USB Attached SCSI HBA/"
sed -i "$file_devuas" -Ee "s/\"27842\"/\"$number\"/"

echo "  $file_devwacom"
number=$(get_random_dec 10)
echo "\"QEMU\"                                            -> \"Wacom\""
echo "Wacom PenPartner                                  -> Wacom PenPartner Tablet"
echo "\"1\"                                               -> \"$number\""
echo "QEMU PenPartner tablet                            -> Wacom PenPartner Tablet"
echo "_desc   = \"QEMU PenPartner Tablet\"                -> _desc   = \"Wacom PenPartner Tablet\""
echo "desc = \"QEMU PenPartner Tablet\"                   -> desc = \"Wacom PenPartner Tablet\""
sed -i "$file_devwacom" -Ee "s/\"QEMU\"/\"Wacom\"/"
sed -i "$file_devwacom" -Ee "s/Wacom PenPartner/Wacom PenPartner Tablet/"
sed -i "$file_devwacom" -Ee "s/\"1\"/\"$number\"/"
sed -i "$file_devwacom" -Ee "s/QEMU PenPartner tablet/Wacom PenPartner Tablet/"
sed -i "$file_devwacom" -Ee "s/_desc   = \"QEMU PenPartner Tablet\"/_desc   = \"Wacom PenPartner Tablet\"/"
sed -i "$file_devwacom" -Ee "s/desc = \"QEMU PenPartner Tablet\"/desc = \"Wacom PenPartner Tablet\"/"

echo "  $file_u2femulated"
get_new_string $(shuf -i 5-7 -n 1) 3
echo "desc = \"QEMU U2F emulated key\"                    -> desc = \"$prefix$suffix U2F emulated key\""
sed -i "$file_u2femulated" -Ee "s/desc = \"QEMU U2F emulated key\"/desc = \"$prefix$suffix U2F emulated key\"/"

echo "  $file_u2fpassthru"
get_new_string $(shuf -i 5-7 -n 1) 3
echo "desc = \"QEMU U2F passthrough key\"                 -> desc = \"$prefix$suffix U2F passthrough key\""
sed -i "$file_u2fpassthru" -Ee "s/desc = \"QEMU U2F passthrough key\"/desc = \"$prefix$suffix U2F passthrough key\"/"

echo "  $file_u2f"
get_new_string $(shuf -i 5-7 -n 1) 3
number=$(get_random_dec 10)
echo "\"QEMU\",                                           -> \"$prefix$suffix\","
echo "\"U2F USB key\"                                     -> \"$prefix$suffix U2F USB key\""
echo "\"0\"                                               -> \"$number\""
echo "_desc   = \"QEMU U2F USB key\"                      -> _desc   = \"$prefix$suffix U2F USB key\""
echo "desc           = \"QEMU U2F key\"                   -> desc           = \"$prefix$suffix U2F USB key\""
sed -i "$file_u2f" -Ee "s/\"QEMU\",/\"$prefix$suffix\",/"
sed -i "$file_u2f" -Ee "s/\"U2F USB key\"/\"$prefix$suffix U2F USB key\"/"
sed -i "$file_u2f" -Ee "s/\"0\"/\"$number\"/"
sed -i "$file_u2f" -Ee "s/_desc   = \"QEMU U2F USB key\"/_desc   = \"$prefix$suffix U2F USB key\"/"
sed -i "$file_u2f" -Ee "s/desc           = \"QEMU U2F key\"/desc           = \"$prefix$suffix U2F USB key\"/"

echo "  $file_ap"
echo "hotpluggable = true                               -> hotpluggable = false"
sed -i "$file_ap" -Ee "s/hotpluggable = true/hotpluggable = false/"

echo "  $header_amlbuild"
echo "APPNAME6 \"BOCHS \"                                 -> APPNAME6 \"$app_name_6\""
echo "APPNAME8 \"BXPC    \"                               -> APPNAME8 \"$app_name_8\""
sed -i "$header_amlbuild" -Ee "s/APPNAME6 \"BOCHS \"/APPNAME6 \"$app_name_6\"/"
sed -i "$header_amlbuild" -Ee "s/APPNAME8 \"BXPC    \"/APPNAME8 \"$app_name_8\"/"

echo "  $header_smbios"
echo "/* SMBIOS type 7 - Cache Information */"
echo "struct smbios_type_7 {"
echo "} QEMU_PACKED;"
echo "^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^"
echo "/* SMBIOS type 8 - Port Connector Information */"
sed -i "$header_smbios" -Ee "/\/\* SMBIOS type 8 - Port Connector Information \*\//i/* SMBIOS type 7 - Cache Information */"
sed -i "$header_smbios" -Ee "/\/\* SMBIOS type 8 - Port Connector Information \*\//istruct smbios_type_7 {"
sed -i "$header_smbios" -Ee "/\/\* SMBIOS type 8 - Port Connector Information \*\//i\    struct smbios_structure_header header;"
sed -i "$header_smbios" -Ee "/\/\* SMBIOS type 8 - Port Connector Information \*\//i\    uint8_t socket_designation;"
sed -i "$header_smbios" -Ee "/\/\* SMBIOS type 8 - Port Connector Information \*\//i\    uint16_t cache_configuration;"
sed -i "$header_smbios" -Ee "/\/\* SMBIOS type 8 - Port Connector Information \*\//i\    uint16_t maximum_cache_size;"
sed -i "$header_smbios" -Ee "/\/\* SMBIOS type 8 - Port Connector Information \*\//i\    uint16_t installed_size;"
sed -i "$header_smbios" -Ee "/\/\* SMBIOS type 8 - Port Connector Information \*\//i\    uint16_t supported_sram_type;"
sed -i "$header_smbios" -Ee "/\/\* SMBIOS type 8 - Port Connector Information \*\//i\    uint16_t current_sram_type;"
sed -i "$header_smbios" -Ee "/\/\* SMBIOS type 8 - Port Connector Information \*\//i\    uint8_t cache_speed;"
sed -i "$header_smbios" -Ee "/\/\* SMBIOS type 8 - Port Connector Information \*\//i\    uint8_t error_correction_type;"
sed -i "$header_smbios" -Ee "/\/\* SMBIOS type 8 - Port Connector Information \*\//i\    uint8_t system_cache_type;"
sed -i "$header_smbios" -Ee "/\/\* SMBIOS type 8 - Port Connector Information \*\//i\    uint8_t associativity;"
sed -i "$header_smbios" -Ee "/\/\* SMBIOS type 8 - Port Connector Information \*\//i\    uint32_t maximum_cache_size_2;"
sed -i "$header_smbios" -Ee "/\/\* SMBIOS type 8 - Port Connector Information \*\//i\    uint32_t installed_size_2;"
sed -i "$header_smbios" -Ee "/\/\* SMBIOS type 8 - Port Connector Information \*\//i} QEMU_PACKED;\\n"
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
sed -i "$header_smbios" -Ee "/\/\* SMBIOS type 32 - System Boot Information \*\//i/* SMBIOS type 20 - Memory Device Mapped Address */"
sed -i "$header_smbios" -Ee "/\/\* SMBIOS type 32 - System Boot Information \*\//istruct smbios_type_20 {"
sed -i "$header_smbios" -Ee "/\/\* SMBIOS type 32 - System Boot Information \*\//i\    struct smbios_structure_header header;"
sed -i "$header_smbios" -Ee "/\/\* SMBIOS type 32 - System Boot Information \*\//i\    uint32_t starting_address;"
sed -i "$header_smbios" -Ee "/\/\* SMBIOS type 32 - System Boot Information \*\//i\    uint32_t ending_address;"
sed -i "$header_smbios" -Ee "/\/\* SMBIOS type 32 - System Boot Information \*\//i\    uint16_t memory_device_handle;"
sed -i "$header_smbios" -Ee "/\/\* SMBIOS type 32 - System Boot Information \*\//i\    uint16_t memory_array_mapped_address_handle;"
sed -i "$header_smbios" -Ee "/\/\* SMBIOS type 32 - System Boot Information \*\//i\    uint8_t partition_row_position;"
sed -i "$header_smbios" -Ee "/\/\* SMBIOS type 32 - System Boot Information \*\//i\    uint8_t interleave_position;"
sed -i "$header_smbios" -Ee "/\/\* SMBIOS type 32 - System Boot Information \*\//i\    uint8_t interleaved_data_depth;"
sed -i "$header_smbios" -Ee "/\/\* SMBIOS type 32 - System Boot Information \*\//i\    uint64_t extended_starting_address;"
sed -i "$header_smbios" -Ee "/\/\* SMBIOS type 32 - System Boot Information \*\//i\    uint64_t extended_ending_address;"
sed -i "$header_smbios" -Ee "/\/\* SMBIOS type 32 - System Boot Information \*\//i} QEMU_PACKED;\\n"
sed -i "$header_smbios" -Ee "/\/\* SMBIOS type 32 - System Boot Information \*\//i/* SMBIOS type 26 - Voltage Probe */"
sed -i "$header_smbios" -Ee "/\/\* SMBIOS type 32 - System Boot Information \*\//istruct smbios_type_26 {"
sed -i "$header_smbios" -Ee "/\/\* SMBIOS type 32 - System Boot Information \*\//i\    struct smbios_structure_header header;"
sed -i "$header_smbios" -Ee "/\/\* SMBIOS type 32 - System Boot Information \*\//i\    uint8_t description;"
sed -i "$header_smbios" -Ee "/\/\* SMBIOS type 32 - System Boot Information \*\//i\    uint8_t location_and_status;"
sed -i "$header_smbios" -Ee "/\/\* SMBIOS type 32 - System Boot Information \*\//i\    uint16_t maximum_value;"
sed -i "$header_smbios" -Ee "/\/\* SMBIOS type 32 - System Boot Information \*\//i\    uint16_t minimum_value;"
sed -i "$header_smbios" -Ee "/\/\* SMBIOS type 32 - System Boot Information \*\//i\    uint16_t resolution;"
sed -i "$header_smbios" -Ee "/\/\* SMBIOS type 32 - System Boot Information \*\//i\    uint16_t tolerance;"
sed -i "$header_smbios" -Ee "/\/\* SMBIOS type 32 - System Boot Information \*\//i\    uint16_t accuracy;"
sed -i "$header_smbios" -Ee "/\/\* SMBIOS type 32 - System Boot Information \*\//i\    uint32_t oem_defined;"
sed -i "$header_smbios" -Ee "/\/\* SMBIOS type 32 - System Boot Information \*\//i\    uint16_t nominal_value;"
sed -i "$header_smbios" -Ee "/\/\* SMBIOS type 32 - System Boot Information \*\//i} QEMU_PACKED;\\n"
sed -i "$header_smbios" -Ee "/\/\* SMBIOS type 32 - System Boot Information \*\//i/* SMBIOS type 27 - Cooling Device */"
sed -i "$header_smbios" -Ee "/\/\* SMBIOS type 32 - System Boot Information \*\//istruct smbios_type_27 {"
sed -i "$header_smbios" -Ee "/\/\* SMBIOS type 32 - System Boot Information \*\//i\    struct smbios_structure_header header;"
sed -i "$header_smbios" -Ee "/\/\* SMBIOS type 32 - System Boot Information \*\//i\    uint16_t temperature_probe_handle;"
sed -i "$header_smbios" -Ee "/\/\* SMBIOS type 32 - System Boot Information \*\//i\    uint8_t device_type_and_status;"
sed -i "$header_smbios" -Ee "/\/\* SMBIOS type 32 - System Boot Information \*\//i\    uint8_t cooling_unit_group;"
sed -i "$header_smbios" -Ee "/\/\* SMBIOS type 32 - System Boot Information \*\//i\    uint32_t oem_defined;"
sed -i "$header_smbios" -Ee "/\/\* SMBIOS type 32 - System Boot Information \*\//i\    uint16_t nominal_speed;"
sed -i "$header_smbios" -Ee "/\/\* SMBIOS type 32 - System Boot Information \*\//i\    uint8_t description;"
sed -i "$header_smbios" -Ee "/\/\* SMBIOS type 32 - System Boot Information \*\//i} QEMU_PACKED;\\n"
sed -i "$header_smbios" -Ee "/\/\* SMBIOS type 32 - System Boot Information \*\//i/* SMBIOS type 28 - Temperature Probe */"
sed -i "$header_smbios" -Ee "/\/\* SMBIOS type 32 - System Boot Information \*\//istruct smbios_type_28 {"
sed -i "$header_smbios" -Ee "/\/\* SMBIOS type 32 - System Boot Information \*\//i\    struct smbios_structure_header header;"
sed -i "$header_smbios" -Ee "/\/\* SMBIOS type 32 - System Boot Information \*\//i\    uint8_t description;"
sed -i "$header_smbios" -Ee "/\/\* SMBIOS type 32 - System Boot Information \*\//i\    uint8_t location_and_status;"
sed -i "$header_smbios" -Ee "/\/\* SMBIOS type 32 - System Boot Information \*\//i\    uint16_t maximum_value;"
sed -i "$header_smbios" -Ee "/\/\* SMBIOS type 32 - System Boot Information \*\//i\    uint16_t minimum_value;"
sed -i "$header_smbios" -Ee "/\/\* SMBIOS type 32 - System Boot Information \*\//i\    uint16_t resolution;"
sed -i "$header_smbios" -Ee "/\/\* SMBIOS type 32 - System Boot Information \*\//i\    uint16_t tolerance;"
sed -i "$header_smbios" -Ee "/\/\* SMBIOS type 32 - System Boot Information \*\//i\    uint16_t accuracy;"
sed -i "$header_smbios" -Ee "/\/\* SMBIOS type 32 - System Boot Information \*\//i\    uint32_t oem_defined;"
sed -i "$header_smbios" -Ee "/\/\* SMBIOS type 32 - System Boot Information \*\//i\    uint16_t nominal_value;"
sed -i "$header_smbios" -Ee "/\/\* SMBIOS type 32 - System Boot Information \*\//i} QEMU_PACKED;\\n"

echo "  $header_pci"
if [[ "${cpu_vendor:1}" == "CyrixInstead" ]]; then
#  echo "QEMU               0x1234                         -> QEMU               0x1022"
  echo "VMWARE             0x15ad                         -> VMWARE             0x1022"
  echo "QUMRANET    0x1af4                                -> QUMRANET    0x1022"
  echo "QUMRANET 0x1af4                                   -> QUMRANET 0x1022"
  echo "REDHAT             0x1b36                         -> REDHAT             0x1022"
#  sed -i "$header_pci" -Ee "s/QEMU               0x1234/QEMU               0x1022/"
  sed -i "$header_pci" -Ee "s/VMWARE             0x15ad/VMWARE             0x1022/"
  sed -i "$header_pci" -Ee "s/QUMRANET    0x1af4/QUMRANET    0x1022/"
  sed -i "$header_pci" -Ee "s/QUMRANET 0x1af4/QUMRANET 0x1022/"
  sed -i "$header_pci" -Ee "s/REDHAT             0x1b36/REDHAT             0x1022/"
else
#  echo "QEMU               0x1234                         -> QEMU               0x8086"
  echo "VMWARE             0x15ad                         -> VMWARE             0x8086"
  echo "QUMRANET    0x1af4                                -> QUMRANET    0x8086"
  echo "QUMRANET 0x1af4                                   -> QUMRANET 0x8086"
  echo "REDHAT             0x1b36                         -> REDHAT             0x8086"
#  sed -i "$header_pci" -Ee "s/QEMU               0x1234/QEMU               0x8086/"
  sed -i "$header_pci" -Ee "s/VMWARE             0x15ad/VMWARE             0x8086/"
  sed -i "$header_pci" -Ee "s/QUMRANET    0x1af4/QUMRANET    0x8086/"
  sed -i "$header_pci" -Ee "s/QUMRANET 0x1af4/QUMRANET 0x8086/"
  sed -i "$header_pci" -Ee "s/REDHAT             0x1b36/REDHAT             0x8086/"
fi

echo "  $header_pciids"
if [[ "${cpu_vendor:1}" == "CyrixInstead" ]]; then
  echo "VMWARE             0x15ad                         -> VMWARE             0x1022"
  sed -i "$header_pciids" -Ee "s/VMWARE             0x15ad/VMWARE             0x1022/"
else
  echo "VMWARE             0x15ad                         -> VMWARE             0x8086"
  sed -i "$header_pciids" -Ee "s/VMWARE             0x15ad/VMWARE             0x8086/"
fi

echo "  $header_qemufwcfg"
echo "QEMU0002                                          -> UEFI0002"
echo "0x51454d5520434647ULL                             -> 0x${signature}ULL"
sed -i "$header_qemufwcfg" -Ee "s/QEMU0002/UEFI0002/"
sed -i "$header_qemufwcfg" -Ee "s/0x51454d5520434647ULL/0x${signature}ULL/"

echo "  $header_optionrom"
echo "0x51454d5520434647ULL                             -> 0x${signature}ULL"
sed -i "$header_optionrom" -Ee "s/0x51454d5520434647ULL/0x${signature}ULL/"

echo "  $file_cpu"
echo "typedef struct X86CPUDefinition {"
echo "    v v v v v v v v v"
echo "    uint8_t t4_family;"
echo "    uint8_t t4_upgrade;"
sed -i "$file_cpu" -Ee "/typedef struct X86CPUDefinition \{/{ n;d; }"
sed -i "$file_cpu" -Ee "/typedef struct X86CPUDefinition \{/a\    uint8_t t4_upgrade;"
sed -i "$file_cpu" -Ee "/typedef struct X86CPUDefinition \{/a\    uint8_t t4_family;"
sed -i "$file_cpu" -Ee "/typedef struct X86CPUDefinition \{/a\    const char *name;"
echo "extern uint8_t g_type4_family;"
echo "extern uint8_t g_type4_upgrade;"
echo "extern char *g_type4_version;"
echo "^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^"
echo "static void x86_cpu_load_model(X86CPU *cpu, X86CPUModel *model)"
sed -i "$file_cpu" -Ee "/static void x86_cpu_load_model\(X86CPU \*cpu, X86CPUModel \*model\)/iextern uint8_t g_type4_family;"
sed -i "$file_cpu" -Ee "/static void x86_cpu_load_model\(X86CPU \*cpu, X86CPUModel \*model\)/iextern uint8_t g_type4_upgrade;"
sed -i "$file_cpu" -Ee "/static void x86_cpu_load_model\(X86CPU \*cpu, X86CPUModel \*model\)/iextern char *g_type4_version;"
echo "    g_type4_family = def->t4_family;"
echo "    g_type4_upgrade = def->t4_upgrade;"
echo "    g_type4_version = malloc(strlen(def->model_id) + 1);"
echo "    strcpy(g_type4_version, def->model_id);"
echo "    ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^"
echo "    object_property_set_str(OBJECT(cpu), \"model-id\", def->model_id,"
sed -i "$file_cpu" -Ee "/    object_property_set_str\(OBJECT\(cpu\), \"model-id\", def->model_id,/i\    g_type4_family = def->t4_family;"
sed -i "$file_cpu" -Ee "/    object_property_set_str\(OBJECT\(cpu\), \"model-id\", def->model_id,/i\    g_type4_upgrade = def->t4_upgrade;"
sed -i "$file_cpu" -Ee "/    object_property_set_str\(OBJECT\(cpu\), \"model-id\", def->model_id,/i\    g_type4_version = malloc(strlen(def->model_id) + 1);"
sed -i "$file_cpu" -Ee "/    object_property_set_str\(OBJECT\(cpu\), \"model-id\", def->model_id,/i\    strcpy(g_type4_version, def->model_id);"
if [[ "${cpu_vendor:1}" == "CyrixInstead" ]]; then
  echo "\"QEMU Virtual CPU version \"                       -> \"AMD CPU version \""
  echo "\"Common KVM processor\"                            -> \"Common AMD processor\""
  echo "\"Common 32-bit KVM processor\"                     -> \"Common 32-bit AMD processor\""
  echo "\"QEMU TCG CPU version \"                           -> \"AMD CPU version \""
  sed -i "$file_cpu" -Ee "s/\"QEMU Virtual CPU version \"/\"AMD CPU version \"/"
  sed -i "$file_cpu" -Ee "s/\"Common KVM processor\"/\"Common AMD processor\"/"
  sed -i "$file_cpu" -Ee "s/\"Common 32-bit KVM processor\"/\"Common 32-bit AMD processor\"/"
  sed -i "$file_cpu" -Ee "s/\"QEMU TCG CPU version \"/\"AMD CPU version \"/"
else
  echo "\"QEMU Virtual CPU version \"                       -> \"Intel CPU version \""
  echo "\"Common KVM processor\"                            -> \"Common Intel processor\""
  echo "\"Common 32-bit KVM processor\"                     -> \"Common 32-bit Intel processor\""
  echo "\"QEMU TCG CPU version \"                           -> \"Intel CPU version \""
  sed -i "$file_cpu" -Ee "s/\"QEMU Virtual CPU version \"/\"Intel CPU version \"/"
  sed -i "$file_cpu" -Ee "s/\"Common KVM processor\"/\"Common Intel processor\"/"
  sed -i "$file_cpu" -Ee "s/\"Common 32-bit KVM processor\"/\"Common 32-bit Intel processor\"/"
  sed -i "$file_cpu" -Ee "s/\"QEMU TCG CPU version \"/\"Intel CPU version \"/"
fi
nehalem=$(shuf -i 1-9 -n 1)
echo "        .name = \"Nehalem\","
echo ".model = 26,                                      -> .model = 30,"
echo ".stepping = 3,                                    -> .stepping = ${cpu_steppings[$nehalem-1]},"
echo "Intel Core i7 9xx (Nehalem Class Core i7)         -> ${cpu_models[$nehalem-1]}"
sed -i "$file_cpu" -Ee "/        .name = \"Nehalem\",/{ n;n;n;n; s/.model = 26,/.model = 30,/ }"
sed -i "$file_cpu" -Ee "/        .name = \"Nehalem\",/{ n;n;n;n;n; s/.stepping = 3,/.stepping = ${cpu_steppings[$nehalem-1]},/ }"
sed -i "$file_cpu" -Ee "s/Intel Core i7 9xx \(Nehalem Class Core i7\)/${cpu_models[$nehalem-1]}/"
sed -i "$file_cpu" -Ee "/        .name = \"Nehalem\",/a\        .t4_upgrade = 0x${cpu_sockets[$nehalem-1]},"
sed -i "$file_cpu" -Ee "/        .name = \"Nehalem\",/a\        .t4_family = 0x${cpu_families[$nehalem-1]},"
sed -i "$file_cpu" -Ee "s/Intel Core i7 9xx \(Nehalem Core i7, IBRS update\)/${cpu_models[$nehalem-1]}/"
sandybridge=$(shuf -i 10-22 -n 1)
echo "        .name = \"SandyBridge\","
echo ".stepping = 1,                                    -> .stepping = ${cpu_steppings[$sandybridge-1]},"
echo "Intel Xeon E312xx (Sandy Bridge)                  -> ${cpu_models[$sandybridge-1]}"
sed -i "$file_cpu" -Ee "/        .name = \"SandyBridge\",/{ n;n;n;n;n; s/.stepping = 1,/.stepping = ${cpu_steppings[$sandybridge-1]},/ }"
sed -i "$file_cpu" -Ee "s/Intel Xeon E312xx \(Sandy Bridge\)/${cpu_models[$sandybridge-1]}/"
sed -i "$file_cpu" -Ee "/        .name = \"SandyBridge\",/a\        .t4_upgrade = 0x${cpu_sockets[$sandybridge-1]},"
sed -i "$file_cpu" -Ee "/        .name = \"SandyBridge\",/a\        .t4_family = 0x${cpu_families[$sandybridge-1]},"
sed -i "$file_cpu" -Ee "s/Intel Xeon E312xx \(Sandy Bridge, IBRS update\)/${cpu_models[$sandybridge-1]}/"
haswell=$(shuf -i 23-38 -n 1)
echo "        .name = \"Westmere\","
echo ".model = 44,                                      -> .model = 60,"
echo ".stepping = 1,                                    -> .stepping = ${cpu_steppings[$haswell-1]},"
echo "Westmere E56xx/L56xx/X56xx (Nehalem-C)            -> ${cpu_models[$haswell-1]}"
sed -i "$file_cpu" -Ee "/        .name = \"Westmere\",/{ n;n;n;n; s/.model = 44,/.model = 60,/ }"
sed -i "$file_cpu" -Ee "/        .name = \"Westmere\",/{ n;n;n;n;n; s/.stepping = 1,/.stepping = ${cpu_steppings[$haswell-1]},/ }"
sed -i "$file_cpu" -Ee "s/Westmere E56xx\/L56xx\/X56xx \(Nehalem-C\)/${cpu_models[$haswell-1]}/"
sed -i "$file_cpu" -Ee "/        .name = \"Westmere\",/a\        .t4_upgrade = 0x${cpu_sockets[$haswell-1]},"
sed -i "$file_cpu" -Ee "/        .name = \"Westmere\",/a\        .t4_family = 0x${cpu_families[$haswell-1]},"
sed -i "$file_cpu" -Ee "s/Westmere E56xx\/L56xx\/X56xx \(IBRS update\)/${cpu_models[$haswell-1]}/"

echo "  $file_kvm"
echo "\"Microsoft VS\"                                    -> 0"
sed -i "$file_kvm" -Ee "s/\"Microsoft VS\"/\"\\\\0\\\\0\\\\0\\\\0\\\\0\\\\0\\\\0\\\\0\\\\0\\\\0\\\\0\\\\0\"/"
echo "\"VS#1\0\0\0\0\0\0\0\0\"                            -> 0"
sed -i "$file_kvm" -Ee "s/\"VS#1\\\\0\\\\0\\\\0\\\\0\\\\0\\\\0\\\\0\\\\0\"/\"\\\\0\\\\0\\\\0\\\\0\\\\0\\\\0\\\\0\\\\0\\\\0\\\\0\\\\0\\\\0\"/"
echo "\"XenVMMXenVMM\"                                    -> 0"
sed -i "$file_kvm" -Ee "s/\"XenVMMXenVMM\"/\"\\\\0\\\\0\\\\0\\\\0\\\\0\\\\0\\\\0\\\\0\\\\0\\\\0\\\\0\\\\0\"/"
echo "KVMKVMKVM\0\0\0                                   -> GenuineIntel"
sed -i "$file_kvm" -Ee "s/KVMKVMKVM\\\\0\\\\0\\\\0/GenuineIntel/"

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
make
#iasl "$file_ssdt1"
#iasl "$file_ssdt2"

sudo cp -f "$(pwd)/qemu-system-x86_64" "$QEMU_DEST"
sudo cp -f "$(pwd)/../ssdt1.aml" "$QEMU_DEST"
sudo cp -f "$(pwd)/../ssdt2.aml" "$QEMU_DEST"
echo "$QEMU_DEST/qemu-system-x86_64"
echo "$QEMU_DEST/ssdt1.aml"
echo "$QEMU_DEST/ssdt2.aml"

sudo mkdir -p /usr/local/share/qemu
sudo cp -f "../pc-bios/kvmvapic.bin" "/usr/local/share/qemu/kvmvapic.bin"
sudo cp -f "../pc-bios/efi-e1000e.rom" "/usr/local/share/qemu/efi-e1000e.rom"
sudo cp -f "../pc-bios/efi-rtl8139.rom" "/usr/local/share/qemu/efi-rtl8139.rom"
sudo cp -f "../pc-bios/vgabios-stdvga.bin" "/usr/local/share/qemu/vgabios-stdvga.bin"
#sudo cp -fr "../pc-bios/." "/usr/local/share/qemu/."
