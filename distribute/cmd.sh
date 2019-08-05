#!/bin/bash
#example
#sh /home/admin/guosq/distribute/cmd.sh "cd /app/module/danmaowu/presto-server-0.221;./bin/launcher stop"
#sh /home/admin/guosq/distribute/cmd.sh "cd /app/module/danmaowu/presto-server-0.221;./bin/launcher start"

cmd=$1

echo  "---------------------starting ${cmd}-------------------------"
for i in `cat ./servers.txt`
do
{
    r=`ssh $i "$cmd"`
    echo "--------$i----$r----------"
}&
done
wait
echo  "--------------------------complete------------------------"