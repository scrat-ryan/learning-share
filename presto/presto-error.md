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

## 各个队列的平均查询时长，查询次数，
    with v_ms as (
      select
          state
        , array_join(resource_group_id,'.') as resource_group_id
      from system.runtime.queries
      where started >= current_date
    )
    select
        resource_group_id
      , state
      , count(1) as queries
    from v_ms
    group by resource_group_id, state
    order by resource_group_id, state

## 获取连续数据

    select
        date_format(itv_month + interval '1' month - interval '1' day, '%Y-%m-%d') as itv_month
    from dw.dual
    cross join unnest(sequence(date_parse('2017-05-01', '%Y-%m-%d'), date_parse('2017-08-26', '%Y-%m-%d'), interval '1' month)) as t (itv_month)

    ----------------------------------- hive -------------------------------------------

    with v_tmp1 as (

      select
          itv_month
        , split(space(itv_month),' ') as arr
        -- , split(repeat(',', itv_month),',') as arr
        from (select
                  cast(floor(months_between('2019-08-26', '2017-05-01')) as integer) as itv_month
              from dw.dual) v    

    )    

    , v_month_tmp as (    

      select
          case when date_format(date_add(add_months('2017-05-01', i + 1), -1), 'yyyy-MM') = date_format('2019-08-28', 'yyyy-MM') then '2019-08-28' else date_add(add_months('2017-05-01', i + 1), -1) end as etl_month
      from v_tmp1
      lateral view posexplode(arr) tf as i,j    
    
    )    
    
    select * from v_month_tmp
    ;

## cube

    with v_tmp1 as (
    SELECT
      deptno,
      job,
      sum(sal),
      grouping(deptno) as deptno_flag,
      grouping(job) as job_flag
    from dmw_test.emp
    group by cube(deptno, job)
    )    

    select
      t.*,
      case
        when deptno_flag = 0 and job_flag = 0 then 'group by deptno, job'
        when deptno_flag = 0 and job_flag = 1 then 'group by deptno'
        when deptno_flag = 1 and job_flag = 0 then 'group by job'
        else '全局group by'
      end as group_path
    from v_tmp1 t