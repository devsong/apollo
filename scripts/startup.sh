#!/bin/bash

JAVA_OPTS="-server -Xms512m -Xmx512m -XX:NewSize=128m -XX:MaxNewSize=256m -Xss512k"

source /etc/profile
basepath=$(cd `dirname $0`; pwd)
PROG_NAME=$0
module=$1
ACTION=$2
pidfile=logs/$module.pid
logfile=logs/$module-info.`date +%F`.log
version=1.6.0-SNAPSHOT

usage() {
    echo "Usage: $PROG_NAME {start|stop|restart|status|tailf|backup}"
    exit 1;
}

if [ "$UID" -eq 0 ]; then
    echo "can't run as root, please use: sudo -u admin $0 $@"
    exit 1
fi

if [ $# -lt 1 ]; then
    usage
fi

# colors
red='\e[0;31m'
green='\e[0;32m'
yellow='\e[0;33m'
reset='\e[0m'

echoRed() { echo -e "${red}$1${reset}"; }
echoGreen() { echo -e "${green}$1${reset}"; }
echoYellow() { echo -e "${yellow}$1${reset}"; }


function check_pid() {
	pidfile=logs/$module.pid
    if [ -f $pidfile ];then
        pid=`cat $pidfile`
        if [ -n $pid ]; then
            running=`ps -p $pid|grep -v "PID TTY" |wc -l`
            return $running
        fi
    fi
    return 0
}

function start(){
	check_pid
	jarfile="$module-$version.jar"
	
	nohup java $JAVA_OPTS -jar $jarfile >> ${logfile} 2>&1 & pid=$!
	
	echoGreen "$module starting "
	for e in $(seq 10); do
	    echoGreen " $e"
	    sleep 1
	done
	echo $pid > $pidfile
}

function stop() {
    pid=`cat $pidfile`
    kill -9 $pid
    echoRed "$app stoped..."
}

function restart() {
    stop
    sleep 1
    start
}

function tailf() {
        tail -f $basepath/logs/$logfile
}

function status() {
    check_pid
    running=$?
    if [ $running -gt 0 ];then
        echoGreen "$app now is running, pid=`cat $pidfile`"
    else
        echoYellow "$app is stoped"
    fi
}

function backup() {
    bakdir=/home/admin/backup/`date +%F`
    mkdir -p $bakdir
    cd $APP_HOME/..
    tar -zcf $app-`date +'%Y%m%d%H%M'`.tar.gz $app --exclude=$app/logs
    mv $app-`date +'%Y%m%d%H%M'`.tar.gz $bakdir
    echoGreen "$app deploy success, is $app-`date +'%Y%m%d%H%M'`.tar.gz"
}

function main {
   RETVAL=0
   case "$1" in
      start)
         start
         ;;
      stop)
         stop
         ;;
      restart)
         restart
         ;;
      tailf)
         tailf
         ;;
      status)
         status
         ;;
      backup)
         backup
         ;;
      *)
	 usage
         ;;
      esac
   exit $RETVAL
}

main $2

