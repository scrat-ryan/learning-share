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

* 三角函数.

  所有三角函数的参数都是以弧度表示。参考单位转换函数degrees() 和 radians()

  * acos(x) → double                     -- 返回反余弦值（x）
  * asin(x) → double                     -- 返回正弦值（x）
  * atan(x) → double                     -- 返回反正切值（x）
  * atan2(y, x) → double                 -- 返回反正切值（y / x）
  * cos(x) → double                      -- 返回余弦值（x）
  * cosh(x) → double                     -- 返回双曲余弦值（x）
  * sin(x) → double                      -- 返回正弦值（x）
  * tan(x) → double                      -- 返回正切值（x）
  * tanh(x) → double                     -- 返回双曲正切值（x）

### 字符串函数和运算符

* 字符串运算符

  使用运算符： || 完成字符串连接

* 字符串函数

  * chr(n) → varchar                            -- 返回在下标为n的位置的char字符的字符串格式表示,`select chr(100)-->d`
  * codepoint(string) → integer                 -- 返回字符串string的asc码,`select codepoint(d)-->100`
  * concat(string1, ..., stringN) → varchar     -- 字符串拼接, 可用||代替
  * hamming_distance(string1, string2)→ bigint  -- 返回两个等长字符串的汉明距离【表示两个等长字符串在对应位置上不同字符的数目】
  * length(string) → bigint                     -- 返回字符串的长度
  * lower(string) → varchar                     -- 将转换为小写
  * lpad(string, size, padstring) → varchar     -- 从左边对字符串使用指定的字符进行填充
  * ltrim(string) → varchar                     -- 去掉字符串开头的空格
  * replace(string, search) → varchar           -- 去掉字符串种所有search实例
  * replace(string, search, replace) → varchar  -- 将字符串中所有search实例替换为replace
  * reverse(string) → varchar                   -- 字符串反转
  * rpad(string, size, padstring) → varchar     -- 从右边对字符串使用指定的字符进行填充
  * rtrim(string) → varchar                     -- 去掉字符串末尾的空格
  * split(string, delimiter) -> array(varchar)  -- 按照指定分隔符切分字符串为一个array
  * split(string, delimiter, limit) -> array(varchar) -- 按照指定分隔符切分字符串为一个array,限定数量。最后一个元素包含了最后一个字符串后面所有的字符。Limit 必须是个数字
  * split_part(string, delimiter, index) → varchar -- 按照指定分隔符切分字符串为一个array,index从1开始,如果Index超过了数组长度,则返回null。
  * split_to_map(string, entryDelimiter, keyValueDelimiter) → map<varchar, varchar>  -- 按照entryDelimiter和keyValueDelimiter分隔符切分字符串为一个map。entryDelimiter将字符串切分为key-value键值对，KeyValueDelimiter将每一个键值对切分为key和value。`select split_to_map('key1,value1\key2,value2','\',',') --> {key1=value1, key2=value2}`
  * split_to_map(string, entryDelimiter, keyValueDelimiter, function(k, v1, v2, res)) → map<varchar, varchar>  -- 出现相同的key，按照function确定value。 SELECT(split_to_map('a:1;b:2;a:3', ';', ':', (k, v1, v2) -> v1)); --> {a=1, b=2}
  * split_to_multimap(string, entryDelimiter, keyValueDelimiter) → (varchar, array(varchar))  -- 每一个key对应的value为一个数组  `select split_to_multimap('a:1;b:2;a:3', ';', ':') --> {a=[1, 3], b=[2]}`
  * strpos(string, substring) → bigint             -- 返回字符串中第一次出现substring的位置。从1开始，如果未找到，返回0。
  * index(string, substring) → bigint              -- 同上
  * strpos(string, substring, instance) → bigint 
  * strrpos(string, substring) → bigint            -- 返回字符串中最后一次出现substring的位置。从1开始，如果未找到，返回0。
  * strrpos(string, substring, instance) → bigint 
  * position(substring IN string) → bigint         -- 返回substring首次出现在string中的位置,没有返回0`SELECT position('11122' in 'fsd11122ghjnk')`
  * substr(string, start) → varchar                -- 从start位置开始 截取字符串【起始为1】
  * substring(string, start) → varchar             -- 同上
  * substr(string, start, length) → varchar        -- 从start位置开始 截取字符串,截取的长度为length。
  * substring(string, start, length) → varchar     -- 同上
  * trim(string) → varchar                         -- 去掉字符串种的空格
  * upper(string) → varchar                        -- 将字符串转换为大写
  * word_stem(word) → varchar
  * word_stem(word, lang) → varchar

