# Hadoop

针对 [Hadoop](http://hadoop.apache.org) 应用的 Docker 镜像，用于提供 Hadoop 服务。

详细信息可参照：[官方说明](http://hadoop.apache.org/docs/r1.0.4/cn/)

![hadoop-logo](img/hadoop-logo.jpg)

**版本信息**：

- 3.3、3.3.0、latest
- 3.2、3.2.1

**镜像信息**

* 镜像地址：colovu/hadoop:latest



## TL;DR

Docker-Compose 快速启动命令：

```shell
$ curl -sSL https://raw.githubusercontent.com/colovu/docker-hadoop/master/docker-compose.yml > docker-compose.yml

$ mkdir -p ./conf ./data
$ docker-compose up -d
```



---



## 默认对外声明

### 端口

- 9000：Namenode Web 端口
- 9870：Namenode 服务监听端口
- 9864：DataNode 服务监听端口
- 8088：ResourceManager Web 端口
- 8188：HistoryManager Web 端口

### 数据卷

镜像默认提供以下数据卷定义，默认数据分别存储在自动生成的应用名对应`Hadoop`子目录中：

```shell
/var/log			# Hadoop 日志文件
/srv/conf			# Hadoop 配置文件
/srv/data			# Hadoop 数据文件
```

如果需要持久化存储相应数据，需要**在宿主机建立本地目录**，并在使用镜像初始化容器时进行映射。宿主机相关的目录中如果不存在对应应用的子目录或相应数据文件，则容器会在初始化时创建相应目录及文件。



## 容器配置

Hadoop 应用的参数通过设置**环境变量**的方式设置。格式为 **`<PREFIX>_<PROPERTY>`**。使用不同的前缀设置不同的配置文件，**`PREFIX`**与配置文件对应关系如下：

- `CORE_CONF`: /srv/conf/hadoop/core-site.xml
- `HDFS_CONF`: /srv/conf/hadoop/hdfs-site.xml
- `YARN_CONF` : /srv/conf/hadoop/yarn-site.xml
- `HTTPFS_CONF` : /srv/conf/hadoop/httpfs-site.xml
- `KMS_CONF` : /srv/conf/hadoop/kms-site.xml
- `MAPRED_CONF` : /srv/conf/hadoop/mapred-site.xml

容器的环境变量可通过两种方式设置：

- 环境变量文件：将常规通用环境变量写入环境变量文件中，并在容器启动命令中指定相应环境变量文件；如使用文件`hadoop.env`
- 命令行参数：对于特定变量，直接在命令行中使用`-e`参数指定各个变量（不适合大量变量的设置）



**`PROPETY`**:

在设置环境变量时，对特殊字符需要进行转义；使用 `docker` 或 `docker-compose` 启动容器时，环境变量与设置的属性转义规则如下：

- `_` ==> `.` : 环境变量中的`下划线`会被转义为设置属性中的`半角点`
- `__` ==> `_` : 环境变量中的`双下划线`会被转义为设置属性中的`单下划线`
- `___` ==> `-` : 环境变量中的`三下划线`会被转义为设置属性中的`中划线`

例如如下的环境变量及对应设置的实际属性为：

- `CORE_CONF_fs_defaultFS=hdfs://namenode:8020` ：设置配置文件`core-site.xml`中`fs.defaultFS`属性，设置后类似如下：

  ```xml
  <property><name>fs.defaultFS</name><value>hdfs://namenode:8020</value></property>
  ```

- `YARN_CONF_yarn_log___aggregation___enable=true` ：设置配置文件`yarn-site.xml`中`yarn.log-aggregation-enable`属性，设置后类似如下：

  ```xml
  <property><name>yarn.log-aggregation-enable</name><value>true</value></property>
  ```

  

### 预置的配置参数

以下配置参数，如果设置，将批量设置对应的配置属性：

#### `MULTIHOMED_NETWORK`

默认值：**1**。配置 Hadoop 集群在使用不同的网络时，可以正常访问；设置的配置文件及对应属性如下：

配置文件 `/srv/conf/hadoop/hdfs-site.xml`:

  * dfs.namenode.rpc-bind-host = 0.0.0.0
  * dfs.namenode.servicerpc-bind-host = 0.0.0.0
  * dfs.namenode.http-bind-host = 0.0.0.0
  * dfs.namenode.https-bind-host = 0.0.0.0
  * dfs.client.use.datanode.hostname = true
  * dfs.datanode.use.datanode.hostname = true

  配置文件 `/srv/conf/hadoop/yarn-site.xml`:

  * yarn.resourcemanager.bind-host = 0.0.0.0
  * yarn.nodemanager.bind-host = 0.0.0.0
  * yarn.nodemanager.bind-host = 0.0.0.0

  配置文件 `/srv/conf/hadoop/mapred-site.xml`:

  * yarn.nodemanager.bind-host = 0.0.0.0



#### `GANGLIA_HOST`

默认值：**无**。配置 Hadoop 将对应的度量数据发送至指定的 `ganglia gmond` 守护服务。



### 可选配置参数

如果没有必要，可选配置参数可以不用定义，直接使用对应的默认值，主要包括：

#### `ENV_DEBUG`

默认值：**false**。设置是否输出容器调试信息。可设置为：1、true、yes



## 安全

### 容器安全

本容器默认使用应用对应的运行时用户及用户组运行应用，以加强容器的安全性。在使用非`root`用户运行容器时，相关的资源访问会受限；应用仅能操作镜像创建时指定的路径及数据。使用`Non-root`方式的容器，更适合在生产环境中使用。



## 更新记录

- 3.3、latest
- 3.2



----

本文原始来源 [Endial Fang](https://github.com/colovu) @ [Github.com](https://github.com)
