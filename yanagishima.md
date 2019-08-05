# [yanagishima](https://github.com/yanagishima/yanagishima)

## require

* Java 8
* Node.js

## quick start

    [admin@UAT-HADOOP-15 guosq]$ git clone https://github.com/yanagishima/yanagishima.git
    [admin@UAT-HADOOP-15 guosq]$ cd yanagishima
    [admin@UAT-HADOOP-15 yanagishima]$ git checkout -b 17.0 refs/tags/17.0
    [admin@UAT-HADOOP-15 yanagishima]$ ./gradlew distZip
    [admin@UAT-HADOOP-15 yanagishima]$ cd build/distributions
    [admin@UAT-HADOOP-15 distributions]$ unzip yanagishima-17.0.zip
    [admin@UAT-HADOOP-15 distributions]$ cd yanagishima-17.0
    [admin@UAT-HADOOP-15 yanagishima-17.0]$ vim conf/yanagishima.properties
    # yanagishima web port
    jetty.port=9876
    # 30 minutes. If presto query exceeds this time, yanagishima cancel the query.
    presto.query.max-run-time-seconds=1800
    # 1GB. If presto query result file size exceeds this value, yanagishima cancel the query.
    presto.max-result-file-byte-size=1073741824
    # you can specify freely. But you need to specify same name to presto.coordinator.server.[...] and presto.redirect.server.[...] and catalog.[...] and schema.[...]
    presto.datasources=presto-uat
    # presto coordinator url
    presto.coordinator.server.presto-uat=http://10.121.18.15:9000
    # almost same as presto coordinator url. If you use reverse proxy, specify it
    presto.redirect.server.presto-uat=http://10.121.18.15:9000
    # presto catalog name
    catalog.presto-uat=hive
    # presto schema name
    schema.presto-uat=default                                        
                                                
    # if query result exceeds this limit, to show rest of result is skipped
    select.limit=500
    # http header name for audit log
    audit.http.header.name=some.auth.header
    # limit to convert from tsv to values query
    to.values.query.limit=500
    # authorization feature
    check.datasource=false
    hive.jdbc.url.your-hive=jdbc:hive2://localhost:10000/default;auth=noSasl
    hive.jdbc.user.your-hive=yanagishima-hive
    hive.jdbc.password.your-hive=yanagishima-hive
    hive.query.max-run-time-seconds=3600
    hive.query.max-run-time-seconds.your-hive=3600
    resource.manager.url.your-hive=http://localhost:8088
    sql.query.engines=presto
    hive.datasources=your-hive
    hive.disallowed.keywords.your-hive=insert,drop
    # 1GB. If hive query result file size exceeds this value, yanagishima cancel the query.
    hive.max-result-file-byte-size=1073741824
    # setup initial hive query(for example, set hive.mapred.mode=strict)
    hive.setup.query.path.your-hive=/usr/local/yanagishima/conf/hive_setup_query_your-hive
    # CORS setting
    cors.enabled=false
    [admin@UAT-HADOOP-15 yanagishima-17.0]$ nohup ./bin/yanagishima-start.sh >/app/module/guosq/yanagishima/log/yanagishima.log 2>&1 &

## 参考

* [https://github.com/yanagishima/yanagishima]