### 正则表达式

  所有的正则表达式函数都使用Java样式的语法

  * regexp_extract_all(string, pattern) -> array(varchar)  -- 返回与模式的正则表达式匹配的字符串`select regexp_extract_all('1a 2b 14m', '\d+'); --> [1, 2, 14]`
  * regexp_extract_all(string, pattern, group) -> array(varchar) -- 返回与模式和组的正则表达式匹配的字符串`select regexp_extract_all('1a 2b 14m', '(\d+)([a-z]+)', 2)`
  * regexp_extract(string, pattern) → varchar              -- 返回与模式的正则表达式匹配的第一个子串`select regexp_extract('1a 2b 14m', '\d+'); --> 1`
  * regexp_extract(string, pattern, group) → varchar       -- 返回与模式和组的正则表达式匹配的第一个子字符串`返回与模式和组的正则表达式匹配的第一个子字符串`
  * regexp_like(string, pattern) → boolean                 -- 返回模式的字符串匹配。如果返回字符串，则该值将为true，否则为false`select regexp_like('1a 2b 14m', '\d+b'); --> true`
  * regexp_replace(string, pattern) → varchar              -- 移除模式的字符串匹配`select regexp_replace('1a 2b 14m', '\d+[ab] '); --> '14m'`
  * regexp_replace(string, pattern, replacement) → varchar -- 替换模式的字符串匹配`select regexp_replace('1a 2b 14m', '(\d+)([ab]) ', '3c$2 '); --> '3ca 3cb 14m'`
  * regexp_replace(string, pattern, function) → varchar    -- 按照function替换模式的字符串匹配`SELECT regexp_replace('new yOrK', '(\w)(\w*)', x -> upper(x[1]) || lower(x[2])); --> New York`
  * regexp_split(string, pattern) -> array(varchar)        -- 拆分给定模式的正则表达式`select regexp_split('1a 2b 14m', '\s*[a-z]+\s*'); --> [1, 2, 14, ]`

### JSON函数和运算符

* 转换为JSON

      SELECT CAST(NULL AS JSON); --> NULL
      SELECT CAST(1 AS JSON); --> JSON '1'
      SELECT CAST(9223372036854775807 AS JSON); --> JSON '9223372036854775807'
      SELECT CAST('abc' AS JSON); --> JSON '"abc"'
      SELECT CAST(true AS JSON); --> JSON 'true'
      SELECT CAST(1.234 AS JSON); --> JSON '1.234'
      SELECT CAST(ARRAY[1, 23, 456] AS JSON); --> JSON '[1,23,456]'
      SELECT CAST(ARRAY[1, NULL, 456] AS JSON); --> JSON '[1,null,456]'
      SELECT CAST(ARRAY[ARRAY[1, 23], ARRAY[456]] AS JSON); --> JSON '[[1,23],[456]]'
      SELECT CAST(MAP_FROM_ENTRIES(ARRAY[('k1', 1), ('k2', 23), ('k3', 456)]) AS JSON); --> JSON '{"k1":1,"k2":23,"k3":456}'
      SELECT CAST(CAST(ROW(123, 'abc', true) AS ROW(v1 BIGINT, v2 VARCHAR, v3 BOOLEAN)) AS JSON); --> JSON '[123,"abc",true]'

* JSON转换为其他数据类型 

      SELECT CAST(JSON 'null' AS VARCHAR); --> NULL
      SELECT CAST(JSON '1' AS INTEGER); --> 1
      SELECT CAST(JSON '9223372036854775807' AS BIGINT); --> 9223372036854775807
      SELECT CAST(JSON '"abc"' AS VARCHAR); --> abc
      SELECT CAST(JSON 'true' AS BOOLEAN); --> true
      SELECT CAST(JSON '1.234' AS DOUBLE); --> 1.234
      SELECT CAST(JSON '[1,23,456]' AS ARRAY(INTEGER)); --> [1, 23, 456]
      SELECT CAST(JSON '[1,null,456]' AS ARRAY(INTEGER)); --> [1, NULL, 456]
      SELECT CAST(JSON '[[1,23],[456]]' AS ARRAY(ARRAY(INTEGER))); --> [[1, 23], [456]]
      SELECT CAST(JSON '{"k1":1,"k2":23,"k3":456}' AS MAP(VARCHAR, INTEGER)); --> {k1=1, k2=23, k3=456}
      SELECT CAST(JSON '{"v1":123,"v2":"abc","v3":true}' AS ROW(v1 BIGINT, v2 VARCHAR, v3 BOOLEAN)); --> {v1=123, v2=abc, v3=true}
      SELECT CAST(JSON '[123,"abc",true]' AS ROW(v1 BIGINT, v2 VARCHAR, v3 BOOLEAN)); --> {value1=123, value2=abc, value3=true}

