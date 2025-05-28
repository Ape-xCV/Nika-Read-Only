#!/usr/bin/env bash

if [ "$EUID" != 0 ]; then
    faillock --reset
    sudo "$0" "$@"
    exit $?
fi

CODE_DEST="/usr/share/edk2/ovmf/OVMF_CODE_4M.patched.fd"
VARS_DEST="/usr/share/edk2/ovmf/OVMF_VARS_4M.patched.fd"

numbers=(
  "01" "02" "03" "04" "05" "06" "07" "08" "09" "10" "11" "12"
)

get_random_element() {
  local array=("$@")
  echo "${array[RANDOM % ${#array[@]}]}"
}

get_random_string() { head /dev/urandom | tr -dc 'A-Z'    | head -c "$1"; }
get_random_number() { head /dev/urandom | tr -dc '0-9'    | head -c "$1"; }
get_random_serial() { head /dev/urandom | tr -dc 'A-Z0-9' | head -c "$1"; }
get_random_word()   { head /dev/urandom | tr -dc '0-9A-F' | head -c "$1"; }

mkdir -p edk2
if [[ ! -d edk2backup ]]; then
  echo -e "$(pwd)/\e[1medk2backup\e[0m does not exist, clone started..."
  git clone --recursive --single-branch --branch  edk2-stable202505 https://github.com/tianocore/edk2.git edk2backup
else
  echo -e "$(pwd)/\e[1medk2backup\e[0m found."
fi

rm edk2/MdeModulePkg/MdeModulePkg.dec
rm edk2/OvmfPkg/Bhyve/AcpiTables/Dsdt.asl
rm edk2/OvmfPkg/Bhyve/AcpiTables/Facp.aslc
rm edk2/OvmfPkg/Bhyve/AcpiTables/Hpet.aslc
rm edk2/OvmfPkg/Bhyve/AcpiTables/Madt.aslc
rm edk2/OvmfPkg/Bhyve/AcpiTables/Mcfg.aslc
rm edk2/OvmfPkg/Bhyve/AcpiTables/Platform.h
rm edk2/OvmfPkg/Bhyve/AcpiTables/Spcr.aslc
rm edk2/OvmfPkg/Bhyve/BhyveRfbDxe/VbeShim.c
rm edk2/OvmfPkg/Bhyve/BhyveX64.dsc
rm edk2/OvmfPkg/Bhyve/SmbiosPlatformDxe/SmbiosPlatformDxe.c
#rm edk2/OvmfPkg/Include/IndustryStandard/Q35MchIch9.h
#rm edk2/OvmfPkg/QemuVideoDxe/Driver.c
rm edk2/ShellPkg/ShellPkg.dec
cp -fr edk2backup/. edk2/.


file_MdeModulePkg="$(pwd)/edk2/MdeModulePkg/MdeModulePkg.dec"
file_Dsdt="$(pwd)/edk2/OvmfPkg/Bhyve/AcpiTables/Dsdt.asl"
file_Facp="$(pwd)/edk2/OvmfPkg/Bhyve/AcpiTables/Facp.aslc"
file_Hpet="$(pwd)/edk2/OvmfPkg/Bhyve/AcpiTables/Hpet.aslc"
file_Madt="$(pwd)/edk2/OvmfPkg/Bhyve/AcpiTables/Madt.aslc"
file_Mcfg="$(pwd)/edk2/OvmfPkg/Bhyve/AcpiTables/Mcfg.aslc"
file_Platform="$(pwd)/edk2/OvmfPkg/Bhyve/AcpiTables/Platform.h"
file_Spcr="$(pwd)/edk2/OvmfPkg/Bhyve/AcpiTables/Spcr.aslc"
file_VbeShim="$(pwd)/edk2/OvmfPkg/Bhyve/BhyveRfbDxe/VbeShim.c"
file_BhyveX64="$(pwd)/edk2/OvmfPkg/Bhyve/BhyveX64.dsc"
file_SmbiosPlatformDxe="$(pwd)/edk2/OvmfPkg/Bhyve/SmbiosPlatformDxe/SmbiosPlatformDxe.c"
#file_Q35MchIch9="$(pwd)/edk2/OvmfPkg/Include/IndustryStandard/Q35MchIch9.h"
#file_Driver="$(pwd)/edk2/OvmfPkg/QemuVideoDxe/Driver.c"
file_ShellPkg="$(pwd)/edk2/ShellPkg/ShellPkg.dec"


