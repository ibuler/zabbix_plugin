#!/bin/bash
# Script_name: check_mysql.sh
# Author: Guanghongwei
# Date: 2014/12/25
#

cwdir=`dirname $0`
. $cwdir/function.sh

mysql_cli=$(which mysql 2> /dev/null)
mysql_cli=${mysql_cli:-/opt/mysql/bin/mysql}
mysql_cli=${mysql_cli:-/usr/local/mysql/bin/mysql}
port=${2:-3306}
tmpfile=$tmp_dir/.$(str_md5 ${port}.mysql).zbx

if [ -f $check_list ];then
    user=$(grep $port $check_list | awk '{ print $4 }')
    password=$(grep $port $check_list | awk '{ print $5 }')
fi

user=${user:-monitor}
password=${password:-Ok7HBwfpWKnQ}
host=${host:-127.0.0.1}
mysql_cli="${mysql_cli} -u$user -p$password -h$host -P$port"

mysql_discovery() {
    ports=($(grep -v '^#' $check_list | grep '^mysql:' | awk '{ print $2 }'))
    discovery ${ports[@]}
}

slave_discovery() {
    ports=($(grep -v '^#' $check_list| grep "^mysql:" | grep 'slave' | awk '{ print $2 }'))
    discovery ${ports[@]}
}

mysql_ping() {
	$mysql_cli -e 'show global status' 2> /dev/null > $tmpfile && $mysql_cli -e 'show global variables' 2> /dev/null >> $tmpfile && $mysql_cli -e 'show slave status\G' 2> /dev/null  >> $tmpfile && echo 1 || echo 0
}

mysql_perf() {
    data=$(grep "\<$1\>" $tmpfile | awk '{ print $2 }')
    if [ -n "$data" ];then
        echo $data
    fi
}

slave_status() {
	slave_running=`mysql_perf 'Slave_running'`
        io_running=`mysql_perf 'Slave_IO_Running'` 
        sql_running=`mysql_perf 'Slave_SQL_Running'`
        if [ "$slave_running" == 'ON' ];then
            if [ "$io_running" == 'No' -o "$sql_running" == 'No' ];then
                echo 0
            else
                echo 1
            fi
        else
            if [ "$io_running" == 'Yes' -o "$sql_running" == 'Yes' ];then
               echo 0
            else
               echo 3
            fi
        fi
        
}

read_behind_master() {
        master_host=`mysql_perf 'Master_Host'`
        master_port=`mysql_perf 'Master_Port'`
	mysql_ping &> /dev/null &&  ${mysql_cli} -h$master_host -P$master_port -e 'show master status\G' 2> /dev/null >> $tmpfile || echo "NULL"
        master_file=`mysql_perf 'File'`
	master_file_pos=`mysql_perf 'Position'`
        read_file=`mysql_perf 'Master_Log_File'`
	read_file_pos=`mysql_perf 'Read_Master_Log_Pos'`
        
        if [ $master_file != $read_file ];then
            echo 99999 && exit 0
        else
            echo $(( $master_file_pos - $read_file_pos ))
        fi
}


case $1 in
    discovery)
        mysql_discovery
        ;;
    slave_discovery)
        slave_discovery
        ;;
    ping)
        mysql_ping
        ;;
    slave_status)
        slave_status
        ;;
    tmpfile_md5)
        tmpfile_md5
        ;;
    read_behind)
        read_behind_master
        ;;
    perf)
        if [ -z "$3" ];then
            echo "NULL"
        else
            mysql_perf $3
        fi
        ;;
    *)
        msg="Usage: $0 discovery | slave_discovery | ping | slave_status | read_behind | tmpfile_md5 | perf  port [options]"
        echo $msg
        ;;
esac
