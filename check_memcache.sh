#!/bin/bash
# Author: Guanghongwei
# Date: 2014/12/26
# Desc: Monitor memcached status
#

cwdir=`dirname $0`
. $cwdir/function.sh

port=${2:-11211}
telnet="/usr/bin/telnet"
tmpfile=$tmp_dir/.$(str_md5 ${port}.memcache).zbx

memcache_discovery() {
    ports=($(grep -v "^#" $check_list | grep '^memcache:' | awk '{ print $2 }'))
    discovery ${ports[@]}
}

memcache_uptime() {
    (echo -e "stats \n quit \n"; sleep 0.1) | $telnet 127.0.0.1 $port 2> /dev/null | tee $tmpfile | grep "uptime" | awk '{ print $3 }'
}

memcache_perf() {
    item=$1
    value=$(grep "\<$item\>" $tmpfile | awk '{ print $3 }')
    if [ ! -z "$value" ];then
       echo $value
    fi
}

case $1 in
discovery)
    memcache_discovery
    ;;
tmpfile_md5)
    tmpfile_md5
    ;;
uptime)
    memcache_uptime
    ;;
perf)
    if [ ! -z $3 ];then
       memcache_perf $3
    fi
    ;;
*)
    usage="Usage: $0 discovery | tmpfile_md5 | uptime | perf <status item> "
    echo $usage
    ;;
esac
