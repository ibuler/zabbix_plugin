#!/bin/bash 
#
# Author: Guanghongwei
# Mail: ibuler@qq.com

. /etc/profile
. /etc/bashrc

cwdir=`dirname $0`
check_list=${cwdir}/check_list.txt

json_null() {
    printf '{\n'
    printf '\t"data":[\n'
    printf  "\t\t{ \n"
    printf  "\t\t\t\"{#PORT}\":\"NULL\"}]}\n"
}

if [ ! -z "$2" ];then
    sitename=$2
else
    sitename=www.baidu.com
fi


str_md5() {
  echo $1 | md5sum | awk '{ print $1 }'
}

tmpfile=/tmp/$(str_md5 $sitename).zbx

website_discovery () { 
    if [ ! -f "$check_list" ];then
        json_null
        exit 1
    fi
    websites=($(grep -v "^#" $check_list | grep '^web:' | awk '{ print $2 }' )) 
    if [ ${#websites[@]} -eq 0 ];then
        json_null
        exit 1
    fi
    printf '{\n' 
    printf '\t"data":[\n' 
    for((i=0;i<${#websites[@]};++i)) { 
        num=$(echo $((${#websites[@]}-1))) 
        if [ "$i" != "${num}" ]; then 
            printf "\t\t{ \n" 
            printf "\t\t\t\"{#SITENAME}\":\"${websites[$i]}\"},\n" 
        else 
            printf  "\t\t{ \n" 
            printf  "\t\t\t\"{#SITENAME}\":\"${websites[$num]}\"}]}\n" 
        fi 
    } 
}

web_code() {
    echo `/usr/bin/curl  -m 10 -o /dev/null -s -w %{http_code}::%{time_namelookup}::%{time_connect}::%{time_starttransfer}::%{time_total}::%{speed_download} $1` | tee $tmpfile | awk -F'::' '{ print $1}'
}

tmpfile_md5() {
    /usr/bin/md5sum $tmpfile | awk '{ print $1 }'
}

case "$1" in 
discovery) 
    website_discovery
    ;; 
code) 
    web_code $sitename
    ;; 
dns) 
    awk -F'::' '{ print $2 }' $tmpfile
    ;; 
connect)
    awk -F'::' '{ print $3 }' $tmpfile
    ;;
start)
    awk -F'::' '{ print $4 }' $tmpfile
    ;;
total)
    awk -F'::' '{ print $5 }' $tmpfile
    ;;
speed)
    awk -F'::' '{ print $6 }' $tmpfile
    ;;
tmpfile_md5)
    tmpfile_md5
    ;;
*) 
    echo "Usage:$0 {discovery | code | dns | connect | start | total | speed | tmpfile_md5 [URL]}" 
;; 
esac
