#! /usr/bin/bash

echo -e "Restoring \e[1mudevadm\e[0m..."
mv /root/udevadm /usr/bin/udevadm
systemctl start systemd-udevd-control.socket systemd-udevd-kernel.socket systemd-udevd.service
read -p $'Restoring \e[1mudisksd\e[0m... Continue? [y/\e[1mN\e[0m]> ' -n 1 -r
if [[ $REPLY =~ ^[Yy]$ ]]; then
  echo ""
  mv /root/udisksd /usr/lib/udisks2/udisksd
else
  echo ""
fi

#udisksctl dump | grep drives
#dbus-send --system --dest=org.freedesktop.UDisks2 --type=method_call --print-reply  /org/freedesktop/UDisks2 org.freedesktop.DBus.ObjectManager.GetManagedObjects | grep by-id