echo "  $file_MdeModulePkg"
echo "\"EDK II\"                             -> \"American Megatrends Inc.\""
echo "\"INTEL \"                             -> \"ALASKA\""
echo "0x20202020324B4445                   -> 0x20202049204D2041" #"    2KDE","   I M A"
sed -i "$file_MdeModulePkg" -Ee "s/\"EDK II\"/\"American Megatrends Inc.\"/"
sed -i "$file_MdeModulePkg" -Ee "s/\"INTEL \"/\"ALASKA\"/"
sed -i "$file_MdeModulePkg" -Ee "s/0x20202020324B4445/0x20202049204D2041/"

echo "  $file_Dsdt"
echo "\"BHYVE\"                              -> \"ALASKA\""
echo "\"BVDSDT\"                             -> \"A M I   \""
sed -i "$file_Dsdt" -Ee "s/\"BHYVE\"/\"ALASKA\"/"
sed -i "$file_Dsdt" -Ee "s/\"BVDSDT\"/\"A M I   \"/"

echo "  $file_Facp"
echo "'B','V','F','A','C','P',' ',' '      -> 'A',' ','M',' ','I',' ',' ',' '"
sed -i "$file_Facp" -Ee "s/'B','V','F','A','C','P',' ',' '/'A',' ','M',' ','I',' ',' ',' '/"

echo "  $file_Hpet"
echo "'B','V','H','P','E','T',' ',' '      -> 'A',' ','M',' ','I',' ',' ',' '"
sed -i "$file_Hpet" -Ee "s/'B','V','H','P','E','T',' ',' '/'A',' ','M',' ','I',' ',' ',' '/"

echo "  $file_Madt"
echo "'B','V','M','A','D','T',' ',' '      -> 'A',' ','M',' ','I',' ',' ',' '"
sed -i "$file_Madt" -Ee "s/'B','V','M','A','D','T',' ',' '/'A',' ','M',' ','I',' ',' ',' '/"

echo "  $file_Mcfg"
echo "'B','V','M','C','F','G',' ',' '      -> 'A',' ','M',' ','I',' ',' ',' '"
sed -i "$file_Mcfg" -Ee "s/'B','V','M','C','F','G',' ',' '/'A',' ','M',' ','I',' ',' ',' '/"

echo "  $file_Platform"
echo "'B','H','Y','V','E',' '              -> 'A','L','A','S','K','A'"
echo "'B','H','Y','V'                      -> 'A','M','I',' '"
sed -i "$file_Platform" -Ee "s/'B','H','Y','V','E',' '/'A','L','A','S','K','A'/"
sed -i "$file_Platform" -Ee "s/'B','H','Y','V'/'A','M','I',' '/"

echo "  $file_Spcr"
echo "'B','V','S','P','C','R',' ',' '      -> 'A',' ','M',' ','I',' ',' ',' '"
sed -i "$file_Spcr" -Ee "s/'B','V','S','P','C','R',' ',' '/'A',' ','M',' ','I',' ',' ',' '/"

echo "  $file_VbeShim"
echo "\"FBSD\"                               -> \"UEFI\""
echo "\"FBSD\"                               -> \"UEFI\""
sed -i "$file_VbeShim" -Ee "s/\"FBSD\"/\"UEFI\"/"
sed -i "$file_VbeShim" -Ee "s/\"FBSD\"/\"UEFI\"/"

echo "  $file_BhyveX64"
echo "\"BHYVE\"                              -> \"ALASKA\""
sed -i "$file_BhyveX64" -Ee "s/\"BHYVE\"/\"ALASKA\"/"

echo "  $file_SmbiosPlatformDxe"
version="$(shuf -i 1-9 -n 1).$(shuf -i 10-99 -n 1)"
day="$(get_random_element "${numbers[@]}")"
month="$(get_random_element "${numbers[@]}")"
year="$(shuf -i 2015-2025 -n 1)"
echo "\"EFI Development Kit II / OVMF\\0\"    -> \"American Megatrends Inc.\\0\""
echo "\"0.0.0\\0\"                            -> \"$version\\0\""
echo "\"02/06/2015\\0\"                       -> \"${day}/${month}/${year}\\0\""
sed -i "$file_SmbiosPlatformDxe" -Ee "s/\"EFI Development Kit II \/ OVMF\\\\0\"/\"American Megatrends Inc.\\\\0\"/"
sed -i "$file_SmbiosPlatformDxe" -Ee "s/\"0.0.0\\\\0\"/\"$version\\\\0\"/"
sed -i "$file_SmbiosPlatformDxe" -Ee "s/\"02\/06\/2015\\\\0\"/\"${day}\/${month}\/${year}\\\\0\"/"

