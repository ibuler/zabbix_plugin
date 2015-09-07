#!/bin/bash
# Author: Guanghongwei
# Date: 2014/12/25
#

cwdir=`dirname $0`
. $cwdir/function.sh

mount_discovery() {
    partition=($(grep -v '^#' $check_list | grep "^mount:" | awk '{ print $2 }'))
    discovery ${partition[@]}
}

check_mount() {
    target_dir=$(grep -v '^#' $check_list | grep "^mount:" | grep $1 | awk '{ print $3}' )
    mount | awk '{ print $1, $3 }' | grep $1 | grep $target_dir &> /dev/null && echo 1 || echo 0
}

case $1 in
discovery)
    mount_discovery;;
*)
    if [ -z "$1"  -o  "$1" == '-h' ];then
        echo $1
        msg="Usage: $0 discovery | dev"
        echo $msg
    else
        check_mount $1
    fi
    ;;

esac
