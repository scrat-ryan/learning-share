​​# [hive](http://hive.apache.org)

Hive是最适合数据仓库应用程序的，其可以维护海量数据，而且可以对数据进行挖掘，然后形成意见和报告等。	


${env:home}
show databases;
create database if not exists human comment 'this is comment';
drop database  if exists human;
drop database  if exists human cascade;

use human;

create table if not exists emp(
  id int comment 'emp id',
  name string comment 'emp name', 
  sal float comment 'emp sal',
  address struct<street:string, city:string, state:string, zip:int> comment 'emp address'
) 
comment 'desc of the table' 
partitioned by (country string, state string) 
tblproperties ('creator'='me', 'created_at'='2018-11-22 15:06:00');

--将Hive设置为"strict(严格)/nostrict(非严格)"模式, 如果对分区表进行查询而where自居没有加分区过滤的话，将会禁止/不禁止提交这个任务
--set hive.mapred.mode=strict/nostrict
--删除表
drop table if exists emp;
--修改表名
alter table emp rename to tmp;

--向管理表中装载数据
load data local inpath '${env:home}/human'
overwrite into table emp
partition (country = 'US', state = 'CA');
--通过查询语句向表中插入数据[insert overwrite/into]
insert overwrite table employees
partition (country = 'US', state = 'OR')
select * from staged_employees se
where se.cnty = 'US' AND se.st = 'OR'
--动态分区插入
--动态分区功能默认情况下没有开启。set hive.exec.dynamic.partition = true
--开启后，默认是以“严格”模式执行的，即要求至少有一列分区字段是静态的，这有助于因设计错误导致查询产生大量的分区 set hive.exec.dynamic.partition.mode = nonstrict/strict
insert overwrite table employees
partition (country, state)
select ..., se.cnty, se.st
from staged_employees se;
--静态分区键必须出现在动态分区键之前
insert overwrite table employees
partition (country = 'US', state)
select ..., se.cnty, se.st
from staged_employees se;
where se.cnty = 'US'

create table ca_employees
as select name, salary, address
from employees se
where se.state = 'CA'

-- 显示索引
show formatted index on employees;
--删除索引
drop index if exists employees_index on table employees;

--创建索引
create index employees_index
on table employees (country)
as 'org.apache.hadoop.hive.ql.index.compact.CompactIndexHandler'
with deferred rebuild
inxproperties ('creator' = 'me', 'created_at' = 'some_time')
in table employees_index_table
partitioned by (country, name)
comment 'Employees indexed by country and name.'
--Bitmap索引普遍应用于排重后值较少的列。
create index employees_index
on table employees (country)
as 'bitmap'
with deferred rebuild
inxproperties ('creator' = 'me', 'created_at' = 'some_time')
in table employees_index_table
partitioned by (country, name)
comment 'Employees indexed by country and name.'

--重建索引
alter index employees_index
on table employees
partition (country = 'US')
rebuild;

-- 尝试使用本地模式执行其他的操作，最好将一下设置增加到你的$HOME/.hiverc配置文件中
set hive.exec.mode.local.auto = true;

-- 对浮点数进行比较时，需要保持极端谨慎的态度。要避免任何从窄类型隐式转换到更广泛类型的操作。

-- having 用来对group by 做限制操作避免出现嵌套子查询

join

inner join

outer join [left join, right join, full join]

-- 优化join操作[map-side join]，将join的小表放入内存中进行逐一匹配，对于right outer join 和 full outer join 不支持这个优化
set hive.auto.convert.join = true;
-- 配置能够使用优化的小表的大小
set hive.mapjoin.smalltable.filesize = 25000000

order by

--在每个reducer中对数据进行排序[局部排序]，保证每个reducer的输出数据都是有序的(但并非全局有序)
sort by

-- hive要求distribute by语句要写在sort by语句之前
distribute by

--distribute by 和 sort by 设计到的列和排序完全相同可以用cluster by 代替
cluster by 

union all

数学函数

