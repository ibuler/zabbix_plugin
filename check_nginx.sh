#!/bin/bash 
#
# Author: Guanghongwei
# Mail: ibuler@qq.com
#

cwdir=`dirname $0`
. $cwdir/function.sh

url=${2:-http://127.0.0.1/nginx_status}
tmpfile=$tmp_dir/.$(str_md5 $url).zbx

web_code() {
    /usr/bin/curl -m 10 -o $tmpfile -s -w %{http_code}   $url
}

case "$1" in 
code) 
    web_code $url
    ;; 
active) 
    grep "Active" $tmpfile  | awk '{ print $3 }'
    ;; 
server)
    grep -A1 "^server" $tmpfile  | tail -1 | awk '{ print $1 }'
    ;;
accepts)
    grep -A1 "^server" $tmpfile  | tail -1 | awk '{ print $2 }'
    ;;
handled)
    grep -A1 "^server" $tmpfile  | tail -1 | awk '{ print $3 }'
    ;;
requests)
    grep -A1 "^server" $tmpfile  | tail -1 | awk '{ print $4 }'
    ;;
reading)
    grep -A1 "^Reading" $tmpfile  | awk '{ print $2 }'
    ;;
writing)
    grep -A1 "^Reading" $tmpfile  | awk '{ print $4 }'
    ;;
waiting)
    grep -A1 "^Reading" $tmpfile  | awk '{ print $6 }'
    ;;
tmpfile_md5)
    tmpfile_md5
    ;;
*) 
    echo "Usage:$0 {code | active | server | accepts | handled | requests | reading | writing | waiting | tmpfile_md5 [URL]}" 
;; 
esac