* JSON函数

  * json_array_contains(json, value) → boolean  -- 判断value是否在json（json格式的字符串）中存在`SELECT json_array_contains('[1, 2, 3]', 2); --> true`
  * json_array_get(json_array, index) → json    -- 获取json数组中索引的元素,索引下标从0开始,-1表示最后一个。如果索引下标不存在，返回null。

        SELECT json_array_get('["a", [3, 9], "c"]', 0);  --> JSON 'a'
        SELECT json_array_get('["c", [3, 9], "a"]', -1); --> JSON 'a'
        SELECT json_array_get('["c", [3, 9], "a"]', -2); --> JSON '[3,9]'
        SELECT json_array_get('[]', 0); --> null
        SELECT json_array_get('["a", "b", "c"]', 10); --> null
        SELECT json_array_get('["c", "b", "a"]', -10); --> null
  
  * json_array_length(json) → bigint  -- 返回json数组中的长度`SELECT json_array_length('[1, 2, 3]');  --> 3`
  * json_format(json) → varchar       -- 返回json结构格式

        SELECT json_format(JSON '{"a": 1, "b": 2}'); --> '{"a":1,"b":2}'
        SELECT json_format(JSON '[1, 2, 3]'); --> '[1,2,3]'
        SELECT json_format(JSON '"abc"'); --> '"abc"'
        SELECT json_format(JSON '42'); --> '42'
        SELECT json_format(JSON 'true'); --> 'true'
        SELECT json_format(JSON 'null'); --> 'null'
  
  * json_parse(string) → json         -- 将字符串解析成json

        SELECT json_parse('not_json'); --> ERROR!
        SELECT json_parse('["a": 1, "b": 2]'); --> JSON '["a": 1, "b": 2]'
        SELECT json_parse('[1, 2, 3]'); --> JSON '[1,2,3]'
        SELECT json_parse('"abc"'); --> JSON '"abc"'
        SELECT json_parse('42'); --> JSON '42'
        SELECT json_parse('true'); --> JSON 'true'
        SELECT json_parse('null'); --> JSON 'null'

  * json_size(json, json_path) → bigint

### 日期时间函数和运算符

* 日期时间运算符

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

* 日期时间函数

  * current_date -> date                           -- 返回当前日期
  * current_time -> time with time zone            -- 返回当前时间
  * current_timestamp -> timestamp with time zone  -- 返回当前时间戳
  * current_timezone() → varchar                   -- 返回当前时区
  * now()                                          -- 效果同current_timestamp
  * localtime                                      -- 获取当地时间
  * localtimestamp                                 -- 获取当地时间戳
  * date(x) → date                                 -- 将x转换为日期,同CAST(x AS date). `select date('2019-08-30')  --> data 2019-08-30`
  * from_unixtime(unixtime) → timestamp            -- 将unix时间戳转换为时间戳   `select from_unixtime(1149578976)  --> 2006-06-06` 15:29:36.000
  * to_milliseconds(interval) → bigint             -- 将interval数据转换为毫秒。 `select to_milliseconds(interval '1' day) --> 86400000`
  * to_unixtime(timestamp) → double                -- 将时间戳转换为unixtime。   `to_unixtime(timestamp '2012-09-30 01:00:00') --> 1348938000`

* 截取函数

  * date_trunc(unit, x) → [same as input]          -- 返回x截取到单位unit之后的值。以 2001-08-22 03:04:05.321 作为输入，不同单位截取后的值为

    单位|x
    -|-
    second|2001-08-22 03:04:05.000
    minute|2001-08-22 03:04:00.000
    hour|2001-08-22 03:00:00.000
    day|2001-08-22 00:00:00.000
    week|2001-08-20 00:00:00.000
    month|2001-08-01 00:00:00.000
    quarter|2001-07-01 00:00:00.000
    year|2001-01-01 00:00:00.000

* 间隔函数

  * 本函数支持如下所列的间隔单位

    单位|描述
    -|-
    second|秒
    minute|分
    hour|时
    day|天
    week|周
    month|月
    quarter|季
    year|年

  * date_add(unit, value, timestamp) → [same as input]

    在timestamp的基础上加上value个unit。如果想要执行相减的操作，可以通过将value赋值为负数来完成。

  * date_diff(unit, timestamp1, timestamp2) → bigint 

    返回 timestamp2 - timestamp1 之后的值，该值的表示单位是unit。

* 期间函数

  * parse_duration支持如下所列的单位

    单位|描述
    -|-
    ns|Nanoseconds
    us|Microseconds
    ms|Milliseconds
    s|Seconds
    m|Minutes
    h|Hours
    d|Days

    parse_duration(string) → interval     -- 将一个格式化的字符串值单位转化成一个interval，值是单位的最小组成部分.

        SELECT parse_duration('42.8ms'); -- 0 00:00:00.043
        SELECT parse_duration('3.81 d'); -- 3 19:26:24.000
        SELECT parse_duration('5m');     -- 0 00:05:00.000

