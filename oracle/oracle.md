--------------------------------------------------------------------------------------------
-- 基数、选择性、数据分布
drop table test purge;
create table test as select * from dba_objects;

select * from test;

-- 基数：列的唯一值的数量
-- 基数越大， 说明这个列的重复数据越少
-- 主键列的基数等于表的总行数
select count(distinct owner) from test;
select count(distinct object_id), count(*) from test;


-- 选择性=列的基数/表的总行数*100%
select round(count(distinct owner) / count(*) * 100, 2) from test;
-- 主键列的选择性为100%
select round(count(distinct object_id) / count(*) * 100, 2) from test;


-- 查看列的数据分布
-- 通过查看列的数据分布可以知道列是否有倾斜， 进行等值访问最多返回多少行数据
-- 也可以得到两个表是几比几关系
select owner, count(*) cnt
  from test
 group by owner
 order by cnt desc;
 
 
-------------------------------------------------------------------------------------------- 
 
 
/*******注意：TP系统生产环境不能指定HINT*******/


-- 全表扫描 TABLE ACCESS FULL
-- 会扫描表所有的数据
-- 多块度
-- hint写法为 /*+ full(表别名/表名) */
-- 可开并行提升性能(OLAP系统才这么干)


/****************************
索引扫描方式
****************************/
drop table test purge;
create table test as select * from dba_objects;

-- INDEX UNIQUE SCAN
-- 无需指定hint， 有索引会自动走
-- 单表扫描走INDEX UNIQUE SCAN不会出性能问题
-- 只会返回一行数据
drop index idx_id;
create unique index idx_id on test(object_id);

select * from test where object_id = 1;


-- INDEX RANGE SCAN
-- 单块读
-- hint写法为 /*+ index(别名/表名 索引名)*/
-- 返回过多数据会出性能问题
-- 返回的数据是有序的
select * from test where object_id between 100 and 200;
select * from test where object_id < 200;



-- INDEX FULL SCAN 
-- INDEX FULL SCAN DESCENDING
-- 单块读
-- hint写法为 /*+ index(别名/表名 索引名) */  /*+ index_desc(别名/表名 索引名) */
-- 返回的数据是有序的
-- 会顺序扫描所有的索引叶子块
-- 如果叶子块数量非常多， 会出严重的性能问题， 如果还需要回表，那就更惨了
select * from test where object_id is not null order by object_id
 

-- INDEX FULL SCAN (MIN/MAX)
-- 只会返回索引叶子快最左侧或最右侧的第一行数据， 性能相当于INDEX UNIQUE SCAN
select max(object_id) from test;
select min(object_id) from test;


-- INDEX FAST FULL SCAN
-- hint写法为 /*+ INDEX_FFS(表别名/表名 索引名) */
-- 多块读
-- 返回的数据是无序的
-- 可开并行提升性能
-- 不可回表
select count(*) from test where object_id is not null;

create index idx_mx on test(owner, object_name);

select owner, object_name from test where owner is not null



-- INDEX SKIP SCAN
-- 单块读
-- 返回的数据有有序的
-- 相当于多次INDEX RANGE SCAN
-- 只能是组合索引的前导列不在where过滤条件中,而是第二列在过滤条件中,这时候就会走INDEX SKIP SCAN
-- 如果在执行计划中发现走了INDEX SKIP SCAN, 必须要手动检查索引的前导列基数，如果基数特别高， 那么这个执行计划就是错的

create index idx_owner_id on test(owner, object_id);
-- 收集表的统计信息
begin
  dbms_stats.gather_table_stats(ownname          => user,
                                tabname          => 'TEST',
                                estimate_percent => 100,
                                method_opt       => 'for all columns size 1',
                                degree           => 8,
                                cascade          => true,
                                no_invalidate    => false);
end;
/

select * from test where object_id = 10;



-- TABLE ACCESS BY INDEX ROWID 回表
-- 通过索引里的rowid去表里面查询数据就叫做回表
-- 回表一般是单块读
-- 做SQL优化的时候一定要注意回表的次数， 特别是回表物理IO的次数


 date转char
select to_char(sysdate,'day') from dual;
select to_char(sysdate,'yyyy-mm-dd hh24:mi:ss') from dual;
select to_char(sysdate,'yyyy') from dual;
select to_char(sysdate,'mm') from dual;
select to_char(sysdate,'dd') from dual;
select to_char(sysdate,'hh24') from dual;
select to_char(sysdate,'mi') from dual;
select to_char(sysdate,'ss') from dual;

        char转date
select to_date('2018-11-20 17:45:10','yyyy-mm-dd hh24:mi:ss') from dual

1.日期时间间隔操作 
//当前时间减去7分钟的时间 
select sysdate,sysdate - interval '7' MINUTE from dual 
//当前时间减去7小时的时间 
select sysdate - interval '7' hour from dual 
//当前时间减去7天的时间 
select sysdate - interval '7' day from dual 
//当前时间减去7月的时间 
select sysdate,sysdate - interval '7' month from dual 
//当前时间减去7年的时间 
select sysdate,sysdate - interval '7' year from dual 
//时间间隔乘以一个数字 
select sysdate,sysdate - 8 *interval '2' hour from dual



1. 复制表结构及其数据：
create table table_name_new as select * from table_name_old

2. 只复制表结构：
create table table_name_new as select * from table_name_old where 1=2;
或者：
create table table_name_new like table_name_old
 
3. 只复制表数据：
如果两个表结构一样：
insert into table_name_new select * from table_name_old
如果两个表结构不一样：
insert into table_name_new(column1,column2...) select column1,column2... from table_name_old
4.创建同义词
create public synonym tradedate_bak_sy for jrtzhg.tradedate_bak_sy;
