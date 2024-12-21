#!/bin/bash

if [ $EUID != 0 ]; then
    sudo "$0" "$@"
    exit $?
fi

#source "/etc/libvirt/hooks/kvm.conf"
#PAGES_TARGET="$(($MEMORY/$(($(grep Hugepagesize /proc/meminfo | awk '{print $2}')/1024))))"
PAGES_TARGET="$((12288/$(($(grep Hugepagesize /proc/meminfo | awk '{print $2}')/1024))))"

PAGES_NUMBER=$(cat /proc/sys/vm/nr_hugepages)
if [ "$PAGES_NUMBER" -eq "$PAGES_TARGET" ]
then
    echo "Deallocating hugepages..."
    echo 0 > /proc/sys/vm/nr_hugepages
    exit 1
fi

echo "Allocating hugepages..."
echo "Succesfully allocated $PAGES_NUMBER / $PAGES_TARGET"
TRIES=0
while (( $PAGES_NUMBER != $PAGES_TARGET && $TRIES < 1000 ))
do
    echo 1 > /proc/sys/vm/compact_memory
    echo $PAGES_TARGET > /proc/sys/vm/nr_hugepages
    PAGES_NUMBER=$(cat /proc/sys/vm/nr_hugepages)
    echo "Succesfully allocated $PAGES_NUMBER / $PAGES_TARGET"
    let TRIES+=1
done

if [ "$PAGES_NUMBER" -ne "$PAGES_TARGET" ]
then
    echo "Deallocating hugepages..."
    echo 0 > /proc/sys/vm/nr_hugepages
    exit 1
fi
