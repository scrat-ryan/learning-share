# [presto-admin](https://github.com/prestodb/presto-admin)

## require

* Python 2.6 or 2.7

## [virtualenv](https://www.cnblogs.com/freely/p/8022923.html)

    $ sudo pip install virtualenv
    $ virtualenv --version

## [virtualenvwrapper](https://www.cnblogs.com/freely/p/8022923.html)

1. install 

        [admin@UAT-HADOOP-15 ~] sudo pip install virtualenvwrapper
        [admin@UAT-HADOOP-15 ~] mkdir $HOME/.virtualenvs
                                export WORKON_HOME=$HOME/.virtualenvs  #设置环境变量
                                source /usr/bin/virtualenvwrapper.sh
        [admin@UAT-HADOOP-15 ~] source ~/.bash_profile

2. 基本使用
    * lsvirtualenv              #列举所有的环境。
    * cdvirtualenv              #导航到当前激活的虚拟环境的目录中，比如说这样您就能够浏览它的 site-packages。
    * cdsitepackages            #和上面的类似，但是是直接进入到 site-packages 目录中。
    * lssitepackages            #显示 site-packages 目录中的内容。
    * mkvirtualenv prestoadmin  #创建一个虚拟环境
    * workon prestoadmin        #在虚拟环境上工作
    * deactivate                #退出虚拟环境
    * rmvirtualenv prestoadmin  #删除虚拟环境

## install presto-admin

1. clone repository

        [admin@UAT-HADOOP-15 ~]$ cd ~/guosq/
        [admin@UAT-HADOOP-15 ~]$ git clone https://github.com/prestodb/presto-admin.git

2. install your local copy into a virtualenv

        [admin@UAT-HADOOP-15 ~]$ mkvirtualenv prestoadmin
        [admin@UAT-HADOOP-15 ~]$ workon prestoadmin
        (prestoadmin) [admin@UAT-HADOOP-15 ~]$ cd ~/guosq/presto-admin-master/
        (prestoadmin) [admin@UAT-HADOOP-15 ~]$ python setup.py install

3. configure prestoadmin virtualenv

        [admin@UAT-HADOOP-15 ~]$ cd ~/.prestoadmin
        [admin@UAT-HADOOP-15 ~]$ vim config.json
                                  {
                                     "username":"admin",
                                     "port": "22",
                                     "coordinator":"UAT-HADOOP-15",
                                     "workers":[
                                         "UAT-HADOOP-13","UAT-HADOOP-14"
                                     ],
                                     "java8_home": "/usr/local/jdk"
                                 }

4. Sudo Password Specification

    * Please note that if the username you specify is not root, and that user needs to specify a sudo password, you do so in one of two ways. You can specify it on the command line:    

            $ ./presto-admin <command> -p <password>    

    * Alternatively, you can opt to use an interactive password prompt, which prompts you for the initial value of your password before running any commands:    

            $ ./presto-admin <command> -I
            $ Initial value for env.password: <type your password here>    

    * ***The sudo password for the user must be the same as the SSH password.***

## presto-admin

1. install

        [admin@UAT-HADOOP-15 ~]$ workon prestoadmin
        (prestoadmin) [admin@UAT-HADOOP-15 ~]$ cdvirtualenv
        (prestoadmin) [admin@UAT-HADOOP-15 prestoadmin]$cd bin/
        (prestoadmin) [admin@UAT-HADOOP-15 bin]$./presto-admin --help
        (prestoadmin) [admin@UAT-HADOOP-15 bin]$wget https://repo1.maven.org/maven2/com/facebook/presto/presto-server-rpm/0.223/presto-server-rpm-0.223.       rpm  #下载0.223rpm
        (prestoadmin) [admin@UAT-HADOOP-15 bin]$./presto-admin server install presto-server-rpm-0.223.rpm -I

2. deploy

    presto集群的配置，全部都在`~/.prestoadmin/`目录下面

    * ./config.json    #presto-admin的集群配置文件
    * ./catalog/       #presto的catalog配置目录
    * ./coordinator/   #presto的coordinator配置目录
    * ./workers/       #presto的workers配置目录

3. presto集群操作

    * ./presto-admin configuration deploy
    * ./presto-admin server start
    * ./presto-admin server stop
    * ./presto-admin server rstart
    * ./presto-admin server status
    * ./presto-admin server install
    * ./presto-admin server upgrade
    * ./presto-admin server uninstall

4. query presto

        [admin@UAT-HADOOP-15 guosq]$mv /usr/lib/presto/lib/presto-client-0.223.jar presto
        [admin@UAT-HADOOP-15 guosq]$chmod +x presto
        [admin@UAT-HADOOP-15 ~]$presto --server 10.121.18.15:9066 --catalog tpch --schema tiny
        presto:tiny>select count(*) from lineitem;

## 参考

* [https://github.com/prestodb/presto-admin]
* [http://prestodb.github.io/presto-admin/docs/current/user-guide.html]
* https://www.cnblogs.com/freely/p/8022923.html