* MySQL日期函数

  在这一章节中使用与MySQLdate_parse和str_to_date相兼容的格式化字符串。下面的表格是基于MySQL使用手册列出的，描述了各种格式化描述符：

  Specifier|Description
  -|-
  %a|Abbreviated weekday name (Sun .. Sat)
  %b|Abbreviated month name (Jan .. Dec)
  %c|Month, numeric (1 .. 12)
  %D|Day of the month with English suffix (0th, 1st, 2nd, 3rd, …)
  %d|Day of the month, numeric (01 .. 31)
  %e|Day of the month, numeric (1 .. 31) 
  %f|Fraction of second (6 digits for printing: 000000 .. 999000; 1 - 9 digits for parsing: 0 .. 999999999) 
  %H|Hour (00 .. 23)
  %h|Hour (01 .. 12)
  %I|Hour (01 .. 12)
  %i|Minutes, numeric (00 .. 59)
  %j|Day of year (001 .. 366)
  %k|Hour (0 .. 23)
  %l|Hour (1 .. 12)
  %M|Month name (January .. December)
  %m|Month, numeric (01 .. 12) 
  %p|AM or PM
  %r|Time, 12-hour (hh:mm:ss followed by AM or PM)
  %S|Seconds (00 .. 59)
  %s|Seconds (00 .. 59)
  %T|Time, 24-hour (hh:mm:ss)
  %U|Week (00 .. 53), where Sunday is the first day of the week
  %u|Week (00 .. 53), where Monday is the first day of the week
  %V|Week (01 .. 53), where Sunday is the first day of the week; used with %X
  %v|Week (01 .. 53), where Monday is the first day of the week; used with %x
  %W|Weekday name (Sunday .. Saturday)
  %w|Day of the week (0 .. 6), where Sunday is the first day of the week (1-7)
  %X|Year for the week where Sunday is the first day of the week, numeric, four digits; used with %V
  %x|Year for the week, where Monday is the first day of the week, numeric, four digits; used with %v
  %Y|Year, numeric, four digits
  %y|Year, numeric (two digits) 
  %%|A literal % character
  %x|x, for any x not listed above

  * date_format(timestamp, format) → varchar     -- 使用format指定的格式，将timestamp格式化成字符串。

  * date_parse(string, format) → timestamp       -- 按照format指定的格式，将字符串string解析成timestamp。

* 抽取函数

  可以使用抽取函数来抽取如下域：

  Field|Description
  YEAR|year()
  QUARTER|quarter()
  MONTH|month()
  WEEK|week()
  DAY|day()
  DAY_OF_MONTH|day()
  DAY_OF_WEEK|day_of_week()
  DOW|day_of_week()
  DAY_OF_YEAR|day_of_year()
  DOY|day_of_year()
  YEAR_OF_WEEK|year_of_week()
  YOW|year_of_week()
  HOUR|hour()
  MINUTE|minute()
  SECOND|second()
  TIMEZONE_HOUR|timezone_hour()
  TIMEZONE_MINUTE|timezone_minute()

  * extract(field FROM x) → bigint      -- 从x中返回域field `SELECT extract(DAY_OF_YEAR FROM current_timestamp )`

* 便利的抽取函数

  * day(x) / day_of_month(x)   → bigint
  * day_of_week(x) / dow(x)    → bigint
  * day_of_year(x) / doy(x)    → bigint
  * hour(x)                    → bigint
  * millisecond(x)             → bigint
  * minute(x)                  → bigint
  * month(x)                   → bigint
  * quarter(x)                 → bigint
  * second(x)                  → bigint
  * timezone_hour(timestamp)   → bigint
  * timezone_minute(timestamp) → bigint
  * week(x) / week_of_year(x)  → bigint
  * year(x)                    → bigint
  * year_of_week(x) / yow(x)   → bigint

### 聚合函数

  聚合函数作用于一个数据集，计算出一个单独的结果。

  除了count(),count_if(),max_by(),min_by()和approx_distinct(),所有的聚合函数都忽略空值，只有在没有输入或者所有输入都为空值时才会返回null。例如，sum()返回空值而不是0，avg()不会将空值值进行计数，coalesce可以将空值转换为0。

* 一般聚合函数

  * arbitrary(x) → [same as input]               -- 返回*x*的任意非空值（如果存在的话）
  * array_agg(x) → array<[same as input]>        -- 将*x*的输入聚合为一个数组返回
  * avg(x) → double                              -- 返回输入值的平均数（算术平均数）
  * avg(time interval type) → time interval type -- 返回输入的平均间隔长度
  * bool_and(boolean) / every(boolean) → boolean -- 如果所有输入都为true返回true，否则返回false
  * bool_or(boolean) → boolean                   -- 如果任何一个输入值为true返回true，否则返回false
  * checksum(x) → varbinary                      -- 返回x的校验和（顺序不敏感）
  * count(`*`) → bigint                          -- 返回输入行的数量
  * count(x) → bigint                            -- 返回非空输入值的数量
  * count_if(x) → bigint                         -- 返回输入值为 TRUE 的数量，等价于count(CASE WHEN x THEN 1 END)
  * geometric_mean(x) → double                   -- 返回输入值的几何平均数
  * max_by(x, y) → [same as x]                   -- 返回与y的最大值关联的x的值【同行的x】
  * max_by(x, y, n) → array<[same as x]>         -- 返回与y的前n个最大值关联的x的值的数组
  * min_by(x, y) → [same as x]                   -- 返回与y的最小值关联的x的值【同行的x】
  * min_by(x, y, n) → array<[same as x]>         -- 返回与y的前n个最小值关联的x的值的数组
  * max(x) → [same as input]                     -- 返回输入值的最大值
  * max(x, n) → array<[same as x]>               -- 返回输入值的前n个最大值
  * min(x) → [same as input]                     -- 返回输入值的最小值
  * min(x, n) → array<[same as x]>               -- 返回输入值的前n个最大值
  * sum(x) → [same as input]                     -- 返回全部输入值的和

