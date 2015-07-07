#!/bin/bash 
#
# Author: Guanghongwei
# Mail: ibuler@qq.com

cwdir=`dirname $0`
. $cwdir/function.sh

url=${2:-www.baidu.com}
tmpfile=$tmp_dir/.$(str_md5 $url).zbx

website_discovery () { 
    urls=($(grep -v "^#" $check_list | grep '^web:' | awk '{ print $2 }' )) 
    discovery ${urls[@]}
}

web_code() {
    echo `/usr/bin/curl -m 10 -o /dev/null -s -w %{http_code}::%{time_namelookup}::%{time_connect}::%{time_starttransfer}::%{time_total}::%{speed_download} $1` | tee $tmpfile | awk -F'::' '{ print $1 }'
}

case "$1" in 
discovery) 
    website_discovery
    ;; 
code) 
    web_code $url
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
