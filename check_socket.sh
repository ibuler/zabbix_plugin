#!/bin/bash
# script name: check_socket.sh
# Authoer: Guanghongwei
# Mail: lastimac@gmail.com
. /etc/profile
. /etc/bashrc

get_data() {
   /usr/sbin/ss -s | head -2 | grep -o  "$1:\?[[:space:]]*[0-9]\{1,\}"  | awk '{ print $2 }' 
}

case $1 in
-h)
    echo "Usage: $0 estab | closed | orphaned | synrecv | timewait | ports";;
$1)
    get_data $1;;
esac
