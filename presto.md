# [presto](https://prestodb.github.io/)

## Install

## Date Types

目前presto支持有限的数据类型，这些类型可以进行标准的类型转换操作。

* Boolean
    * BOOLEAN `此类型获取布尔值 true 和 false 。`
* Integer
    * TINYINT-8位有符号二补整数，最大值为-***2^7***，最小值位***2^7-1***
    * SMALLINT-16位有符号二补整数，最大值为-***2^15***，最小值位***2^15-1***
    * INTEGER-32位有符号二补整数，最大值为-***2^31***，最小值位***2^31-1***，也可以用 ***INT***代替
    * BIGINT-64位有符号二补整数，最大值为-***2^63***，最小值位***2^63-1***
* Floating-Point
    * REAL-32位不精确，可变精度， 基于IEEE标准754的二进制浮点算法的实现
    * DOUBLE-64位不精确，可变精度， 基于IEEE标准754的二进制浮点算法的实现
* Fixed-Precision
    * DECIMAL-固定精度的小数，支持高达38位的精度，但性能表现最好是18位
* String
    * VARCHAR-变长字符数据
    * CHAR-定长字符数据
    * VARBINARY-变长二进制数据
    * JSON-json类型的数据可以是JSON对象、JSON数组、JSON数字、JSON字符串、true、false或null
* Date and Time
    * DATE-日历日期（年，月，日），eg `DATE '2001-08-22'`
    * TIME-一天中的时间（小时，分钟，秒，毫秒），无时区。 此类型的值在会话时区进行解析并转换。eg `TIME '01:02:03.456'`
    * TIME WITH TIME ZONE-一天中的时间（小时，分钟，秒，毫秒），有时区。 此类型的值使用指定的时区进行转换。ge TIME `'01:02:03.456 America/Los_Angeles'`
    * TIMESTAMP-一天中的某一瞬间，包括日期和时间，无时区。 此类型的值在会话时区进行解析并转换。eg `TIMESTAMP '2001-08-22 03:04:05.321'`
    * TIMESTAMP WITH TIME ZONE-一天中的某一瞬间，包括日期和时间，无时区。 此类型的值使用指定的时区进行转换。eg `TIMESTAMP '2001-08-22 03:04:05.321 America/Los_Angeles'`
    * INTERVAL YEAR TO MONTH-年和月的跨度。eg `INTERVAL '3' MONTH`
    * INTERVAL DAY TO SECOND-天、小时、分钟、秒和毫秒的跨度。eg `INTERVAL '2' DAY`
* Structural
    * ARRAY-给定类型的数组。eg `ARRAY[1, 2, 3]`
    * MAP-给定类型的map。eg `MAP(ARRAY['foo', 'bar'], ARRAY[1, 2])`
    * ROW-由名字字段组成的结构。可以是任何SQL类型的字段， 使用字段操作符`.`访问。eg `my_column.my_field`
* Network Address
    * IPADDRESS
* HyperLogLog
    * HyperLogLog
    * P4HyperLogLog
* Quantile Digest
    * QDigest

## Functions & Operators

### 逻辑运算符

* 逻辑运算符

    运算符|描述|示例
    :-:|-|-
    AND|True if both values are true|a AND b
    OR|True if either value is true|a OR b
    NOT|True if the value is false|NOT a

* 逻辑运算符中NULL的效果

    **如果AND表达式中有一边或者两边都是null，那么整个AND表达式的结果将会是null。如果AND表达式中至少有一边的值是false，那么整个AND表达式的值都是false。**

    **如果OR表达式的一边或者两边都是null，那么整个OR表达式的值就是null。如果OR表达式中只要有一边的值为true，那么整个OR表达式的值就是true。**

    a|b|a AND b|a OR b
    -|-|-|-
    TRUE|TRUE|TRUE|TRUE
    TRUE|FALSE|FALSE|TRUE
    TRUE|NULL|NULL|TRUE
    FALSE|TRUE|FALSE|TRUE
    FALSE|FALSE|FALSE|FALSE
    FALSE|NULL|FALSE|NULL
    NULL|TRUE|NULL|TRUE
    NULL|FALSE|FALSE|NULL
    NULL|NULL|NULL|NULL

    **NULL的NOT表达式的结果还是NULL**

    a|NOT a
    -|-
    TRUE|FALSE
    FALSE|TRUE
    NULL|NULL

### 比较函数和运算符

* 比较运算符

    运算符|描述
    -|-
    `<`|小于
    `>`|大于
    `<=`|小于等于
    `>=`|大于等于
    `=`|等于
    `<>`|不等
    `!=`|不等（不标准的用法，但是很流行这样使用）

* 范围运算符-BETWEEN和NOT BETWEEN

    a|b|a = b|a <> b|a DISTINCT b|a NOT DISTINCT b
    -|-|-|-|-|-
    1|1|TRUE|FALSE|FALSE|TRUE
    1|2|FALSE|TRUE|TRUE|FALSE
    1|NULL|NULL|NULL|TRUE|FALSE
    NULL|NULL|NULL|NULL|FALSE|TRUE

* 空和非空-IS NULL和 IS NOT NULL

* 最大和最小-greatest(value1, value2) 和least(value1, value2)

* 

### 条件表达式




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
