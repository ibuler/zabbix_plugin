#!/bin/bash
# Script_name: check_process.sh
# Author: Guanghongwei
# Date: 2014/12/25

cwdir=`dirname $0`
. $cwdir/function.sh

min_num_default=1
max_num_default=30

proc_discovery() {
    procs=($(grep -v '^#' $check_list | grep '^proc:' | awk '{ print $2 }'))
    discovery ${procs[@]}
}

proc_num() {
    cur_num=$(ps axu | grep $1 | egrep -v 'grep|vim|check_proc' | wc -l)
    echo $cur_num
}

proc_status() {
    proc=$1
    min_num=$(grep $proc $check_list | grep "^proc" | awk '{ print $3 }')
    max_num=$(grep $proc $check_list | grep "^proc" | awk '{ print $4 }')
    min_num=${min_num:=$min_num_default}
    max_num=${max_num:=$max_num_default}
    cur_num=$(proc_num $proc)

    if [ "$cur_num" -ge "$min_num" -a "$cur_num" -le "$max_num" ];then
        echo 1
    else
        echo 0
    fi
}

proc_mem() {
    proc=$1
    total_mem=0
    mem_list=$(ps axu | grep $proc | egrep -v 'grep|vim|check_proc' | awk '{ print $6 }') 
    for i in $mem_list;do
        total_mem=$(echo $total_mem + $i | bc)
    done
    echo $total_mem
}

proc_cpu() {
    proc=$1
    total_cpu=0
    cpu_list=$(ps axu | grep $proc | egrep -v 'grep|vim|check_proc' | awk '{ print $3 }')
    for i in $cpu_list;do
        total_cpu=$(echo $total_cpu + $i | bc)
    done
    echo $total_cpu
}

case $1 in 
discovery)
    proc_discovery
    ;;
num)
    proc_num $2
    ;;
status)
    proc_status $2
    ;;
mem)
    proc_mem $2
    ;;
cpu)
    proc_cpu $2
    ;;
*)
    msg="Usage: $0 discovery | status | mem | cpu  PROC"
    echo $msg
esac
