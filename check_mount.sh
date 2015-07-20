#!/bin/bash
# Author: Guanghongwei
# Date: 2014/12/25
#

cwdir=`dirname $0`
. $cwdir/function.sh

check_mount() {
    mount | awk '{ print $1, $3 }' | grep $1 | grep $2 &> /dev/null && echo 1 || echo 0
}


if [ -z "$1"  -o -z "$2" -o "$1" == '-h' ];then
    msg="Usage: $0 dev target_dir"
    echo $msg
else
    check_mount $1 $2
fi
