#!/bin/bash
#
# Author: Guanghongwei
# Email: ibuler@qq.com

cwdir=`dirname $0`
. $cwdir/function.sh

redis_cli=$(which redis-cli 2> /dev/null)
redis_cli=${redis_cli:=/opt/redis/bin/redis-cli}
port=${2:-6379}
redis_pwd_default=guanghongwei

if [ -f $check_list ];then
    redis_pwd=$(grep $port $check_list | awk '{ print $4 }')
fi

redis_pwd=${redis_pwd:-$redis_pwd_default}
redis_cli="${redis_cli} -a $redis_pwd -p $port"
tmpfile=$tmp_dir/.$(str_md5 ${port}.redis).zbx

slave_discovery() {
    ports=($(grep -v "^#" $check_list | grep '^redis:' | grep 'slave' | awk '{ print $2 }'))
    discovery ${ports[@]}
}

redis_discovery() {
    ports=($(grep -v "^#" $check_list | grep "^redis:" | awk '{ print $2 }'))
    discovery ${ports[@]}
}

redis_ping() {
    error=''
    role=$(grep ^redis: $check_list | grep $port | awk '{ print $3 }')
    role=$(low_case ${role:-slave})
    $redis_cli ping 2> /dev/null | grep -i 'PONG' &> /dev/null || error='1'
    if [ "$role" == 'master' ];then
        $redis_cli set zbx_ping OK 2> /dev/null | grep -i 'OK' &> /dev/null || error='2'
        $redis_cli expire zbx_ping 60 &> /dev/null
        $redis_cli get zbx_ping 2> /dev/null | grep -i 'OK' &> /dev/null || error='3'
    fi

    if [ -z "$error" ];then
        echo 1
    else
        echo 0
    fi
    $redis_cli info 2> /dev/null > $tmpfile
}

redis_perf() {
    value=$(grep ^$1 $tmpfile | awk -F: '{ print $2 }')
    if [ ! -z "$value" ];then
       echo $value
    fi
}

redis_conf() {
    value=$($redis_cli config get $1 | tail -1)
    if [ ! -z "$value" ];then
        echo $value
    fi
}

redis_size() {
    $redis_cli dbsize | head -1 
}

case $1 in
discovery)
    redis_discovery
    ;;
slave_discovery)
    slave_discovery
    ;;
ping)
    redis_ping
    ;;
tmpfile_md5)
    tmpfile_md5
    ;;
dbsize)
    redis_size
    ;;   
perf)
    if [ ! -z "$3" ];then
       redis_perf $3
    fi
    ;;
conf)
    if [ ! -z "$3" ];then
       redis_conf $3
    fi
    ;;
*)
    msg="Usage: $0 discovery | ping | tmpfile_md5 | dbsize | conf port option | perf port option "
    echo $msg
    ;;
esac
