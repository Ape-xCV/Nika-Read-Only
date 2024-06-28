#! /usr/bin/bash

systemctl stop systemd-udevd-control.socket systemd-udevd-kernel.socket systemd-udevd.service
#mv /usr/bin/udevadm /root/udevadm
echo -e "Disabling \e[1mudisksd\e[0m..."
mv /usr/lib/udisks2/udisksd /root/udisksd

rm -fr /dev/disk/by-id
mkdir /dev/disk/by-id
exa --icons /dev/disk

ip link set wlan0 down
macchanger -r wlan0
ip link set wlan0 up

read -p $'Disabling \e[1mudevadm\e[0m... Continue? [y/\e[1mN\e[0m]> ' -n 1 -r
if [[ $REPLY =~ ^[Yy]$ ]]; then
  echo ""
  read -p $'Are you sure? [y/\e[1mN\e[0m]> ' -n 1 -r
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo ""
    mv /usr/bin/udevadm /root/udevadm
  else
    echo ""
  fi
else
  echo ""
fi
