#! /usr/bin/bash

systemctl stop systemd-udevd-control.socket systemd-udevd-kernel.socket systemd-udevd.service
#mv /usr/bin/udevadm /root/udevadm
echo -e "Disabling \e[1mudisksd\e[0m..."
mv /usr/lib/udisks2/udisksd /root/udisksd

rm -fr /dev/disk/by-id
mkdir /dev/disk/by-id
if [[ ! -f /usr/bin/eza ]]; then
  echo /dev/disk/by-id
  ls -al /dev/disk/by-id
else
  eza --icons /dev/disk
fi

ip link set wlan0 down
macchanger -r wlan0
ip link set wlan0 up

#read -p $'Disabling \e[1mudevadm\e[0m... Continue? [y/\e[1mN\e[0m]> ' -n 1 -r
#if [[ $REPLY =~ ^[Yy]$ ]]; then
#  echo ""
#  read -p $'Are you sure? [y/\e[1mN\e[0m]> ' -n 1 -r
#  if [[ $REPLY =~ ^[Yy]$ ]]; then
#    echo ""
#    mv /usr/bin/udevadm /root/udevadm
#  else
#    echo ""
#  fi
#else
#  echo ""
#fi

echo -e "Disabling \e[1mudevadm\e[0m..."
chmod 700 /usr/bin/udevadm
echo -e "Disabling \e[1mnvidia-smi\e[0m..."
chmod 700 /usr/bin/nvidia-smi
