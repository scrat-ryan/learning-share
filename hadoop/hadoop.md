# [hadoop](http://hadoop.apache.org)

## 简介

## MapReduce

* MapReduce任务过程分为两个处理阶段：map阶段和reduce阶段。每阶段都以键-值对作为输入和输出，其类型由程序员来选择。
* map函数的输出经由MapReduce框架处理后，最后发送到reduce函数。这个处理过程基于键来对键-值对进行排序和分组【shuffle】。
* job->task->map & reduce 
* Hadoop将MapReduce的输入数据划分成等长的小数据块，称为输入分片(input split)或简称“分片”。Hadoop为每个分片构建一个map任务，并由该任务来运行用户自定义的map函数从而处理分片中的每条记录。分片不能太大也不能太小。管理分片的总时间和构建map任务的总时间将决定作业的整个执行时间。对于大多数作业来说，一个合理的分片大小趋向于HDFS的一个块的大小，默认是128MB。
* Hadoop在存储有输入数据(HDFS中的数据)的节点上运行map任务，可以获得最佳性能，因为它无需使用宝贵的集群带宽资源。这就是所谓的“数据本地化优化”(data locality optimization)。
* map任务将其输出写入本地硬盘，而非HDFS。【因为map的输出是中间结果：该中间结果由reduce任务处理后才产生最终输出结果，而且一旦作业完成，map的输出结果就可以删除。因此，如果把它存储在HDFS中并实现备份，难免有些小题大做。如果运行map任务的节点在将map中间结果传送给reduce任务之前失败，Hadoop将在另一个节点上重新运行这个map任务以再次构建map中间结果】
* reduce的输出通常存储在HDFS中以实现可靠存储。【对于reduce输出的每个HDFS块，第一个副本存储在本地节点上，其他副本出于可靠性考虑存储在其他几家的节点中】
* reduce任务的数量并非由输入数据的大小决定，相反是独立制定的。
* 如果有到多个任务，每个任务就会针对输出进行分区(partition)，即为每个reduce建一个分区。每个分区有有许多键及对应的值，但每个键对应的键-值对记录都在同一分区中。分区可由用户定义的分区函数控制，但通常情况默认的partitioner通过哈希函数来分区，很高效。
* 有reduce任务就存在shuffle【map和redeuce中间的数据流】，没有reduce的时候，唯一的非本地节点数据传输是map任务将结果写入HDFS。
![avatar](../pic/一个reduce任务的MapReduce数据流.png)
![avatar](../pic/多个reduce任务的数据流.png)
![avatar](../pic/无reduce任务的MapReduce数据流.png)
* combiner函数能帮助减少mapper和reducer之间的数据传输量【集群上的可用带宽限制了MapReduce作业的数量，因此尽量避免map和reduce人物之间的数据传输是有利的】，但是combiner函数不能取代reduce函数，因为我们仍然需要reduce函数来处理不通map输出中具有相同键的记录。


## Hadoop分布式文件系统

* 分布式文件系统：管理网络中跨多台计算机存储的文件系统。
* HDFS，简称DFS，以流式数据访问模式来存储超大文件，运行于商用硬件集群上。

    1. 超大文件
    2. 流式数据访问--一次写入，多次读取是最高效的使用方式。数据机通常由数据源生成或从数据源复制而来，接着长时间在此数据集上进行各种分析。每次分析都将设计该数据集的大部分数据甚至全部，因此读取整个数据集的时间延迟比读取第一条记录的时间延迟更重要。
    3. 商用硬件--Hadoop 并不需要运行在昂贵且高可靠的硬件上，它是设计运行在商用硬件的集群上的。
    4. 低时间延迟的数据访问--HDFS是为高数据吞吐量应用优化的，要求低时间延迟数据访问的应用不适合在HDFS上运行。
    5. 大量的小文件--由于namenode将文件系统的元数据存储在内存中，因此该文件系统所能存储的文件总数受限于namenode的内存容量.根据经验，每个文件、目录和数据块的存储信息大约占150字节。
    6. 多用户写入，任意修改文件--HDFS中的文件写入只支持单个写入者，而且写操作总是以“只添加”方式在文件末尾写数据。不支持多个写入者的操作，也不支持在文件的任意位置进行修改。

* HDFS中的块(block)，默认为128MB。HDFS上的文件被划分为块大小的多个分块(chunk)，作为独立的存储单元。HDFS中小于一个块大小的文件不会占据整个块的空间。
* HDFS的块比磁盘的块大，其目的是为了最小化寻址开销。如果块足够大，从磁盘传输数据的时间会明显大于定位这个块开始位置所需的时间。因而，传输一个由多个块组成的大文件的时间取决于磁盘传输速率。
* MapReduce中的map任务通常一次只处理一个块中的数据
* 对分布式文件系统中的块进行抽象的好处

    1. 一个文件的大小可以大于网络中任意一个磁盘的容量。
    2. 使用抽象块而非整个文件作为存储单元，大大简化了存储子系统的设计。
    3. 非常适合用于数据备份进而提供数据容错能力和提高可用性。

