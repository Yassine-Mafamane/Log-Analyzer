#!/bin/bash
set -e

export HADOOP_HOME=/usr/local/hadoop
export PATH=$HADOOP_HOME/bin:$HADOOP_HOME/sbin:$PATH

LOCAL_INPUT="/data/input"
LOCAL_OUTPUT="/data/output"
HDFS_INPUT="/input"
HDFS_OUTPUT="/output"
STREAMING_JAR=$HADOOP_HOME/share/hadoop/tools/lib/hadoop-streaming-2.9.2.jar

sed s/HOSTNAME/localhost/ $HADOOP_HOME/etc/hadoop/core-site.xml.template > $HADOOP_HOME/etc/hadoop/core-site.xml
service ssh start

if [ ! -d "/tmp/hadoop-root/dfs/name/current" ]; then
    hdfs namenode -format -force -nonInteractive
fi

$HADOOP_HOME/sbin/start-dfs.sh
$HADOOP_HOME/sbin/start-yarn.sh

while ! nc -z localhost 9000; do sleep 1; done
hdfs dfsadmin -safemode wait
while ! nc -z localhost 8032; do sleep 1; done

hdfs dfs -mkdir -p $HDFS_INPUT
hdfs dfs -rm -r -f $HDFS_OUTPUT 2>/dev/null || true
hdfs dfs -put -f $LOCAL_INPUT/*.txt $HDFS_INPUT/

hadoop jar $STREAMING_JAR \
    -input $HDFS_INPUT \
    -output $HDFS_OUTPUT \
    -mapper $HADOOP_HOME/mapper \
    -reducer $HADOOP_HOME/reducer

hdfs dfs -cat $HDFS_OUTPUT/part-* > $LOCAL_OUTPUT/anomalies.txt
$HADOOP_HOME/sbin/stop-dfs.sh

cat "$LOCAL_OUTPUT/anomalies.txt"
