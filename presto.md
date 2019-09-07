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
  * strpos(string, substring, instance) → bigint 
  * strrpos(string, substring) → bigint            -- 返回字符串中最后一次出现substring的位置。从1开始，如果未找到，返回0。
  * strrpos(string, substring, instance) → bigint 
  * position(substring IN string) → bigint         -- 返回substring首次出现在string中的位置,没有返回0`SELECT position('11122' in 'fsd11122ghjnk')`
  * substr(string, start) → varchar                -- 从start位置 开始 截取字符串【起始为1】
  * substr(string, start, length) → varchar        -- 从start位置 开始 截取字符串,截取的长度为length。
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

  * 