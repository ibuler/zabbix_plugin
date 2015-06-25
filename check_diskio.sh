#!/bin/bash
# Author: Guanghongwei
# Date: 2014/12/25
#

cwdir=`dirname $0`
. $cwdir/function.sh

diskstates="/proc/diskstats"
disk=${2:-"sda"}

disk_discovery() {
    disks=($(cat /proc/diskstats | awk '{ print $3 }' | grep '[a-z]d[a-z]$'))
    discovery ${disks[@]}
}

read_ops() {
    cat /proc/diskstats | grep $1 | head -1 | awk '{print $4}'
}

write_ops() {
    cat /proc/diskstats | grep $1 | head -1 | awk '{print $8}'
}

read_sector() {
    cat /proc/diskstats | grep $1 | head -1 | awk '{print $6}'
}

write_sector() {
    cat /proc/diskstats | grep $1 | head -1 | awk '{print $10}'
}

case $1 in
discovery)
    disk_discovery
    ;;
*)
    if `echo "read_ops write_ops read_sector write_sector" | grep $1 &> /dev/null`;then
        $1 $disk
    else
        msg="Usage: $0 discovery | read_ops | write_ops | read_sector | write_sector"
        echo $msg
    fi
    ;;
esac