* HDFS集群有两类节点以管理节点-工作节点模式运行，及一个namenode(管理节点)和多个datanode(工作节点)。
* namenode管理文件系统的命名空间，它维护着文件系统书及整棵树内所有的文件和目录。这些信息以两个文件形式永久保存在本地磁盘上：命名空间镜像文件和编辑日志文件。namenode也记录着每个文件中各个块所在的数据节点信息，但它并不永久保存块的位置信息，因为这些信息会在系统启动时根据节点信息重建。
* datanode是文件系统的工作节点。它们根据需要存储并检索数据块(受客户端或namenode调度),并且定期向namenode发送它们所存储的块的列表。 
* Hadoop为namenode的容错提供了两种机制

    1. 备份那些组成文件系统元数据持久状态的文件，Hadoop可以通过配置使namenode在多个文件系统上保存元数据的持久状态。这些写操作是实时同步的，且是原子操作。一版的配置使，将持久状态写入本地磁盘的同时，写入一个远程挂在的网络文件系统(NFS)。
    2. 运行一个辅助namenode，但它不能被用作namenode。这个辅助namenode的重要作用是定期合并编辑日志与命名空间镜像，以防止编辑日志过大。这个辅助namenode一般在另一台单独的物理计算机上运行，因为它需要占用大量CPU时间，并且需要与namenode一样多的内存来执行合并操作。它会保存合并后的命名空间镜像的副本，并在namenode发生故障时启用，但是，辅助namenode保存的状态总是滞后于主节点所以在主节点全部失效时，难免会丢失部分数据。在这种情况下一般把存储在NFS上的namenode元数据复制到辅助namenode并作为新的主namenode运行。

* 块缓存--通常datanode从磁盘中读取块，但对于访问频繁的文件，其对应的块可能被显式地缓存在datanode的内存中，以堆外块缓存(off-heap block cache)的形式存在。默认情况下，一个块仅缓存在一个datanode的内存中，当然可以针对每个文件配置datanode的数量。作业调度器通过在缓存块的datanode上运行任务，可以利用块缓存的优势提高读操作的性能。eg:连接(join)操作中使用的一个小的查询表就是块缓存的一个很好的候选。
* 用户或应用通过在缓存池(cache pool)中增加一个cache directive来告诉namenode需要缓存哪些文件及缓存多久。缓存池是一个用于管理缓存权限和资源使用的管理性分组。
* namenode 在内存中保存文件系统中每个文件和每个数据块的引用关系，这意味着对于一个拥有大量文件的超大集群来说，内存将成为限制系统横向扩展的瓶颈。
* 联邦HDFS--联邦HDFS允许系统通过添加namenode实现扩展，其中每个namenode管理文件系统命名空间的一部分【/user,/share,...】。在联邦环境下，每个namenode维护一个命名空间卷(namespace volume)，由命名空间的元数据和一个数据块池(block pool)组成，数据块池包含该命名空间下文件的所有数据块。命名空间卷之间是相互独立的，两两之间并不相互通信，甚至其中一个namenode的实效也不会影响由其他namenode维护的命名空间的可用性。数据块池不再进行切分，因此集群中的datanode需要注册到每个namenode，并且存储着来自多个数据块池中的数据块。
* Hadoop2配置了一堆活动-备用(active-standby)namenode来支持HDFS的高可用性(HA)。
* 两种高可用性共享存储方案：NFS过滤器或群体日志管理器(QJM, Quorum Journal Manager)。QJM是一个专用的HDFS实现，为提供一个高可用的编辑日志而设计，被推荐用于大多数HDFS部署中。
* 系统中有一个称为故障转移控制器(failover controller)的新实体，管理者将活动namenode转换为备用namenode的转换过程。有多种故障转移控制器，但默认的一种是使用了ZooKeeper来确保有且仅有一个活动namenode。每一个namenode运行着一个轻量级的故障转移控制器，其工作就是监视诉诸namenode是否失效(通过一个简单的心跳机制实现)并在namenode失效时进行故障切换。
* fs.defaultFS(core-site.xml)，用于设置Hadoop的默认文件系统，eg：hdfs://localhost/  填写uri时可省略
* dfs.replication(hdfs-site.xml)，用于设置HDFS文件系统块的副本数量。

        hadoop fs -ls hdfs://mycluster/user/hive/warehouse/guosq_test.db
        hadoop fs -mkdir /user/guosq  等价于  hadoop fs -mkdir hdfs://mycluster/user/guosq
        hadoop fs -ls /user  等价于  hadoop fs -ls hdfs://mycluster/user
        hadoop fs -copyFromLocal /home/admin/guosq/start-spark-sql.sh hdfs://mycluster/user/guosq/start-spark-sql.sh  等价于  hadoop fs -copyFromLocal /home/admin/guosq/start-spark-sql.sh /user/guosq/start-spark-sql.sh 
        hadoop fs -copyFromLocal /home/admin/guosq/start-spark-sql.sh start-spark-sql.sh  使用相对路径复制到HDFS的home目录中，本例中为/user/admin
        hadoop fs -copyToLocal start-spark-sql.sh /home/admin/guosq/start-spark-sql.copy.sh