* 位运算聚合函数

  * bitwise_and_agg(x) → bigint                  -- 返回 x 中所有值的与操作结果，x 为数组
  * bitwise_or_agg(x) → bigint                   -- 返回 x 中所有值的或操作结果，x 位数组

* Map聚合函数

  * histogram(x) -> map(K, bigint)               -- 统计每一个输入值的count数量，返回map，即统计分布直方图
  * map_agg(key, value) -> map(K, V)             -- 以输入的key/value键值对返回一个map
  * multimap_agg(key, value) -> map(K, array(V)) -- 创建一个多重映射的MAP变量

* 近似聚合函数
  
  * 

* 统计聚合函数

  * stddev(x) / stddev_samp()  → double          -- 返回全部输入值的样本标准偏差
  * stddev_pop(x) → double                       -- 返回全部输入值的总体标准偏差
  * variance(x) / var_samp(x) → double           -- 返回全部输入值的样本方差
  * var_pop(x) → double                          -- 返回全部输入值的总体方差

### 窗口函数

  窗口函数运行在HAVING语句之后，但是运行在ORDER BY语句之前。如果想要调用窗口函数，需要使用OVER语句来指定窗口。一个窗口有3个组成部分。

  * The partition specification, which separates the input rows into different partitions. This is analogous to how the GROUP BY clause separates rows into different groups for aggregate functions
  * The ordering specification, which determines the order in which input rows will be processed by the window function
  * The window frame, which specifies a sliding window of rows to be processed by the function for a given row. If the frame is not specified, it defaults to *RANGE UNBOUNDED PRECEDING*, which is the same as *RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW*. This frame contains all rows from the start of the partition up to the last peer of the current row

* 聚合函数

  所有的聚合函数加上*over*都可以变成窗口函数,聚合函数计算的是当前行所对应的所有窗口行

* 排序函数

  * cume_dist() → bigint        -- 小于等于当前值的行数/分组内总行数（没有order by 的话结果为1.0,否则结果<=1.0）
  * dense_rank() → bigint       -- 排序，相同值排名相同，出现相同排名时，将不跳过相同排名号，rank值紧接上一次的rank值
  * rank() → bigint             -- 排序，相同值排名相同，出现相同排名时，将跳过相同排名号，rank值不会紧接上一次的rank值
  * row_number() → bigint       -- 排序，从1开始，无重复序号
  * percent_rank() → double     -- 分组内当前行的RANK值-1/分组内总行数-1
  * ntile(n) → bigint           -- 用于将分组数据按照顺序切分成n片，返回当前切片值

* 值函数

  * first_value(x) → [same as input]                      -- 首次出现
  * last_value(x) → [same as input]                       -- 最后出现
  * nth_value(x, offset) → [same as input]                -- 取x排序的第offset个值
  * lead(x[, offset[, default_value]]) → [same as input]  -- 前offset个
  * lag(x[, offset[, default_value]]) → [same as input]   -- 后offset个

### 数组函数和运算符

