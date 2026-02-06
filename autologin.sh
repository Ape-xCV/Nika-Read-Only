#!/usr/bin/env bash

if [ "$EUID" != 0 ]; then
    faillock --reset
    sudo -E "$0" "$USER"
    exit $?
fi

if [ "$1" == "" ]; then exit 0; fi
file="/etc/systemd/system/getty@tty1.service.d/autologin.conf"
mkdir -p "/etc/systemd/system/getty@tty1.service.d"
echo "[Service]" > "$file"
echo "ExecStart=" >> "$file"
echo "ExecStart=/sbin/mingetty tty1 --autologin "$1" --noclear" >> "$file"
echo $file
systemctl enable getty@tty1.service
