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

* 空和非空-IS NULL和 IS NOT NULL

* IS DISTINCT FROM 和 IS NOT DISTINCT FROM

  presto的特有用法。在SQL种NULL表示一个已知的值，因此，任何比较相关的语句含有NULL，结果都是NULL。而 IS DISTINCT FROM 和 IS NOT DISTINCT FROM 运算符将NULL视为一个已知的值，这两个运算符保证即使输入中有NULL，结果也是TRUE或FALSE。

    select null is distinct from null =>false
  
    select null is not distinct from null => true

    a|b|a = b|a <> b|a DISTINCT b|a NOT DISTINCT b
    -|-|-|-|-|-
    1|1|TRUE|FALSE|FALSE|TRUE
    1|2|FALSE|TRUE|TRUE|FALSE
    1|NULL|NULL|NULL|TRUE|FALSE
    NULL|NULL|NULL|NULL|FALSE|TRUE

* 最大和最小-greatest(value1, value2) 和least(value1, value2)
  
  这两个函数不是SQL标准函数，他们是常用的扩展。 与Presto的其他数函数相似，任何一个参数为空，则返回空。 但是在某些其他数据库中，例如PostgreSQL， 只有全部参数都为空时，才返回空。

* 批量比较运算符-ALL, ANY and SOME

    表达式|含义
    -|-
    A = ALL (...)|当A等于所有值的时候返回TRUE.
    A <> ALL (...)|当A不等于所有值的时候返回TRUE.
    A < ALL (...)|当A小于所有值的时候返回TRUE.
    A = ANY (...)|当A等于任一值的时候返回TRUE. 等价于A IN (...).
    A <> ANY (...)|当A不等于任一值的时候返回TRUE.
    A < ANY (...)|当A小于任一值的时候返回TRUE.

### 条件表达式

* CASE

  简单模式：

    CASE expression
    WHEN value THEN result
    [ WHEN ... ]
    [ ELSE result ]
    END
  
  查找模式：

    CASE
    WHEN condition THEN result
    [ WHEN ... ]
    [ ELSE result ]
    END

* IF

  if(condition, true_value) -- 如果 condition 为真，返回 true_value；否则返回空，true_value 不进行计算

  if(condition, true_value, false_value) -- 如果 condition 为真，返回 true_value ； 否则计算并返回 false_value 。

* COALESCE

  coalesce(value1, value2[, ...]) -- 返回参数列表中的第一个非空 value 。 与 CASE 表达式相似，仅在必要时计算参数。

* NULLIF
 
  nullif(value1, value2) -- 如果 value1 与 value2 相等，返回空；否则返回 value1 。

* TRY

  try(expression) -- 评估一个表达式，如果出错，则返回Null。类似于编程语言中的try catch。try函数一般结合COALESCE使用，COALESCE可以将异常的空值转为0或者’’。以下情况会被try捕获:

  分母为0

  错误的cast操作或者函数入参

  数字超过了定义长度

  个人不推荐使用，应该明确以上异常，做数据预处理

### Lambda表达式

### 转换函数

* 转换函数

  cast(value AS type) → type  -- 显式转换一个值的类型。 可以将varchar类型的值转为数字类型，反过来转换也可以。

  try_cast(value AS type) → type -- 与 cast() 相似，区别是转换失败返回null。

* 数据大小

  parse_presto_data_size(string) -> decimal(38)

    SELECT parse_presto_data_size('1B'); -- 1
    SELECT parse_presto_data_size('1kB'); -- 1024
    SELECT parse_presto_data_size('1MB'); -- 1048576
    SELECT parse_presto_data_size('2.3MB'); -- 2411724

* 数据类型

  typeof(expr) → varchar -- 返回表达式的数据类型

### 数字函数和运算符

* 数字函数  

  * abs(x) → [same as input]          -- 返回x的绝对值
  * cbrt(x) → double                  -- 返回x的立方根
  * ceil(x) → [same as input]         -- 是ceiling()的同名方法
  * ceiling(x) → [same as input]      -- 返回x的向上取整的数值
  * degrees(x) → double               -- 返回x的度数值,从弧度弧度x转换为角度
  * e() → double                      -- 返回欧拉数的双重值
  * exp(x) → double                   -- 返回欧拉数的指数值
  * floor(x) → [same as input]        -- 返回x向下取整的数值
  * ln(x) → double                    -- 返回x的自然对数
  * log2(x) → double                  -- 返回x的基2的对数
  * log10(x) → double                 -- 返回x的基10对数
  * log(x,y) → double                 -- 返回x的基y对数
  * mod(n, m) → [same as input]       -- 返回n除以m的模数（余数）
  * pi() → double                     -- 返回pi的双重值
  * pow(x, p) → double                -- 是power()的同名方法
  * power(x, p) → double              -- 返回x的p次方
  * radians(x) → double               -- 返回x的弧度值,将角度x转换为弧度
  * rand() → double                   -- 弧度的别名
  * random() → double                 -- 返回伪随机值
  * random(n) → [same as input]       -- 
  * round(x) → [same as input]        -- 返回x的舍入值
  * round(x, d) → [same as input]     -- 第'd'小数位四舍五入的x值
  * sqrt(x) → double                  -- 返回x的平方根
  * truncate(x) → double              -- 截取x为整数
  * truncate(x,n) → double            -- 截取x小数点后n位




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
