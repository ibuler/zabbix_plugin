#!/bin/bash
# script name: check_socket.sh
# Authoer: Guanghongwei
# Mail: lastimac@gmail.com
#

get_data() {
   /usr/sbin/ss -s | head -2 | grep -o  "$1:\?[[:space:]]*[0-9]\{1,\}"  | awk '{ print $2 }' 
}

case $1 in
$1)
    if [ -z "$1" -o "$1" == "-h" ];then
        echo "Usage: $0 estab | closed | orphaned | synrecv | timewait | ports";
        exit 1
    fi
    get_data $1;;
esac
