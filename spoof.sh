#! /usr/bin/bash

ip link set wlan0 down
macchanger -r wlan0
ip link set wlan0 up

serial=$(LC_ALL=C tr -dc A-F0-9 </dev/urandom | head -c 16)
wwid=${serial,,}
model=$(LC_ALL=C tr -dc A-Z0-9 </dev/urandom | head -c 7)
number=$(($RANDOM % 3))
if [[ $number -eq 0 ]]; then
  model="KINGDIAN ${model}"
elif [[ $number -eq 1 ]]; then
  model="KINGFAST ${model}"
else
  model="KINGSPEC ${model}"
fi

serial2=$(LC_ALL=C tr -dc A-F0-9 </dev/urandom | head -c 16)
wwid2=${serial2,,}
model2=$(LC_ALL=C tr -dc A-Z0-9 </dev/urandom | head -c 7)
number=$(($RANDOM % 3))
if [[ $number -eq 0 ]]; then
  model2="KINGDIAN ${model2}"
elif [[ $number -eq 1 ]]; then
  model2="KINGFAST ${model2}"
else
  model2="KINGSPEC ${model2}"
fi

serial3=$(LC_ALL=C tr -dc A-F0-9 </dev/urandom | head -c 16)
wwid3=${serial3,,}
model3=$(LC_ALL=C tr -dc A-Z0-9 </dev/urandom | head -c 7)
number=$(($RANDOM % 3))
if [[ $number -eq 0 ]]; then
  model3="KINGDIAN ${model3}"
elif [[ $number -eq 1 ]]; then
  model3="KINGFAST ${model3}"
else
  model3="KINGSPEC ${model3}"
fi

head -37 rules > new.txt
echo "ATTRS{serial}==\"?*\",       ENV{ID_SERIAL_SHORT}=\"${serial}\"" >> new.txt
echo "ATTRS{wwid}==\"?*\",         ENV{ID_WWN}=\"${wwid}\"" >> new.txt
echo "ATTRS{model}==\"?*\",        ENV{ID_MODEL}=\"${model}\"" >> new.txt
tail -n +41 rules | head -20 >> new.txt
echo "##KERNEL==\"sd*[!0-9]|sr*\", ENV{ID_SERIAL}!=\"?*\", SUBSYSTEMS==\"scsi\", ATTRS{vendor}==\"ATA\", IMPORT{program}=\"ata_id --export \$devnode\"" >> new.txt
echo "##KERNEL==\"sd*[!0-9]|sr*\", ENV{ID_BUS}==\"ata\", ENV{ID_ATA_PERIPHERAL_DEVICE_TYPE}==\"20\", PROGRAM=\"scsi_id -u -g \$devnode\", \\" >> new.txt
echo "##  SYMLINK+=\"disk/by-id/scsi-\$result\$env{.PART_SUFFIX}\"" >> new.txt
echo "KERNEL==\"sda\" \\" >> new.txt
echo ",          ENV{ID_BUS}=\"ata\" \\" >> new.txt
echo ", ENV{ID_SERIAL_SHORT}=\"${serial2}\" \\" >> new.txt
echo ",          ENV{ID_WWN}=\"${wwid2}\" \\" >> new.txt
echo ",        ENV{ID_MODEL}=\"${model2}\" \\" >> new.txt
echo ",       ENV{ID_SERIAL}=\"${model2} ${serial2}\"" >> new.txt
echo "KERNEL==\"sdb\" \\" >> new.txt
echo ",          ENV{ID_BUS}=\"ata\" \\" >> new.txt
echo ", ENV{ID_SERIAL_SHORT}=\"${serial3}\" \\" >> new.txt
echo ",          ENV{ID_WWN}=\"${wwid3}\" \\" >> new.txt
echo ",        ENV{ID_MODEL}=\"${model3}\" \\" >> new.txt
echo ",       ENV{ID_SERIAL}=\"${model3} ${serial3}\"" >> new.txt
# tail -n +64 rules | head -84 >> new.txt
# tail -15 rules >> new.txt
tail -112 rules >> new.txt

if [[ ! -f /lib/udev/rules.d/60-persistent-storage.rules_ ]]; then
  echo -e "Backup /lib/udev/rules.d/\e[1m60-persistent-storage.rules_\e[0m does not exist, creating..."
  cp /lib/udev/rules.d/60-persistent-storage.rules /lib/udev/rules.d/60-persistent-storage.rules_
else
  echo -e "Backup /lib/udev/rules.d/\e[1m60-persistent-storage.rules_\e[0m found."
fi

read -p $'Spoofing \e[1m60-persistent-storage.rules\e[0m... Continue? [y/\e[1mN\e[0m]> ' -n 1 -r
if [[ $REPLY =~ ^[Yy]$ ]]; then
  echo ""
  cp new.txt /lib/udev/rules.d/60-persistent-storage.rules
  read -p $'Reboot? [\e[1mY\e[0m/n]> ' -n 1 -r
  if [[ $REPLY =~ ^[Nn]$ ]]; then
    echo ""
  else
    echo ""
    reboot
  fi
else
  echo ""
fi
