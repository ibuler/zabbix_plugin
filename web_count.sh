#!/bin/bash
#
# Desc: zabbix self key get pv, uv, download yesterday from nginx log 
#

domain_name=$1
file=$3
date=`date -d "-1 day" +"%Y%m%d"`

get_log(){
    year=${date:0:4}
    month=${date:4:2}
    day=${date:6:2}
    for log in `ls /opt/nginx/logs/$year/$month/$day | grep ^$domain_name`;do
        echo /opt/nginx/logs/$year/$month/$day/$log
    done
}

get_pv(){
    sum=0
    for log_file in `get_log`;do
         let sum+=`wc -l $log_file | awk '{ print $1 }'`
    done
    echo $sum
}

get_uv(){
    sum=0
    for log_file in `get_log`;do
	let sum+=`awk '{ print $1 }' $log_file | sort -u | wc -l`
    done
    echo $sum
}

download_total(){
    sum=0
    for log_file in `get_log`;do
        let sum+=`grep "$file" $log_file | awk '{ print $1 }' | wc -l`
    done
    echo $sum
}

download_per(){
    sum=0
    for log_file in `get_log`;do
        let sum+=`grep "$file" $log_file | awk '{ print $1 }' | sort -u | wc -l`
    done
    echo $sum
}

case $2 in
pv)
  get_pv;;
uv)
  get_uv;;
download_total)
  download_total;;
download_per)
  download_per;;
*)
  echo "Usage: $0 domain pv | uv | download_total | download_per file "
  ;;
esac
