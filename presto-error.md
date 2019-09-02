# 报错及解决方案汇总

## Query failed (#20190730_075948_06314_759ps): line 13:24: '=' cannot be applied to varchar(1), integer

  * reason: 在presto中，'='两边的数据类型要严格一致，否则报错
  * solution: a.id = cast(b.id as varchar) -- 需要做显示的类型转换

## Query failed: / by zero

   * reason: 除数为0会报错
   * solution: `with v_data as (
                 select 10 as num1 , 0 as num2 from dw.dual
               )
               select try(num1/num2) from v_data;               
               或者是               
               with v_data as (
                 select 10 as num1 , 0 as num2 from dw.dual
               )
               select case when num2 = 0 then NULL else num1/num2 end from v_data;`

## Cannot cast 'dsfa' to BIGINT

   * reason: carchar转integer失败
   * solution: select try(cast('dsfa' as bigint));

## NVL函数不存在的错误

   * reason: presto种不存在nvl函数
   * solution: 使用coalesce或if替代(建议使用coalesce)

## Query failed (#20190902_092407_01703_7b29j) in presto-uat: Final aggregation with default value not separated from partial aggregation by remote hash exchange

  * reason: 这是由于做cube的语句group by cube(group_depart_id, sequence_category)中group_depart_id只有一个值导致的
  * solution: `grouping sets(
                               (group_depart_id, sequence_category)
                               , (sequence_category)
                               , (group_depart_id)
                               -- , ()
                             )`
