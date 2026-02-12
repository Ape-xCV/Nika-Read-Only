#!/usr/bin/env bash

if [ $(tty | grep /dev/tty1) ]; then
  #Xvfb :1 -screen 0 1024x768x16 &
  Xorg :1 -config dummy.conf -noreset +extension GLX +extension RANDR +extension RENDER &
  sleep 3
  x11vnc -display :1 -rfbport 5900 -forever &
  sleep 3

  ip addr
  export DISPLAY=:1
  startlxde
  #mate-session
fi
