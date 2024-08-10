#! /usr/bin/bash

if [ "$EUID" != 0 ]; then
    faillock --reset
    sudo "$0" "$@"
    exit $?
fi

rm -fr /root/Nika-Read-Only
#cd /root
#git clone https://github.com/Ape-xCV/Nika-Read-Only.git
cp -r . /root/Nika-Read-Only
mkdir /root/Nika-Read-Only/build
cd /root/Nika-Read-Only/build
cmake ..
make
cp main /root/main
cp nika.ini /root/nika.ini
chmod +x main.sh
cp main.sh /root/main.sh
cp www.txt /root/www.txt
chmod +x spoof.sh
cp spoof.sh /root/spoof.sh
cp rules /root/rules

cd /root
pwd
ls --color
