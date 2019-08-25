# 报错及解决方案汇总

## Caused by: org.codehaus.janino.InternalCompilerException: Code of method "processNext()V" of class "org.apache.spark.sql.catalyst.expressions.GeneratedClass$GeneratedIterator" grows beyond 64 KB

   * reference:<https://stackoverflow.com/questions/50891509/apache-spark-codegen-stage-grows-beyond-64-kb/55208567#55208567> 
   * solution:`set spark.sql.codegen.wholeStage = false;`