* 下表运算符 `[]`【下表从1开始】
* 连接运算符 `||`【类型必须相同】
* 数组函数
  * array_distinct(x) → array      -- 移除x中重复的元素并返回剩下的
  * array_intersect(x, y) → array  -- 返回数组x和数组y的交集，结果去重
  * array_union(x, y) → array      -- 返回数组x和数组y的并集，结果去重
  * array_except(x, y) → array     -- 返回数组x-数组y的差集，结果去重【在x不在y】
  * array_join(x, delimiter, null_replacement) → varchar  -- 将数组中的所有元素以delimiter指定的分隔符连接起来，null值用null_value_replacement代替，返回一个字符串
  * array_max(x) → x               -- 返回数组x的最大值
  * array_min(x) → x               -- 返回数组x的最小值
  * array_position(x, element) → bigint  --  返回element首次出现再x中的位置，没有返回0
  * array_remove(x, element) → array     --  移除x中所有等于element的元素
  * array_sort(x) → array                --  将x重新排序排序后返回，element必须支持比较操作，null值放在最后
  * array_sort(array(T), function(T, T, int)) -> array(T)  -- array根据给定的比较函数function排序并返回。比较函数采用两个可空的参数来表示array两个可以为空的元素。当第一个可空元素小于，等于或大于第二个可空元素时，它返回-1,0或1。如果比较函数返回其他值（包括NULL），则查询将失败并引发错误
  * arrays_overlap(x, y) → boolean  -- 测试数组x和y是否有任何共同的非空元素。如果没有公共的非空元素，但是两个数组都包含null，则返回null
  * cardinality(x) → bigint   -- 返回数组的基数【即长度】
  * concat(array1, array2, ..., arrayN) → array     -- 连接数组array1，array2，...，arrayN，功能同||运算符，不去重
  * contains(x, element) → boolean    -- 如果数组x包含element返回true, 否则返回false
  * element_at(array(E), index) → E   -- 返回array给定的元素是否在给定的索引index。如果index> 0，则此函数提供与SQL标准下标运算符（[]）相同的功能。如果index<0，则element_at从最后到第一个的元素访问到第一个元素
  * filter(array(T), function(T, boolean)) -> array(T)  -- 把函数function返回true的元素来构造新数组
  * flatten(x) → array                -- `flatten(array [array [1,2,2], array [1,3,3,4]])->[1, 2, 2, 1, 3, 3, 4]`
  * ngrams(array(T), n) -> array(array(T))  -- Returns n-grams for the array:

        SELECT ngrams(ARRAY['foo', 'bar', 'baz', 'foo'], 2); -- [['foo', 'bar'], ['bar', 'baz'], ['baz', 'foo']]
        SELECT ngrams(ARRAY['foo', 'bar', 'baz', 'foo'], 3); -- [['foo', 'bar', 'baz'], ['bar', 'baz', 'foo']]
        SELECT ngrams(ARRAY['foo', 'bar', 'baz', 'foo'], 4); -- [['foo', 'bar', 'baz', 'foo']]
        SELECT ngrams(ARRAY['foo', 'bar', 'baz', 'foo'], 5); -- [['foo', 'bar', 'baz', 'foo']]
        SELECT ngrams(ARRAY[1, 2, 3, 4], 2); -- [[1, 2], [2, 3], [3, 4]]
  * repeat(element, count) → array                -- 将element重复count次返回数组
  * reverse(x) → array                            -- 数组反转
  * sequence(start, stop) -> array(bigint)        -- 从start到stop生成一个整数序列，如果开始数小于等于停止数 每次自增1，否则自增 -1
  * sequence(start, stop, step) -> array(bigint)  -- 同上，根据指定步进值自增
  * sequence(start, stop) -> array(date)          -- 生成start日期到stop日期的日期序列，如果start日期小于或等于stop日期，则按1天递增，否则按-1天递增
  * sequence(start, stop, step) -> array(date)    -- 生成日期序列从start到stop，通过step递增。类型step可以是INTERVAL DAY TO SECOND或者INTERVAL YEAR TO MONTH
  * sequence(start, stop, step) -> array(timestamp) -- 生成时间戳序列，start到stop递增step。类型step可以是INTERVAL DAY TO SECOND或INTERVAL YEAR TO MONTH
  * shuffle(x) → array                              -- 打乱数组元素
  * slice(x, start, length) → array                 -- 数组切片，和python[::]类似，如果start为负数，则从后面开始切
  * transform(array(T), function(T, U)) -> array(U) -- 返回一个数组，该数组是应用function到每个元素的结果：

        SELECT transform(ARRAY [], x -> x + 1); -- []
        SELECT transform(ARRAY [5, 6], x -> x + 1); -- [6, 7]
        SELECT transform(ARRAY [5, NULL, 6], x -> COALESCE(x, 0) + 1); -- [6, 1, 7]
        SELECT transform(ARRAY ['x', 'abc', 'z'], x -> x || '0'); -- ['x0', 'abc0', 'z0']
        SELECT transform(ARRAY [ARRAY [1, NULL, 2], ARRAY[3, NULL]], a -> filter(a, x -> x IS NOT NULL)); -- [[1, 2], [3]]

### Map函数和运算符

