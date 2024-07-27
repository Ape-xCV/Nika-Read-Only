#! /usr/bin/bash

#if [[ $WINDOWID -gt 0 ]]; then
#  xfconf-query -c thunar -n -p /misc-exec-shell-scripts-by-default -s true -t bool
#  echo "$BASH_SOURCE"
#else
#  xfce4-terminal --title "Steam" --command="$BASH_SOURCE"
#  exit
#fi

if [[ -z "$(ls -A /dev/disk/by-id)" ]]; then
  dbus-send --system --dest=org.freedesktop.UDisks2 --type=method_call --print-reply  /org/freedesktop/UDisks2 org.freedesktop.DBus.ObjectManager.GetManagedObjects | grep by-id
  if [[ $? -eq 1 ]]; then
    echo SAFE TO RUN /usr/bin/steam-runtime
  fi
else
  ls /dev/disk/by-id
fi

#read -p "Press any key to continue . . . " -n 1 -r