* 以下场景，可用带宽依次递减：

    * 同一节点上的进程
    * 同一机架上的不同节点
    * 同一数据中心中不同机架上的节点
    * 不同数据中心中的节点

* Distcp 可以替代hadoop fs -cp

        hadoop distcp file1 file2
        hadoop distcp dir1 dir2
        hadoop distcp -update dir1 dir2
        hadoop distcp -overwrite file1 file2
        hadoop distcp -update -delete -p hdfs://namenode1/foo hdfs://namenode2/foo   -delete选项使得distcp可以删除目标路径中任意没在源路径中出现的文件或目录，-p选项意味着文件状态如权限、块大小和副本数被保留
        hadoop distcp  webhdfs://namenode1:50070/foo webhdfs://namenode2:50070/foo

## YARN(Yet Another Resource Negotiator)

![avatar](../pic/YARN应用.png)
![avatar](../pic/YARN应用的运行机制.png)

* 资源管理器(resoure manager)：管理集群资源使用
* 节点管理器(node manager)：运行在所有节点上，能够启动和监控容器(container)
* YARN本身不会为应用的各部分(客户端、master和进程)彼此间通信提供任何手段。大多数重要的YARN应用使用某种形式的远程通信机制(例如Hadoop的RPC层)来向客户端传递状态更新和返回结果，但是这些通信机制都是专属于各应用的。
* YARN有一个灵活的资源请求模型。档请求多个容器时，可以指定每个容器需要的计算机资源数量(内存和CPU)，还可以指定对容器的本地限制要求。
* 有时本地限制无法被满足，这种情况下要么不分配资源，或者可选择放松限制。
* 通常情况下，档启动一个容器用于处理HDFS数据块(为了在MapReduce中运行一个map任务)时，应用将会向这样的节点申请容器：存储该数据块三个副本的节点，或是存储这些副本的机架中的一个节点。如果都申请失败，则申请集群中的任意节点。
* YARN应用可以在运行中的任意时刻提出资源申请。eg：可以在最开始提出所有的请求，或者为了满足不断变化的应用需要，采取更为动态的方式在需要更多资源时提出请求。Spark是采用固定的方式，MapReduce则分两步，在最开始时申请map任务容器，reduce任务容器的启用则放在后期。同样，如果任何任务出现失败，将会另外申请容器以重新运行失败的任务。
* YARN生命周期的三种模型

    1. 一个用户作业对应一个应用---MapReduce
    2. 作业的每个工作流或每个用户对话(可能并无关联性)对应一个应用。这种方法要比第一种情况效率更高，因为容器可以在作业之间崇勇，并且有可能缓存作业之间的中间数据。--Spark
    3. 多个用户共享一个长期运行的应用。这种应用通常是作为一种协调者的角色在运行。--Impala(Impala使用这种模型提供了一个代理应用，Impala守护进程通过该代理请求集群资源。由于避免了启动新application master带来的开销，一个总是开启(always on)的application master意味着用户将获得非常低延迟的查询响应)
    
* YARN的很多设计是为了解决MapReduce1的局限性。使用YARN的好处包括一下几个方面
    
    1. 可扩展性(Scalability)
    2. 可用性(Availability)
    3. 利用率(Utilization)
    4. 多租户(Multitenancy)
    
* YARN的三种调度器
    
    1. FIFO调度器(FIFO Scheduler)--先进先出，简单易懂，不需要任何配置，但是不适合共享集群
    2. 容量调度器(Capacity Scheduler)--一个独立的专门队列保证小作业一提交就可以启动
    3. 公平调度器(Fair Scheduler)--不需要预留一定量的资源，调度器会在所有运行的作业之间动态平衡资源
    
* 容量调度器允许多个组织共享一个Hadoop集群，每个组织可以分配到全部集群资源的一部分。每个组织被配置一个专门的队列，每个队列被配置为可以使用一定的集群资源。队列可以进一步按层次划分，这样每个组织内的不同用户能够共享该组织队列所分配的资源。在一个队列内，使用FIFO调度策略对应用进行调度。
* 单个作业使用的资源不会超过其队列容量。然而，如果队列中有多个作业，并且资源不够用的情况下，这时如果集群仍有可用的空闲资源，那么容量调度器可能会将空余的资源分配给队列中的作业，哪怕这会超出队列容量。这成为“弹性队列”(queue elasticity)。
* 延迟调度(delay scheduling)-- 如果等待一小段时间(不超过几秒)，能够戏剧性的增加在锁清秋的节点上分配到一个容器的机会，从而可以提高集群的效率
* 主导资源公平性(Dominant Resource Fairness, DRF)--YARN观察每个用户的主导资源，并将其作为对集群资源使用的一个度量。

## Hadoop的I/O操作
































