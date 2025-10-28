#!/usr/bin/env bash

if [ "$EUID" != 0 ]; then
    faillock --reset
    sudo -E "$0" "$@"
    exit $?
fi

TKG_URL="https://github.com/Frogging-Family/linux-tkg.git"
TKG_DIR="linux-tkg"
TKG_CFG="${TKG_DIR}/customization.cfg"
KERNEL_MAJOR="6"
KERNEL_MINOR="16"
KERNEL_VERSION="${KERNEL_MAJOR}.${KERNEL_MINOR}-latest"

if [[ ! -d ${TKG_DIR} ]]; then
  echo -e "$(pwd)/\e[1m${TKG_DIR}\e[0m does not exist, clone started..."
  git clone --single-branch --branch "master" "${TKG_URL}" "${TKG_DIR}"
else
  echo -e "$(pwd)/\e[1m${TKG_DIR}\e[0m found."
fi

declare -A config_values=(
  [_distro]=""
  [_version]="6.16-latest"
  [_menunconfig]="false"
  [_diffconfig]="false"
  [_cpusched]="eevdf"
  [_compiler]="gcc"
  [_sched_yield_type]="0"
  [_tickless]="1"
  [_acs_override]="false"
  [_glitched_base]="false"
  [_zenify]="false"
  [_compileroptlevel]="1"
  [_processor_opt]=""
  [_timer_freq]="1000"
  [_clear_patches]="false"
  [_openrgb]="false"
  [_install_after_building]="yes"
  [_fsync_backport]="false"
  [_fsync_legacy]="false"
  [_zfsfix]="false"
  [_user_patches_no_confirm]="true"
)

for key in "${!config_values[@]}"; do
  sed -i "s|$key=\"[^\"]*\"|$key=\"${config_values[$key]}\"|" "$TKG_CFG"
done

mkdir -p "${TKG_DIR}/linux${KERNEL_MAJOR}${KERNEL_MINOR}-tkg-userpatches"
IFS=':'
cpu_vendor=( $(cat /proc/cpuinfo | grep 'vendor_id' | uniq) )
cpu_vendor="${cpu_vendor[1]}"
if [[ "${cpu_vendor:1}" == "AuthenticAMD" ]]; then
  cp -f "amd616.mypatch" "${TKG_DIR}/linux${KERNEL_MAJOR}${KERNEL_MINOR}-tkg-userpatches/."
else
  cp -f "intel616.mypatch" "${TKG_DIR}/linux${KERNEL_MAJOR}${KERNEL_MINOR}-tkg-userpatches/."
fi

if [[ -d ${TKG_DIR}/RPMS ]]; then
  read -p $'Uninstall previous patch? [\e[1mY\e[0m/n]> ' -n 1 -r
  if [[ $REPLY =~ ^[Nn]$ ]]; then
    echo ""
    exit 0
  else
    echo ""
    cd ${TKG_DIR}/RPMS
    ls *.rpm | grep -v headers | sed 's/.rpm//' | while read line; do sudo rpm -e $line; done
    cd -
  fi
fi

#read -p $'Continue? [y/\e[1mN\e[0m]> ' -n 1 -r
#if [[ $REPLY =~ ^[Yy]$ ]]; then
#  echo ""
#else
#  echo ""
#  exit 0
#fi

cd "$TKG_DIR"
chmod +x "install.sh"
./install.sh install