* 下标运算符: []
* Map函数
  * cardinality(x) → bigint               -- 返回map的基数大小
  * element_at(map(K, V), key) → V        -- 返回map中key对应的value，没有返回null
  * map() → map<unknown, unknown>         -- 返回一个空的map
  * map(array(K), array(V)) -> map(K, V)  -- 返回一个由指定的键/值数组构成的map
  * 
  * map_from_entries(array(row(K, V))) -> map(K, V)              -- key不能有重复的
  * multimap_from_entries(array(row(K, V))) -> map(K, array(V))  -- key可以有重复的
  * map_entries(map(K, V)) -> array(row(K, V))                   -- 以数组形式返回map中的所有实体
  * map_concat(map1(K, V), map2(K, V), ..., mapN(K, V)) -> map(K, V) -- 将map1，map2...mapN做并集，同一个key的value为在最后一个concat种的map的value
  * map_filter(map(K, V), function(K, V, boolean)) -> map(K, V)  -- 过滤map的所有键值对进行function计算结果为false的数据，true的键值对保留

        SELECT map_zip_with(MAP(ARRAY[1, 2, 3], ARRAY['a', 'b', 'c']), -- {1 -> ad, 2 -> be, 3 -> cf}
                    MAP(ARRAY[1, 2, 3], ARRAY['d', 'e', 'f']),
                    (k, v1, v2) -> concat(v1, v2));
        SELECT map_zip_with(MAP(ARRAY['k1', 'k2'], ARRAY[1, 2]), -- {k1 -> ROW(1, null), k2 -> ROW(2, 4), k3 -> ROW(null, 9)}
                            MAP(ARRAY['k2', 'k3'], ARRAY[4, 9]),
                            (k, v1, v2) -> (v1, v2));
        SELECT map_zip_with(MAP(ARRAY['a', 'b', 'c'], ARRAY[1, 8, 27]), -- {a -> a1, b -> b4, c -> c9}
                            MAP(ARRAY['a', 'b', 'c'], ARRAY[1, 2, 3]),
                            (k, v1, v2) -> k || CAST(v1/v2 AS VARCHAR));
  * map_keys(x(K, V)) -> array(K)                                   -- 返回map的全部键
  * map_values(x(K, V)) -> array(V)                                 -- 返回map的全部值
  * transform_keys(map(K1, V), function(K1, V, K2)) -> map(K2, V)   -- 对map的每一个键值对进行function运算之后生成新的k，value不变
       
       SELECT transform_keys(MAP(ARRAY[], ARRAY[]), (k, v) -> k + 1); -- {}
       SELECT transform_keys(MAP(ARRAY [1, 2, 3], ARRAY ['a', 'b', 'c']), (k, v) -> k + 1); -- {2 -> a, 3 -> b, 4 -> c}
       SELECT transform_keys(MAP(ARRAY ['a', 'b', 'c'], ARRAY [1, 2, 3]), (k, v) -> v * v); -- {1 -> 1, 4 -> 2, 9 -> 3}
       SELECT transform_keys(MAP(ARRAY ['a', 'b'], ARRAY [1, 2]), (k, v) -> k || CAST(v as VARCHAR)); -- {a1 -> 1, b2 -> 2}
       SELECT transform_keys(MAP(ARRAY [1, 2], ARRAY [1.0, 1.4]), -- {one -> 1.0, two -> 1.4}
                             (k, v) -> MAP(ARRAY[1, 2], ARRAY['one', 'two'])[k]);
  * transform_values(map(K, V1), function(K, V1, V2)) -> map(K, V2)  -- 对map的每一个键值对进行function运算之后生成新的value，key不变

       SELECT transform_values(MAP(ARRAY[], ARRAY[]), (k, v) -> v + 1); -- {}
       SELECT transform_values(MAP(ARRAY [1, 2, 3], ARRAY [10, 20, 30]), (k, v) -> v + k); -- {1 -> 11, 2 -> 22, 3 -> 33}
       SELECT transform_values(MAP(ARRAY [1, 2, 3], ARRAY ['a', 'b', 'c']), (k, v) -> k * k); -- {1 -> 1, 2 -> 4, 3 -> 9}
       SELECT transform_values(MAP(ARRAY ['a', 'b'], ARRAY [1, 2]), (k, v) -> k || CAST(v as VARCHAR)); -- {a -> a1, b -> b2}
       SELECT transform_values(MAP(ARRAY [1, 2], ARRAY [1.0, 1.4]), -- {1 -> one_1.0, 2 -> two_1.4}
                               (k, v) -> MAP(ARRAY[1, 2], ARRAY['one', 'two'])[k] || '_' || CAST(v AS VARCHAR));


## SQL语法声明

### schema

    create schema is not exists hive.gsq_test;  

    alter schema gsq_test rename to guosq_test;  

    drop schema is exists gsq_test;

### table

    CREATE TABLE IF NOT EXISTS orders (
      orderkey bigint,
      orderstatus varchar,
      totalprice double COMMENT 'Price in cents.',
      orderdate date
    )
    COMMENT 'A table to keep track of orders.'  

    CREATE TABLE bigger_orders (
      another_orderkey bigint,
      LIKE orders,
      another_orderdate date
    )  

### analyze

    analyze bigger_orders;  

    analyze dw.hrms_employee_cost_month with(partitions = array[array['2019-07-18'],array['2019-07-22']]);
     
    prepare m1 from select * from guosq_test.orders;  

    execute m1;  

    prepare m2 from select * from dw.hrms_employee_zipper where start_date <= ? and end_date > ? and employee_id = ?  

    execute m2 using '2019-05-01','2019-05-01',161333  

### insert

    INSERT INTO orders
    SELECT * FROM new_orders;  

    INSERT INTO cities VALUES (1, 'San Francisco');  

    INSERT INTO cities VALUES (2, 'San Jose'), (3, 'Oakland');  

    INSERT INTO nation (nationkey, name, regionkey, comment)
    VALUES (26, 'POLAND', 3, 'no comment');

### values 

    VALUES
    (1, 'a'),
    (2, 'b'),
    (3, 'c')  

    SELECT * FROM (
        VALUES
            (1, 'a'),
            (2, 'b'),
            (3, 'c')
    ) AS t (id, name)  

    CREATE TABLE example AS
    SELECT * FROM (
        VALUES
            (1, 'a'),
            (2, 'b'),
            (3, 'c')
    ) AS t (id, name)