返回值类型样式描述BIGINTround(DOUBLE d)返回DOUBLE型d的BIGINT类型的近似值DOUBLEround(DOUBLE d,  INT n)返回DOUBLE型d的保留n为小树的DOUBLE类型的近似值BIGINTfloor(DOUBLE d)d是DOUBLE类型的，返回<=d的最大BIGINT型值BIGINTceil(DOUBLE d)ceiling(DOUBLE d)d是DOUBLE类型的，返回>=d的最小BIGINT型值DOUBLErand()rand(INT  seed)每行返回一个DOUBLE型随机数，整数seed是随机因子 DOUBLEexp(DOUBLE  d)返回e的d幂次方，返回的是个DOUBLE型值 =e^dDOUBLEln(DOUBLE  d)以自然数为底d的对数，返回DOUBLE型值DOUBLElog10(DOUBLE  d)以10为底d的对数，返回DOUBLE型值DOUBLElog2(DOUBLE  d)以2为底d的对数，返回DOUBLE型值DOUBLElog(DOUBLE  base, DOUBLE d)以base为底d的对数，返回DOUBLE型值，其中base和d都是DOUBLE型的DOUBLEpow(DOUBLE  d, DOUBLE p)power(DOUBLE  d, DOUBLE p)计算d的p次幂，返回DOUBLE型值，其中d和p都是DOUBLE型的DOUBLEsqrt(DOUBLE d)计算d的平方根，其中d是DOUBLE型的STRINGbin(BIGINT  i)计算二进制值i的STRING类型值，其中i是BIGINT类型的STRINGhex(BIGINT  i)计算十六进制值i的STRING类型值，其中i是BIGINT类型的STRINGhex(STRING  str)计算十六进制值str的STRING类型值，其中i是STRING类型的STRINGhex(BINARY  b)计算十六进制值b的STRING类型值，其中i是BINARY类型的STRINGunhex(STRING  i)hex(STRING i)的逆方法DOUBLEabs(DOUBLE  d)计算DOUBLE型值d的绝对值，返回结果也是DOUBLE型的INTpmod(INT i1, INT i2)INT值i1对i2取模，结果也是INT型的DOUBLE pmod(DOUBLE d1, DOUBLE d2)DOUBLE 值d1对d2取模，结果也是DOUBLE 型的DOUBLE sin(DOUBLE  d)在弧度度量中，返回DOUBLE型值d的正弦值，结果是DOUBLE型的DOUBLE asin(DOUBLE  d)在弧度度量中，返回DOUBLE型值d的反正弦值，结果是DOUBLE型的DOUBLE cos(DOUBLE  d)在弧度度量中，返回DOUBLE型值d的余弦值，结果是DOUBLE型的DOUBLE acos(DOUBLE  d)在弧度度量中，返回DOUBLE型值d的反余弦值，结果是DOUBLE型的DOUBLE tan(DOUBLE  d)在弧度度量中，返回DOUBLE型值d的正切值，结果是DOUBLE型的DOUBLE atan(DOUBLE  d)在弧度度量中，返回DOUBLE型值d的反正切值，结果是DOUBLE型的DOUBLE degrees(DOUBLE  d)将DOUBLE型弧度值d转换成角度值，结果是DOUBLE型的DOUBLE radians(DOUBLE  d)将DOUBLE型值角度值d转换成弧度，结果是DOUBLE型的INTpositive(INT i)返回INT型值i（其等价的有效表达式是\+i）DOUBLE positive(DOUBLE d)返回DOUBLE 型值d（其等价的有效表达式是\+d）INTnegative(INT  i)返回INT型值i的负数（其等价的有效表达式是\-i）DOUBLE negative(DOUBLE  d)返回DOUBLE 型值d的负数（其等价的有效表达式是\-d）FLOATsign(DOULE  d)如果DOUBLE型值d是正数的话，则返回FLOAT值1.0；如果d是负数的话，则返回-1.0；否则返回0.0DOUBLE e()数学常数e，也就是超越数，DOUBLE型值DOUBLE pi()数学常数pi，也就是圆周率，DOUBLE型值BIGINTfactorial(INT  a)求a的阶乘DOUBLE cbrt(DOUBLE  a)求a的立方根


聚合函数【通过设置属性hvie.map.aggr值为true来提高聚合的性能 set hive.map.aggr = true】

返回值类型样式描述BIGINTcount(*)计算总行数，包括含有NULL值的行BIGINTcount(expr)计算提供的expr表达式的值非NULL的行数BIGINTcount(DISTICT expr[,  expr_.])计算提供的expr表达式的值排重后非NULL的行数DOUBLEsum(col)计算指定列的值的和DOUBLEsum(DISTICT  col)计算指定列去重后的值的和DOUBLEavg(col)计算指定列的值的平均值DOUBLEavg(DISTICT  col)计算指定列去重后的值的平均值DOUBLEmin(col)计算指定列的最小值DOUBLEmax(col)计算指定列的最大值DOUBLEvariance(col)var_pop(col)计算指定列的方差DOUBLEvar_samp(col)计算指定列的样本方差DOUBLEstddev_pop(col)计算指定列的标准偏差DOUBLEstddev_samp(col)计算指定列的标准样本偏差DOUBLEconvar_pop(col1,  col2) 计算两个数字列的协方差DOUBLEconvar_samp(col1,  col2) 计算两个数字列的样本协方差DOUBLEcorr(col1,  col2)计算两个数字列的皮尔逊相关系数

