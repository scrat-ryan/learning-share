# ansible

Ansible is Simple IT Automation    --简单的自动化IT工具

## 简介

ansible是新出现的自动化运维工具，基于Python开发，集合了众多运维工具（puppet、cfengine、chef、func、fabric）的优点，实现了批量系统配置、批量程序部署、批量运行命令等功能。

ansible是基于模块工作的，本身没有批量部署的能力。真正具有批量部署的是ansible所运行的模块，ansible只是提供一种框架。主要包括：

Ansible跟其他IT自动化技术的区别在于其关注点并非配置管理、应用部署或IT流程工作流，而是提供一个统一的界面来协调所有的IT自动化功能，因此Ansible的系统更加易用，部署更快。

Ansible可以让用户避免编写脚本或代码来管理应用，同时还能搭建工作流实现IT任务的自动化执行。IT自动化可以降低技术门槛及对传统IT的依赖，从而加快项目的交付速度。

优点：

1. 连接插件connection plugins：负责和被监控端实现通信；
2. host inventory：指定操作的主机，是一个配置文件里面定义监控的主机；
3. 各种模块核心模块、command模块、自定义模块；
4. 借助于插件完成记录日志邮件等功能；
5. playbook：剧本执行多个任务时，非必需可以让节点一次性运行多个任务。

缺点：

1. 对于几千台、上万台机器的操作，还不清楚性能、效率情况如何，需要进一步了解

## install

    [admin@UAT-HADOOP-15 ~]$ sudo yum install ansible
    [admin@UAT-HADOOP-15 ~]$ ansible --version
    [admin@UAT-HADOOP-15 ~]$ ls /etc/ansible/
    [admin@UAT-HADOOP-15 ~]$ ansible.cfg hosts roles  
                             ├── ansible.cfg  # ansible的配置文件                         
                             ├── hosts  # ansible的主仓库 用来存储需要管理的远程主机的相关信息                         
                             └── roles            
    [admin@UAT-HADOOP-15 ~]$ sudo vim /etc/ansible/hosts
                             [presto]
                             10.121.18.13 UAT-HADOOP-13=UAT-HADOOP-13
                             10.121.18.14 UAT-HADOOP-14=UAT-HADOOP-14
                             10.121.18.15 UAT-HADOOP-15=UAT-HADOOP-15

## ansible 命令

1. ansible-doc  #列出所有已安装的模块
2. ansible-doc -l  #查看具体某模块的用法，这里如查看command模块 ansible-doc -s command
3. ping 模块

       ansible presto -m ping

4. command模块  #可以运行远程权限范围所有的shell命令，不支持管道符

       ansible presto -m command -a "echo Hello World."
       ansible presto -m command -a "free -m"
       ansible presto -m command -a "date"
       ansible presto -m command -a "rm -rf /tmp/start-presto.sh"

5. shell模块  #执行远程主机上的shell脚本文件，支持管道符

       ansible presto -m shell -a "/home/admin/guosq/test.sh"

6. script模块  #在远程主机执行主控端存储的shell脚本文件，相当于scp+shell组合

       ansible presto -m script -a "/home/admin/guosq/presto_start.sh"
       ansible presto -m script -a "/home/admin/guosq/presto_stop.sh"

7. copy模块  #实现主控端向目标主机拷贝文件，类似于scp功能

       ansible presto -m copy -a "src=/home/admin/guosq/start-presto.sh dest=/tmp/ force=true owner=admin group=admin mode=0755"

8. stat模块  #获取远程文件状态信息， atime/ctime/mtime/md5/uid/gid等信息

       ansible presto -m stat -a "/path=/etc/syctl.conf"

9. get_url模块  #实现在远程主机下载指定url到本地，支持sha256sum文件娇艳

       ansible presto -m get_url -a "url=http://www.baidu.com dest=/tmp/index.html mode=0440 force=yes"

## 参考

* [https://www.ansible.com]
* [https://www.ansible.com.cn]
* [https://www.cnblogs.com/dachenzi/p/8916521.html]
* [https://blog.51cto.com/13680184/2097243]