### group by 

    SELECT * FROM shipping;  

     origin_state | origin_zip | destination_state | destination_zip | package_weight
    --------------+------------+-------------------+-----------------+----------------
     California   |      94131 | New Jersey        |            8648 |             13
     California   |      94131 | New Jersey        |            8540 |             42
     New Jersey   |       7081 | Connecticut       |            6708 |            225
     California   |      90210 | Connecticut       |            6927 |           1337
     California   |      94131 | Colorado          |           80302 |              5
     New York     |      10002 | New Jersey        |            8540 |              3
    (6 rows)
    
    SELECT origin_state, origin_zip, destination_state, sum(package_weight)
    FROM shipping
    GROUP BY GROUPING SETS (
        (origin_state),
        (origin_state, origin_zip),
        (destination_state));
    等价于
    SELECT origin_state, NULL, NULL, sum(package_weight)
    FROM shipping GROUP BY origin_state      

    UNION ALL      

    SELECT origin_state, origin_zip, NULL, sum(package_weight)
    FROM shipping GROUP BY origin_state, origin_zip      

    UNION ALL      

    SELECT NULL, NULL, destination_state, sum(package_weight)
    FROM shipping GROUP BY destination_state;
    结果为
     origin_state | origin_zip | destination_state | _col0
    --------------+------------+-------------------+-------
     New Jersey   | NULL       | NULL              |   225
     California   | NULL       | NULL              |  1397
     New York     | NULL       | NULL              |     3
     California   |      90210 | NULL              |  1337
     California   |      94131 | NULL              |    60
     New Jersey   |       7081 | NULL              |   225
     New York     |      10002 | NULL              |     3
     NULL         | NULL       | Colorado          |     5
     NULL         | NULL       | New Jersey        |    58
     NULL         | NULL       | Connecticut       |  1562
    (10 rows)  

    SELECT origin_state, destination_state, sum(package_weight)
    FROM shipping
    GROUP BY GROUPING SETS (
        (origin_state, destination_state),
        (origin_state),
        (destination_state),
        ());
    等价于
    SELECT origin_state, destination_state, sum(package_weight)
    FROM shipping
    GROUP BY CUBE (origin_state, destination_state);
    结果为
     origin_state | destination_state | _col0
    --------------+-------------------+-------
     California   | New Jersey        |    55
     California   | Colorado          |     5
     New York     | New Jersey        |     3
     New Jersey   | Connecticut       |   225
     California   | Connecticut       |  1337
     California   | NULL              |  1397
     New York     | NULL              |     3
     New Jersey   | NULL              |   225
     NULL         | New Jersey        |    58
     NULL         | Connecticut       |  1562
     NULL         | Colorado          |     5
     NULL         | NULL              |  1625
    (12 rows)  

    SELECT origin_state, origin_zip, sum(package_weight)
    FROM shipping
    GROUP BY ROLLUP (origin_state, origin_zip);
    等价于
    SELECT origin_state, origin_zip, sum(package_weight)
    FROM shipping
    GROUP BY GROUPING SETS ((origin_state, origin_zip), (origin_state), ());
    结果为
     origin_state | origin_zip | _col2
    --------------+------------+-------
     California   |      94131 |    60
     California   |      90210 |  1337
     New Jersey   |       7081 |   225
     New York     |      10002 |     3
     California   | NULL       |  1397
     New York     | NULL       |     3
     New Jersey   | NULL       |   225
     NULL         | NULL       |  1625
    (8 rows)

### UNNEST

    SELECT numbers, animals, n, a
    FROM (
      VALUES
        (ARRAY[2, 5], ARRAY['dog', 'cat', 'bird']),
        (ARRAY[7, 8, 9], ARRAY['cow', 'pig'])
    ) AS x (numbers, animals)
    CROSS JOIN UNNEST(numbers, animals) AS t (n, a);  
    SELECT numbers, n, a
    FROM (
      VALUES
        (ARRAY[2, 5]),
        (ARRAY[7, 8, 9])
    ) AS x (numbers)
    CROSS JOIN UNNEST(numbers) WITH ORDINALITY AS t (n, a)  
    SELECT numbers, n
    FROM (
      VALUES
        (ARRAY[2, 5]),
        (ARRAY[7, 8, 9])
    ) AS x (numbers)
    CROSS JOIN UNNEST(numbers) AS t(n)
    
### using

    SELECT *
    FROM table_1
    JOIN table_2
    ON table_1.key_A = table_2.key_A AND table_1.key_B = table_2.key_B     
    等价于
    SELECT *
    FROM table_1
    JOIN table_2
    USING (key_A, key_B)
    
### show    
    
    show catalogs; -- 查看Presto连接的所有数据源
    show schemas from hive; -- 列出catalog_name下的所有schema
    show tables from hive.guosq_test; -- 查看'catalog_name.schema_name'下的所有表   
    show columns from guosq_test.orders; -- 查看'guosq_test.orders'下的所有列
    show create table guosq_test.orders
    show create view view_name;
    show functions;
    show grants;
    show grants on table guosq_test.orders;
    show roles;
    show current roles;
    show session;
    show stats for guosq_test.orders;