​​



其他内置函数

返回值类型样式描述返回值类型就是type定义的类型cast(<expr>  as <type>)将expr转换成type类型的。例如cast('1' as BIGINT)将会将字符串'1'转换成BIGINT数值类型。如果转换过程失败，则返回NULLSTRINGconcat(BINARY  s1, BINARY s2, … )将二进制字节码按次序拼接成一个字符串STRINGconcat(STRING  s1, STRING s2, … )将字符串s1，s2等拼接成一个字符串STRINGconcat(STRING  separator, STRING s1, STRING s2, … )使用指定的分隔符进行拼接STRINGdecode(binary  bin, string charset)使用指定的字符集charset将二进制值bin解码成字符串，支持的字符集有：'US-ASCII', 'ISO-8859-1', 'UTF-8', 'UTF-16BE',  'UTF-16LE', 'UTF-16'，如果任意输入参数为NULL都将返回NULLBINARYencode(STRING  src, STRING charset)使用指定的字符集charset将字符串src编码成二进制值(支持的字符集有：'US-ASCII', 'ISO-8859-1', 'UTF-8',  'UTF-16BE', 'UTF-16LE', 'UTF-16')。如果任意输入参数为NULL，则结果为NULLINTfind_in_set(string  str, string strList)返回以逗号分隔的字符串中str出现的位置，如果参数str为逗号或查找失败将返回0，如果任一参数为NULL将返回NULLSTRINGformat_number(number  x, int d)将数值X转换成‘#,###,###.##’格式字符串，并保留d位小数，如果d为0，将进行四舍五入且不保留小数STRINGget_json_object(STRING  json_string, STRING path)从给定路径上的JSON字符串中抽取出JSON对象，并返回这个对象的JSON字符串形式。如果输入的JSON字符串是非法的，则返回NULLBOOLEANin_file(STRING  s, STRING filename)如果文件名为filename的文件中有完成一行数据和字符串s完全匹配的话，则返回trueINTinstr(STRING  str, STRING substr)查找字符串str中子字符串substr第一次出现的位置INTlength(STRING  S)计算字符串s的长度INTlocate(STRING  substr, STRING str, INT pos)查找在字符串str中的pos位置后字符串substr第一次出现的位置STRINGlower(STRING  s) lcase(STRING  s) 将字符串中所有字母转换成小写字母STRINGupper(STRING  s) ucase(STRING  s)将字符串中所有字母转换成大写字母STRINGlpad(STRING  s, INT len, STRING pad)从左边开始对字符串s使用字符串pad进行填充，最终达到len长度为止。如果字符串s本身长度比len大的话，那么多余的部分会被去除掉STRINGrpad(STRING  s, INT len, STRING pad)从右边开始对字符串s使用字符串pad进行填充，最终达到len长度为止。如果字符串s本身长度比len大的话，那么多余的部分会被去除掉STRINGltrim(STRING  s)将字符串s前面出现的空格全部去除掉STRINGlrtrim(STRING  s)将字符串s后面出现的空格全部去除掉STRINGtrim(STRING  s)将字符串s出现的空格全部去除掉STRINGparse_url(string  urlString, string partToExtract [, string keyToExtract])返回从URL中抽取指定部分的内容，参数url是URL字符串，而参数partToExtract是要抽取的部分，这个参数包含(HOST,  PATH, QUERY, REF, PROTOCOL, AUTHORITY, FILE, and USERINFO,例如：parse_url('http://facebook.com/path1/p.php?k1=v1&k2=v2#Ref1',  'HOST') ='facebook.com'，如果参数partToExtract值为QUERY则必须指定第三个参数key 如：parse_url('http://facebook.com/path1/p.php?k1=v1&k2=v2#Ref1',  'QUERY', 'k1') ='v1'STRINGprintf(STRING  format, Obj... args)按照printf风格格式输出字符串STRINGregexp_extract(string  subject, string regex_pattern, int index)抽取字符串subject中符合正则表达式regex_pattern的第index个部分的子字符串，注意一些预定义字符的使用，如第二个参数如果使用STRINGregexp_replace(string  s, string regexp_replace, string replacement)按照Java正则表达式PATTERN将字符串s中符合条件的部分换成replacement所指定的字符串，如里replacement部分是空的话，那么符合正则的部分将被去掉  如：regexp_replace('foobar', 'oo|ar',  '') = ‘fb.’ 注意一些预定义字符的使用，如第二个参数如果使用’\s’将被匹配到s,’\\s’才是匹配空格STRINGrepeat(string  s, int n)重复输出n次字符串sSTRINGreverse(string  s)反转字符串sSTRINGspace(INT  n)返回n个空格ARRAY<STRING>split(STRING  s, STRING pattern)按照正则表达式pattern分割字符串s，并将分割后的部分以字符串数组的方式返回STRINGsubstr(BINARY  | STRING s, STRING start_index)substring(BINARY  | STRING s, STRING start_index)对于二进制字节串/字符串s，从start位置开始截取字符串并返回STRINGsubstr(BINARY  | STRING s, STRING start_index, INT len)substring(BINARY  | STRING s, STRING start_index, INT len)对于二进制/字符串s，从start位置开始截取长度为len的字符串并返回STRINGtranslate(STRING  input, STRING from, STRING to)将input出现在from中的字符串替换成to中的字符串  如：translate('MOBIN','BIN','M')='MOM'BINARYunbase64(STRING  str)将给予64位的字符串str转换成二进制值STRINGfrom_unixtime(BIGINT  unixtime[, string format])将时间戳秒数转换成UTC时间(从1970-01-01  00:00:00 UTC到指定时间的秒数)，并用字符串表示，可以通过format规定的时间格式，指定输出的时间格式BIGINTunix_timestamp()获取当前本地时区下的当前时间戳BIGINTunix_timestamp(STRING  date)输入的时间字符串格式必须是yyyy-MM-dd  HH:mm:ss, 如果不符合则返回0，如果符合则将此时间字符串转换成unxi时间戳。例如：unix_timestamp('2009-03-02 11:30:01') =  1237573801BIGINTunix_timestamp(STRING  date, STRING pattern)将指定时间字符串格式字符串转换成  unix时间戳，如果格式不对则返回0.例如unix_timestamp('2009-03-20', 'yyyy-MM-dd') =  1237532400STRINGto_date(STRING  timestamp)返回时间字符串的日期部分，例如：to_date('2018-11-26  21:56:31') = '2018-11-26'INTyear(STRING  date)返回时间字符串中的年份并使用INT类型表示。例如：year('2018-11-26 21:56:31') = 2018INTmonth(STRING  date)返回时间字符串中的月份并使用INT类型表示。例如：month('2018-11-26 21:56:31') = 11INTday(STRING  date)dayofmonth(STRING  date)返回时间字符串中的天并使用INT类型表示。例如：day('2018-11-26 21:56:31') = 26INThour(STRING  date)返回时间字符串中的天并使用INT类型表示。例如：hour('2018-11-26 21:56:31') = 21INTminute(STRING  date)返回时间字符串中的天并使用INT类型表示。例如：minute('2018-11-26 21:56:31') = 56INTsecond(STRING  date)返回时间字符串中的天并使用INT类型表示。例如：second('2018-11-26 21:56:31') = 31INTweekofyear(STRING  date)返回时间字符串中的天并使用INT类型表示。例如：weekofyear('2018-11-26 21:56:31') = 48INTdatediff(STRING  end_date, STRING start_date)计算开始时间start_date到结束时间end_date相差的天数。例如：datediff('2009-03-31', '2009-02-27') = 2STRINGdate_add(STRING  start_date, INT days)为开始时间start_date增加days天。例如date_add('2008-12-31',1)='2009-01-01'STRINGdate_sub(STRING  start_date, INT days)为开始时间start_date增加days天。例如date_add('2008-12-31',1)='2008-12-30'TIMESTAMPfrom_utc_timestamp(TIMESTAMP  timestamp, STRING timezone)如果给定的时间戳并非UTC，则将其转化成指定的时区下的时间戳TIMESTAMPto_utc_timestamp(TIMESTAMP  timestamp, STRING timezone)如果给定的时间戳是指定时区下的时间戳，则将其转化成UTC下的时间戳      


