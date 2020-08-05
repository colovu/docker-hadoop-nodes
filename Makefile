# Ver: 1.0 by Endial Fang (endial@126.com)
#
# 当前 Docker 镜像的编译脚本

current_branch := $(shell git rev-parse --abbrev-ref HEAD)

# Sources List: default / tencent / ustc / aliyun / huawei
build-arg := --build-arg apt_source=tencent

# 设置本地下载服务器路径，加速调试时的本地编译速度
local_ip=`ifconfig -a|grep inet|grep -v 127.0.0.1|grep -v inet6|awk '{print $$2}'|tr -d "addr:"`
build-arg += --build-arg local_url=http://$(local_ip)/dist-files/

current_branch := 3.3
build:
	docker rmi colovu/hadoop:$(current_branch) colovu/hadoop-namenode:$(current_branch) colovu/hadoop-datanode:$(current_branch) || true
	docker rmi colovu/hadoop-resourcemanager:$(current_branch) colovu/hadoop-nodemanager:$(current_branch) colovu/hadoop-historyserver:$(current_branch) || true
	docker build --force-rm $(build-arg) -t colovu/hadoop:$(current_branch) ./hadoop
	docker build --force-rm $(build-arg) -t colovu/hadoop-journalnode:$(current_branch) ./journalnode
	docker build --force-rm $(build-arg) -t colovu/hadoop-datanode:$(current_branch) ./datanode
	docker build --force-rm $(build-arg) -t colovu/hadoop-namenode:$(current_branch) ./namenode
	docker build --force-rm $(build-arg) -t colovu/hadoop-resourcemanager:$(current_branch) ./resourcemanager
	docker build --force-rm $(build-arg) -t colovu/hadoop-nodemanager:$(current_branch) ./nodemanager
	docker build --force-rm $(build-arg) -t colovu/hadoop-historyserver:$(current_branch) ./historyserver

DOCKER_NETWORK = back-tier
ENV_FILE = hadoop.env

wordcount:
	mkdir -p ./conf ./data
	cp ./README.md ./data/
	docker network create back-tier --driver bridge || true
	docker-compose up -d namenode
	docker-compose up -d datanode
	docker rmi hadoop-wordcount || true
	docker build -t hadoop-wordcount ./submit
	sleep 5
	docker run --network ${DOCKER_NETWORK} -v $(PWD)/conf:/srv/conf -v $(PWD)/data:/srv/data --env-file ${ENV_FILE} colovu/hadoop:$(current_branch) "hdfs dfs -mkdir -p /input/"
	docker run --network ${DOCKER_NETWORK} -v $(PWD)/conf:/srv/conf -v $(PWD)/data:/srv/data --env-file ${ENV_FILE} colovu/hadoop:$(current_branch) "hdfs dfs -copyFromLocal -f /usr/local/bin/appcommon.sh /input/"
	docker run --network ${DOCKER_NETWORK} -v $(PWD)/conf:/srv/conf -v $(PWD)/data:/srv/data --env-file ${ENV_FILE} hadoop-wordcount
	docker run --network ${DOCKER_NETWORK} -v $(PWD)/conf:/srv/conf -v $(PWD)/data:/srv/data --env-file ${ENV_FILE} colovu/hadoop:$(current_branch) "hdfs dfs -cat /output/*"
	docker run --network ${DOCKER_NETWORK} -v $(PWD)/conf:/srv/conf -v $(PWD)/data:/srv/data --env-file ${ENV_FILE} colovu/hadoop:$(current_branch) "hdfs dfs -rm -r /output"
	docker run --network ${DOCKER_NETWORK} -v $(PWD)/conf:/srv/conf -v $(PWD)/data:/srv/data --env-file ${ENV_FILE} colovu/hadoop:$(current_branch) "hdfs dfs -rm -r /input"
	docker-compose down
	rm -rf ./conf ./data

clean:
	docker rmi -f colovu/hadoop:$(current_branch) colovu/hadoop-namenode:$(current_branch) colovu/hadoop-datanode:$(current_branch) || true
	docker rmi -f colovu/hadoop-resourcemanager:$(current_branch) colovu/hadoop-nodemanager:$(current_branch) colovu/hadoop-journalnode:$(current_branch) colovu/hadoop-historyserver:$(current_branch) || true
	docker rmi -f hadoop-wordcount || true

# 以 /tmp/conf 及 /tmp/data 映射并启动集群后（至少 namenode 及 datanode）
# 
# docker run --network back-tier -v /tmp/conf:/srv/conf -v /tmp/data:/srv/data --env-file hadoop.env colovu/hadoop:3.2 hdfs dfs -mkdir -p /input/
# docker run --network back-tier -v /tmp/conf:/srv/conf -v /tmp/data:/srv/data --env-file hadoop.env colovu/hadoop:3.2 hdfs dfs -copyFromLocal -f /srv/data/hadoop/README.md /input/
# docker run --network back-tier -v /tmp/conf:/srv/conf -v /tmp/data:/srv/data --env-file hadoop.env colovu/hadoop:3.2 hadoop jar /usr/local/hadoop/share/hadoop/mapreduce/hadoop-mapreduce-examples-3.2.1.jar wordcount /input /output
# docker run --network back-tier -v /tmp/conf:/srv/conf -v /tmp/data:/srv/data --env-file hadoop.env colovu/hadoop:3.2 hdfs dfs -cat /output/*
# docker run --network back-tier -v /tmp/conf:/srv/conf -v /tmp/data:/srv/data --env-file hadoop.env colovu/hadoop:3.2 hdfs dfs -rm -r /output
# 
# docker run -it --network back-tier -v /tmp/conf:/srv/conf -v /tmp/data:/srv/data --env-file hadoop.env colovu/hadoop:3.2 /bin/bash
#   hdfs dfs -mkdir -p /input
#   hdfs dfs -copyFromLocal /srv/data/hadoop/README.md /input/
#   cd /usr/local/hadoop/share/hadoop/mapreduce
#   hadoop jar hadoop-mapreduce-examples-3.3.0.jar wordcount /input /output