# [presto](https://prestodb.github.io/)

## Install

## Date Types

目前presto支持有限的数据类型，这些类型可以进行标准的类型转换操作。

* Boolean
    * BOOLEAN `此类型获取布尔值 true 和 false 。`
* Integer
    * TINYINT 8位有符号二补整数，最大值为-**2^7**，最小值位***2^7-1***
    * SMALLINT
    * INTEGER
    * BIGINT
* 
* 
* 
* 
* 
* 
* 


## Functions & Operators

### 日期时间函数和运算符
运算符|示例|结果
:-:|-|-
+|date '2019-08-14' + interval '2' day|2019-08-16
+|time '01:00' + interval '3' hour|04:00:00.000
+|timestamp '2019-08-14 01:00' + interval '29' hour|2019-08-15 06:00:00.000
+|timestamp '2012-10-31 01:00' + interval '1' month|2012-11-30 01:00:00.000
+|interval '2' day + interval '3' hour|2 03:00:00.000
+|interval '3' year + interval '5' month|3-5
-|date '2012-08-08' - interval '2' day|2012-08-06
-|time '01:00' - interval '3' hour|22:00:00.000
-|timestamp '2012-08-08 01:00' - interval '29' hour|2012-08-06 20:00:00.000
-|timestamp '2012-10-31 01:00' - interval '1' month|2012-09-30 01:00:00.000
-|interval '2' day - interval '3' hour|1 21:00:00.000
-|interval '3' year - interval '5' month|2-7