OLTP
OLAP

数仓模型：
-星型模型
-雪花模型


hql->解析器->编译器->优化器->执行

explain plan for ***
select * from table(dbms_xplan.display);
create index myindex on emp(empno);

hive安装模式：
嵌入模式
本地模式
远程模式

show tables;
show functions;

!linux命令

source ***.sql


select * 不会转化为MapReduce作业

hive -s  进入静默模式

hive --service hwi  web管理界面

hive --service hiveserver &  远程服务启动方式

内部表 (Table) 
与数据库中的Table在概念上是类似的
每一个Table在Hive中都有一个相应的目录存储数据
所有的Table数据（不包括External Table）都保存在这个目录中
删除表时，元数据与数据都会被删除

分区表（Partition）
Partition对应于数据库的Partition列的密集索引
在Hive中，表中的一个Partition对应于标下的一个目录，所有的Partition的数据都存储在对应的目录中

外部表(External Table)
-指向已经在HDFS中存在的数据，可以创建Partition
-它和内部表在元数据的组织上是相同的，而实际数据的存储则有较大的差异
-外部表只有一个过程，加载数据和创建表同时完成，并不会移动到数据仓库目录中，只是与外部数据建立一个链接。当删除一个外部表时，仅删除该链接。

桶表
-桶表时对数据进行哈希取值，然后放到不同文件中存储。


