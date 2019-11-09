sf = select * from
scf = select count(*) from
scf1 = select /*+ parallel(8) */ count(*) from
sjfb = select column_name, count(*) cnt from table_name group by column_name order by cnt desc;
sjfb1 = select /*+ parallel(8) */ column_name, count(*) cnt from table_name group by column_name order by cnt desc;
hive_sjfb = select column_name , isnull(column_name), count(*) cnt from table_name where dt='' group by column_name order by cnt desc limit 100;
hive_sjfb1 = select column_name , isnull(column_name), count(*) cnt from table_name where dt='' group by column_name distribute by column_name sort by cnt desc limit 100;
js = select count(distinct column_name) from table_name;
js1 = select /*+ parallel(8) */ count(distinct column_name) from table_name;
show_plan = select * from table(dbms
