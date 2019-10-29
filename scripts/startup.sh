#!/bin/sh
version=1.6.0-SNAPSHOT
pidfile=logs/$1.pid
logfile=logs/$1-info.`date +%F`.log
JAVA_OPTS="-server -Xms512m -Xmx512m -XX:NewSize=128m -XX:MaxNewSize=256m -Xss512k"
module="$1-$version.jar"

nohup java $JAVA_OPTS -jar $module >> ${logfile} 2>&1 & pid=$!

echo "$module starting "
for e in $(seq 10); do
    echo -e " $e"
    sleep 1
done
echo $pid > $pidfile