视图（View）
-视图时一种虚表，是一个逻辑概念；可以跨越多张表
-视图建立在已有表的基础上，视图赖以建立的这些表称为基表
-视图可以简化复杂的查询



create table t1
(tid int, tname string, age int);


create table t1
(tid int, tname string, age int)
location '/mytable/hive/t2';

create table t1
(tid int, tname string, age int)
row format delimited fields terminated by ',';

create table t4
as
select * from sample_data;

hdfs dfs -cat /user/hive/warehouse/t4000000_0

create table t5
row format delimited fields terminated by ',';
as
select * from sample_data;

alter table t1 add columns(english int);

drop table t1;


create table partition_table
(tid int, tname string, age int)
partitioned by (gender string)
row format delimited fields terminated by ',';

insert into table partition_table partition(gender='M') select * from sample_data where gender='M';

explain select * from sample_data;

hdfs dfs -put student01.txt /input
hdfs dfs -put student02.txt /input
hdfs dfs -put student03.txt /input

hdfs dfs -rm /input/student03.txt

create external table external_student
(tid int, tname string, age int)
partitioned by (gender string)
row format delimited fields terminated by ','
location '/input';

create table bucket_table
(tid int, tname string, age int)
clustered by(sname) into 5 buckets;

create view table_view
as
select *********

使用Load语句执行数据的导入
//导入单个文件
load data local inpath '/root/data/student01.txt' into table t2;
//导入整个目录下的数据
load data local inpath '/root/data/' overwrite into table t2;
//导入hdfs文件
load data inpath '/input/student01.txt' overwrite into table t2; 
//导入分区表
load data local inpath '/root/data/data1.txt' into table partition_table pertition(gender='M');


sqoop 导入

使用Sqoop导入Oracle数据到HDFS中
./sqoop import --connect jdbc:oracle:thin:@192.168.1.1:1521:orcl --username scott --password tiger --table emp -m 1 --columns 'empno,ename,job,sal,deptno' --target-dir '/sqoop/emp'


使用Sqoop导入Oracle数据到Hive中
./sqoop import --hive-import --connect jdbc:oracle:thin:@192.168.1.1:1521:orcl --username scott --password tiger --table emp -m 1 --columns 'empno,ename,job,sal,deptno'

使用Sqoop导入Oracle数据到Hive中, 并且指定表名
./sqoop import --hive-import --connect jdbc:oracle:thin:@192.168.1.1:1521:orcl --username scott --password tiger --table emp -m 1 --columns 'empno,ename,job,sal,deptno' --hive-table emp1

使用Sqoop导入Oracle数据到Hive中, 并且使用where条件
./sqoop import --hive-import --connect jdbc:oracle:thin:@192.168.1.1:1521:orcl --username scott --password tiger --table emp -m 1 --columns 'empno,ename,job,sal,deptno' --hive-table emp1 --where 'depno=10'

使用Sqoop导入Oracle数据到Hive中, 并且使用查询语句
./sqoop import --hive-import --connect jdbc:oracle:thin:@192.168.1.1:1521:orcl --username scott --password tiger -m 1 --query 'select * from emp where sal<2000 AND $CONDITIONS' --target-dir '/sqoop/emp5' --hive-table emp5

使用Sqoop将hive中的数据导出到Oracle数据库中
./sqoop export --connect jdbc:oracle:thin:@192.168.1.1:1521:orcl --username scott --password tiger -m 1 --table MYEMP --export-dir ******

hive中大部分的查询都会转化为MapReduce作业，但有少量不会转化，比如select *

简单查询的Fetch Task 功能
-set hive.fetch.task.conversion=more;
-hive --hiveconf hive.fetch.task.conversion=more;
-修改hive-site.xml文件
