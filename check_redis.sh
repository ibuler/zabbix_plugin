#!/bin/bash
#
# Author: Guanghongwei
# Email: ibuler@qq.com

. /etc/profile
. /etc/bashrc

redis_cli=$(which redis-cli 2> /dev/null)
redis_cli=${redis_cli:=/opt/redis/bin/redis-cli}
cwdir=`dirname $0`
check_list=${cwdir}/check_list.txt

if [ ! -z "$2" ];then
    port=$2
else
    port=6379
fi

if [ -f $check_list ];then
    pwd=$(grep $port $check_list | awk '{ print $4 }')
fi
pwd=${pwd:=guanghongwei}

redis_cli="${redis_cli} -a $pwd -p $port"

low_case() {
  echo $1 | tr [A-Z] [a-z]
}

str_md5() {
  echo $1 | md5sum | awk '{ print $1 }'
}

json_null() {
    printf '{\n'
    printf '\t"data":[\n'
    printf  "\t\t{ \n"
    printf  "\t\t\t\"{#PORT}\":\"NULL\"}]}\n"
}

tmpfile=/tmp/.$(str_md5 ${port}.redis).zbx

slave_discovery() {
    if [ ! -f "$check_list" ];then
        json_null
        exit 1
    fi

    ports=($(grep -v "^#" $check_list | grep '^redis:' | grep 'slave' | awk '{ print $2 }'))
    if [ ${#ports[@]} -eq 0 ];then
        json_null
        exit 1
    fi
    printf '{\n'
    printf '\t"data":[\n'
    for((i=0;i<${#ports[@]};++i)) {
        num=$(echo $((${#ports[@]}-1)))
        if [ "$i" != "${num}" ]; then
            printf "\t\t{ \n"
            printf "\t\t\t\"{#PORT}\":\"${ports[$i]}\"},\n"
        else
            printf  "\t\t{ \n"
            printf  "\t\t\t\"{#PORT}\":\"${ports[$num]}\"}]}\n"
        fi
    }
}

redis_discovery() {
    if [ ! -f "$check_list" ];then
        json_null
        exit 1
    fi

    ports=($(grep -v "^#" $check_list | grep "^redis:" | awk '{ print $2 }'))
    if [ ${#ports[@]} -eq 0 ];then
        json_null
        exit 1
    fi
    printf '{\n'
    printf '\t"data":[\n'
    for((i=0;i<${#ports[@]};++i)) {
        num=$(echo $((${#ports[@]}-1)))
        if [ "$i" != "${num}" ]; then
            printf "\t\t{ \n"
            printf "\t\t\t\"{#PORT}\":\"${ports[$i]}\"},\n"
        else
            printf  "\t\t{ \n"
            printf  "\t\t\t\"{#PORT}\":\"${ports[$num]}\"}]}\n"
        fi
    }
}

redis_ping() {
    error=''
    role=$(grep ^$port $check_list | awk '{ print $3 }')
    role=$(low_case ${role:=slave})
    $redis_cli ping 2> /dev/null | grep -i 'PONG' &> /dev/null || error='1'
    if [ "$role" == 'master' ];then
        $redis_cli set zbx_ping OK 2> /dev/null | grep -i 'OK' &> /dev/null || error='2'
        $redis_cli get zbx_ping 2> /dev/null | grep -i 'OK' &> /dev/null || error='3'
    fi

    if [ -z "$error" ];then
        echo 1
    else
        echo 0
    fi
}

redis_uptime() {
    $redis_cli info 2> /dev/null | tee $tmpfile | grep uptime_in_seconds | awk -F: '{ print $2 }' || echo 0
}

tmpfile_md5() {
    /usr/bin/md5sum $tmpfile 2> /dev/null | awk '{ print $1 }' || echo "9741"
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
uptime)
    redis_uptime
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

    usage="Usage: $0 discovery | ping | uptime | tmpfile_md5 | dbsize | conf port option | perf port option "
    echo $usage
    ;;
esac
