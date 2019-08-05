#!/usr/bin/expect -f
#chmod 777 distribute.sh
#10.121.18.13
#10.121.18.14
#把所有目的ip写入servers.txt文件，servers.txt文件与distribute.sh在同一层目录，servers.txt文件中一行写一个ip
#sh distribute.sh 源服务器路径   目的服务器路径
#例如：sh distribute.sh /home/admin/guosq/distribute/ /home/admin/guosq/
#例如：sh distribute.sh /home/admin/guosq/distribute/servers.txt /home/admin/guosq/
#path: 源服务器路径 
#topath: 目的服务器路径

user=admin
password=!2019@kye
path=$1
topath=$2


for i in `cat ./servers.txt`
do
for line in $(ls ${path})
do
if [ "$path" == "$line" ]
then
   source=${path}
else
   source=${path}${lin}
fi
expect<<-END
spawn scp ${source} ${user}@${i}:${topath}
expect {
        "(yes/no)?" {send "yes\r"; exp_continue}
        "${i}'s password:" {send "${password}\r"}
        "Permission denied" { send_user "[exec echo "\nError: Password is wrong\n"]"; exit}
}
expect eof
exit
END
done
done