#!/bin/bash 
#
# Author: Guanghongwei
# Mail: ibuler@qq.com

cwdir=`dirname $0`
. $cwdir/function.sh

log=${2:-/var/log/message}
tmpfile=$tmp_dir/.$(str_md5 $url).zbx

log_discovery () { 
    logs=($(grep -v "^#" $check_list | grep '^log:' | awk '{ print $2 }' )) 
    discovery ${logs[@]}
}


case "$1" in 
discovery) 
    log_discovery
    ;; 
count) 
    #count $log $3
    awk -v status=${3} '$11 == status' $log | wc -l
    ;; 
total)
    wc -l $log | awk '{ print $1 }'
    ;;
error)
    awk '$11 !~ 20. && $11 !~ 30. ' $log | grep -v 'favicon' | grep -v 'Alibaba' |  wc -l
    ;;
50x)
    awk '$11 ~ 50. ' $log | wc -l
    ;;
*) 
    echo "Usage:$0 {discovery | count logfile code | error logfile | total logfile" 
;; 
esac
