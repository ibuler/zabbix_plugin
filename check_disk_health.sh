#!/bin/bash
# Author: GuangHongwei
# Email: ibuler@qq.com
# Desc: Check Disk Health Status
# Require dell server and install MegaCli tools
#

MegaCli="sudo /opt/MegaRAID/MegaCli/MegaCli64"

check_support() {
    if [ ! -f ${MegaCli#sudo} ];then
        echo 2
        return 1
    fi
    count=`$MegaCli -adpCount | grep "Controller" | awk -F: '{ print $2 }'`
    if [ "${count/./}" -gt 0 ];then
        echo 1
        return 0
    else
        echo 0
        return 1
    fi
}

check_disk_count() {
    check_support &> /dev/null
    if [ $? != '0' ];then
        echo 0
        return 1
    fi
    count=`$MegaCli -AdpAllInfo -aALL   | grep -A9 "Device Present" | grep "^[[:space:]]*$1" | awk -F: '{ print $2 }'`
    echo ${count/ /}
}

case $1 in
Support)
    check_support
    ;;
*)
    echo "Critical Failed Degraded Offline Physical Virtual Disks" | grep "$1" &> /dev/null
    if [ $? != '0' ] || [ -z "$1" ] ;then
        echo "Usage: $0 Critical Failed Degraded Offline Physical Virtual Disks Support"
    else
        check_disk_count $1
    fi
    ;;
esac