#echo "  $file_Q35MchIch9"
#if [[ "${cpu_vendor:1}" == "AuthenticAMD" ]]; then
#  echo "0x29C0                               -> 0x1480"
#  sed -i "$file_Q35MchIch9" -Ee "s/0x29C0/0x1480/"
#else
#  echo "0x29C0                               -> 0x4641"
#  sed -i "$file_Q35MchIch9" -Ee "s/0x29C0/0x4641/"
#fi

#echo "  $file_Driver"
#IFS=':'
#cpu_vendor=( $(cat /proc/cpuinfo | grep 'vendor_id' | uniq) )
#cpu_vendor="${cpu_vendor[1]}"
#if [[ "${cpu_vendor:1}" == "AuthenticAMD" ]]; then
#  echo "0x1234                               -> 0x1022"
#  echo "0x1234                               -> 0x1022"
#  echo "0x1b36                               -> 0x1022"
#  echo "0x1af4                               -> 0x1022"
#  echo "0x15ad                               -> 0x1022"
#  sed -i "$file_Driver" -Ee "s/0x1234/0x1022/"
#  sed -i "$file_Driver" -Ee "s/0x1234/0x1022/"
#  sed -i "$file_Driver" -Ee "s/0x1b36/0x1022/"
#  sed -i "$file_Driver" -Ee "s/0x1af4/0x1022/"
#  sed -i "$file_Driver" -Ee "s/0x15ad/0x1022/"
#else
#  echo "0x1234                               -> 0x8086"
#  echo "0x1234                               -> 0x8086"
#  echo "0x1b36                               -> 0x8086"
#  echo "0x1af4                               -> 0x8086"
#  echo "0x15ad                               -> 0x8086"
#  sed -i "$file_Driver" -Ee "s/0x1234/0x8086/"
#  sed -i "$file_Driver" -Ee "s/0x1234/0x8086/"
#  sed -i "$file_Driver" -Ee "s/0x1b36/0x8086/"
#  sed -i "$file_Driver" -Ee "s/0x1af4/0x8086/"
#  sed -i "$file_Driver" -Ee "s/0x15ad/0x8086/"
#fi

echo "  $file_ShellPkg"
echo "\"EDK II\"                             -> \"American Megatrends Inc.\""
  sed -i "$file_ShellPkg" -Ee "s/\"EDK II\"/\"American Megatrends Inc.\"/"

read -p $'Continue? [y/\e[1mN\e[0m]> ' -n 1 -r
if [[ $REPLY =~ ^[Yy]$ ]]; then
  echo ""
else
  echo ""
  exit 0
fi

cd edk2
export WORKSPACE="$(pwd)"
export EDK_TOOLS_PATH="${WORKSPACE}/BaseTools"
export CONF_PATH="${WORKSPACE}/Conf"

echo "Building BaseTools (EDK II build tools)..."
make -C BaseTools; source edksetup.sh

echo "Compiling OVMF firmware with Secure Boot and TPM support..."
build \
  -a X64 \
  -p OvmfPkg/OvmfPkgX64.dsc \
  -b RELEASE \
  -t GCC5 \
  -n 0 \
  -s \
  -q \
  --define SECURE_BOOT_ENABLE=TRUE \
  --define TPM_CONFIG_ENABLE=TRUE \
  --define TPM_ENABLE=TRUE \
  --define TPM1_ENABLE=TRUE \
  --define TPM2_ENABLE=TRUE

echo "$CODE_DEST"
echo "$VARS_DEST"
cp -f "Build/OvmfX64/RELEASE_GCC5/FV/OVMF_CODE.fd" "$CODE_DEST"
cp -f "Build/OvmfX64/RELEASE_GCC5/FV/OVMF_VARS.fd" "$VARS_DEST"
#qemu-img convert -f raw -O qcow2 "Build/OvmfX64/RELEASE_GCC5/FV/OVMF_CODE.fd" "$CODE_DEST"
#qemu-img convert -f raw -O qcow2 "Build/OvmfX64/RELEASE_GCC5/FV/OVMF_VARS.fd" "$VARS_DEST"
