# [hadoop](http://hadoop.apache.org)

## 简介

## MapReduce

* MapReduce任务过程分为两个处理阶段：map阶段和reduce阶段。每阶段都以键-值对作为输入和输出，其类型由程序员来选择。
* map函数的输出经由MapReduce框架处理后，最后发送到reduce函数。这个处理过程基于键来对键-值对进行排序和分组【shuffle】。
* job->task->map & reduce 
* Hadoop将MapReduce的输入数据划分成等长的小数据块，称为输入分片（input split）或简称“分片”。Hadoop为每个分片构建一个map任务，并由该任务来运行用户自定义的map函数从而处理分片中的每条记录。分片不能太大也不能太小。管理分片的总时间和构建map任务的总时间将决定作业的整个执行时间。对于大多数作业来说，一个合理的分片大小趋向于HDFS的一个块的大小，默认是128MB。
* Hadoop在存储有输入数据（HDFS中的数据）的节点上运行map任务，可以获得最佳性能，因为它无需使用宝贵的集群带宽资源。这就是所谓的“数据本地化优化”（data locality optimization）。
* map任务将其输出写入本地硬盘，而非HDFS。【因为map的输出是中间结果：该中间结果由reduce任务处理后才产生最终输出结果，而且一旦作业完成，map的输出结果就可以删除。因此，如果把它存储在HDFS中并实现备份，难免有些小题大做。如果运行map任务的节点在将map中间结果传送给reduce任务之前失败，Hadoop将在另一个节点上重新运行这个map任务以再次构建map中间结果】
* reduce的输出通常存储在HDFS中以实现可靠存储。【对于reduce输出的每个HDFS块，第一个副本存储在本地节点上，其他副本出于可靠性考虑存储在其他几家的节点中】
* reduce任务的数量并非由输入数据的大小决定，相反是独立制定的。
* 如果有到多个任务，每个任务就会针对输出进行分区（partition），即为每个reduce建一个分区。每个分区有有许多键及对应的值，但每个键对应的键-值对记录都在同一分区中。分区可由用户定义的分区函数控制，但通常情况默认的partitioner通过哈希函数来分区，很高效。
* 有reduce任务就存在shuffle【map和redeuce中间的数据流】，没有reduce的时候，唯一的非本地节点数据传输是map任务将结果写入HDFS。
![avatar](../pic/一个reduce任务的MapReduce数据流.png)
![avatar](../pic/多个reduce任务的数据流.png)
![avatar](../pic/无reduce任务的MapReduce数据流.png)
* combiner函数能帮助减少mapper和reducer之间的数据传输量【集群上的可用带宽限制了MapReduce作业的数量，因此尽量避免map和reduce人物之间的数据传输是有利的】，但是combiner函数不能取代reduce函数，因为我们仍然需要reduce函数来处理不通map输出中具有相同键的记录。


## Hadoop分布式文件系统

## YARN

* 资源管理器[resoure manager]：管理集群资源使用
* 节点管理器[node manager]：运行在所有节点上，能够启动和监控容器

