#!/bin/bash
# Author: Guanghongwei
# Date: 2014/12/25
# Public function/variable for zabbix agent check
#
. /etc/profile
. /etc/bashrc

cwdir=`dirname $0`
check_list=$cwdir/check_list.txt

json_null() {
    printf '{\n'
    printf '\t"data":[\n'
    printf  "\t\t{ \n"
    printf  "\t\t\t\"{#VALUE}\":\"NULL\"}]}\n"
}

str_md5() {
  echo $1 | md5sum | awk '{ print $1 }'
}

tmpfile_md5() {
    /usr/bin/md5sum $tmpfile 2> /dev/null | awk '{ print $1 }' || echo "NULL"
}

low_case() {
  echo $1 | tr [A-Z] [a-z]
}

if [ -d "/dev/shm" ];then
    tmp_dir="/dev/shm"
else
    tmp_dir="/tmp"
fi

discovery() {
    values=($@)
    if [ ! -f "$check_list" ];then
        json_null
        exit 2
    fi

    if [ ${#values[@]} -eq 0 ];then
        json_null
        exit 1
    fi

    printf '{\n'
    printf '\t"data":[\n'
    for((i=0;i<${#values[@]};++i)) {
        num=$(echo $((${#values[@]}-1)))
        if [ "$i" != "${num}" ]; then
            printf "\t\t{ \n"
            printf "\t\t\t\"{#VALUE}\":\"${values[$i]}\"},\n"
        else
            printf  "\t\t{ \n"
            printf  "\t\t\t\"{#VALUE}\":\"${values[$num]}\"}]}\n"
        fi
    }

}

