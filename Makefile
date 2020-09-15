# Ver: 1.4 by Endial Fang (endial@126.com)
#
# 当前 Docker 镜像的编译脚本

app_name :=colovu/hadoop

# 生成镜像TAG，类似：
# 	<镜像名>:<分支名>-<Git ID>		# Git 仓库且无文件修改直接编译 	
# 	<镜像名>:<分支名>-<年月日>-<时分秒>		# Git 仓库有文件修改后的编译
# 	<镜像名>:latest-<年月日>-<时分秒>		# 非 Git 仓库编译
current_subversion:=$(shell if [ ! `git status >/dev/null 2>&1` ]; then git rev-parse --short HEAD; else date +%y%m%d-%H%M%S; fi)
current_tag:=$(shell if [ ! `git status >/dev/null 2>&1` ]; then git rev-parse --abbrev-ref HEAD | sed -e 's/master/latest/'; else echo "latest"; fi)-$(current_subversion)

# Sources List: default / tencent / ustc / aliyun / huawei
build-arg:=--build-arg apt_source=tencent

# 设置本地下载服务器路径，加速调试时的本地编译速度
local_ip:=`ifconfig -a|grep inet|grep -v 127.0.0.1|grep -v inet6|awk '{print $$2}'|tr -d "addr:"`
build-arg+=--build-arg local_url=http://$(local_ip)/dist-files

.PHONY: build build-debian build-alpine clean clearclean upgrade

build: build-debian build-alpine
	@echo "Build complete"

build-debian:
	@echo "Build $(app_name):$(current_tag) and add tag: latest"
	@docker build --force-rm $(build-arg) -t $(app_name):$(current_tag) ./hadoop
	@docker tag $(app_name):$(current_tag) $(app_name):latest
	@echo "Build hadoop nodes"
	@docker build --force-rm $(build-arg) -t $(app_name)-journalnode:$(current_tag) ./journalnode
	@docker build --force-rm $(build-arg) -t $(app_name)-datanode:$(current_tag) ./datanode
	@docker build --force-rm $(build-arg) -t $(app_name)-namenode:$(current_tag) ./namenode
	@docker build --force-rm $(build-arg) -t $(app_name)-resourcemanager:$(current_tag) ./resourcemanager
	@docker build --force-rm $(build-arg) -t $(app_name)-nodemanager:$(current_tag) ./nodemanager
	@docker build --force-rm $(build-arg) -t $(app_name)-historyserver:$(current_tag) ./historyserver
	@echo "Add tag for nodes with: latest"
	@docker tag $(app_name)-journalnode:$(current_tag) $(app_name)-journalnode:latest
	@docker tag $(app_name)-datanode:$(current_tag) $(app_name)-datanode:latest
	@docker tag $(app_name)-namenode:$(current_tag) $(app_name)-namenode:latest
	@docker tag $(app_name)-resourcemanager:$(current_tag) $(app_name)-resourcemanager:latest
	@docker tag $(app_name)-nodemanager:$(current_tag) $(app_name)-nodemanager:latest
	@docker tag $(app_name)-historyserver:$(current_tag) $(app_name)-historyserver:latest

build-alpine:
	@echo "Build $(app_name):$(current_tag)-alpine and add tag: latest-alpine"
	@docker build --force-rm $(build-arg) -t $(app_name):$(current_tag)-alpine ./alpine/hadoop
	@docker tag $(app_name):$(current_tag)-alpine $(app_name):latest-alpine
	@echo "Build hadoop nodes"
	@docker build --force-rm $(build-arg) -t $(app_name)-journalnode:$(current_tag)-alpine ./alpine/journalnode
	@docker build --force-rm $(build-arg) -t $(app_name)-datanode:$(current_tag)-alpine ./alpine/datanode
	@docker build --force-rm $(build-arg) -t $(app_name)-namenode:$(current_tag)-alpine ./alpine/namenode
	@docker build --force-rm $(build-arg) -t $(app_name)-resourcemanager:$(current_tag)-alpine ./alpine/resourcemanager
	@docker build --force-rm $(build-arg) -t $(app_name)-nodemanager:$(current_tag)-alpine ./alpine/nodemanager
	@docker build --force-rm $(build-arg) -t $(app_name)-historyserver:$(current_tag)-alpine ./alpine/historyserver
	@echo "Add tag for nodes with: latest"
	@docker tag $(app_name)-journalnode:$(current_tag)-alpine $(app_name)-journalnode:latest-alpine
	@docker tag $(app_name)-datanode:$(current_tag)-alpine $(app_name)-datanode:latest-alpine
	@docker tag $(app_name)-namenode:$(current_tag)-alpine $(app_name)-namenode:latest-alpine
	@docker tag $(app_name)-resourcemanager:$(current_tag)-alpine $(app_name)-resourcemanager:latest-alpine
	@docker tag $(app_name)-nodemanager:$(current_tag)-alpine $(app_name)-nodemanager:latest-alpine
	@docker tag $(app_name)-historyserver:$(current_tag)-alpine $(app_name)-historyserver:latest-alpine

# 清理悬空的镜像（无TAG）及停止的容器 
clearclean: clean
	@echo "Clean untaged images and stoped containers..."
	@docker ps -a | grep "Exited" | awk '{print $$1}' | sort -u | xargs -L 1 docker rm
	@docker images | grep '<none>' | awk '{print $$3}' | sort -u | xargs -L 1 docker rmi -f

# 为了防止删除前缀名相同的镜像，在过滤条件中加入一个空格进行过滤
clean:
	@echo "Clean all images for current application..."
	@docker images | grep "$(app_name)-" | awk '{print $$3}' | sort -u | xargs -L 1 docker rmi -f
	@docker images | grep "$(app_name) " | awk '{print $$3}' | sort -u | xargs -L 1 docker rmi -f
	@docker rmi -f hadoop-wordcount || true

tag:
	@echo "Add tag: $(local_registory)/$(app_name):latest"
	@docker tag $(app_name):latest $(local_registory)/$(app_name):latest

push: tag
	@echo "Push: $(local_registory)/$(app_name):latest"
	@docker push $(local_registory)/$(app_name):latest
	@echo "Push: $(app_name):latest"
	@docker push $(app_name):latest

# 更新所有 colovu 仓库的镜像 
upgrade: 
	@echo "Upgrade all images..."
	@docker images | grep 'colovu' | grep -v '<none>' | grep -v "latest-" | awk '{print $$1":"$$2}' | sort -u | xargs -L 1 docker pull


DOCKER_NETWORK = back-tier
ENV_FILE = hadoop.env

# 字符统计样例，统计镜像 /usr/local/license/LICENSE 文件
wordcount-deb:
	docker network create ${DOCKER_NETWORK} --driver bridge || true
	docker-compose up -d namenode datanode
	docker rmi hadoop-wordcount-deb || true
	docker build -t hadoop-wordcount-deb ./submit
	sleep 5
	docker run --network ${DOCKER_NETWORK} --env-file ${ENV_FILE} $(app_name):$(current_tag)-deb "hdfs dfs -mkdir -p /input/"
	docker run --network ${DOCKER_NETWORK} --env-file ${ENV_FILE} $(app_name):$(current_tag)-deb "hdfs dfs -copyFromLocal -f /usr/local/license/LICENSE /input/"
	docker run --network ${DOCKER_NETWORK} --env-file ${ENV_FILE} hadoop-wordcount-deb
	docker run --network ${DOCKER_NETWORK} --env-file ${ENV_FILE} $(app_name):$(current_tag)-deb "hdfs dfs -cat /output/*"
	docker run --network ${DOCKER_NETWORK} --env-file ${ENV_FILE} $(app_name):$(current_tag)-deb "hdfs dfs -rm -r /output"
	docker run --network ${DOCKER_NETWORK} --env-file ${ENV_FILE} $(app_name):$(current_tag)-deb "hdfs dfs -rm -r /input"
	docker-compose down

wordcount:
	docker network create ${DOCKER_NETWORK} --driver bridge || true
	docker-compose -f docker-compose-alpine.yml up -d namenode datanode
	docker rmi hadoop-wordcount-deb || true
	docker build -t hadoop-wordcount ./submit
	sleep 5
	docker run --network ${DOCKER_NETWORK} --env-file ${ENV_FILE} $(app_name):$(current_tag) "hdfs dfs -mkdir -p /input/"
	docker run --network ${DOCKER_NETWORK} --env-file ${ENV_FILE} $(app_name):$(current_tag) "hdfs dfs -copyFromLocal -f /usr/local/license/LICENSE /input/"
	docker run --network ${DOCKER_NETWORK} --env-file ${ENV_FILE} hadoop-wordcount
	docker run --network ${DOCKER_NETWORK} --env-file ${ENV_FILE} $(app_name):$(current_tag) "hdfs dfs -cat /output/*"
	docker run --network ${DOCKER_NETWORK} --env-file ${ENV_FILE} $(app_name):$(current_tag) "hdfs dfs -rm -r /output"
	docker run --network ${DOCKER_NETWORK} --env-file ${ENV_FILE} $(app_name):$(current_tag) "hdfs dfs -rm -r /input"
	docker-compose down

# 以 /tmp/conf 及 /tmp/data 映射并启动集群后（至少 namenode 及 datanode）
# 
# docker run --network back-tier --env-file hadoop.env colovu/hadoop:latest-deb hdfs dfs -mkdir -p /input/
# docker run --network back-tier --env-file hadoop.env colovu/hadoop:latest-deb hdfs dfs -copyFromLocal -f /usr/local/license/LICENSE /input/
# docker run --network back-tier --env-file hadoop.env colovu/hadoop:latest-deb hadoop jar /usr/local/hadoop/share/hadoop/mapreduce/hadoop-mapreduce-examples-3.2.1.jar wordcount /input /output
# docker run --network back-tier --env-file hadoop.env colovu/hadoop:latest-deb hdfs dfs -cat /output/*
# docker run --network back-tier --env-file hadoop.env colovu/hadoop:latest-deb hdfs dfs -rm -r /output
# 
# docker run -it --network back-tier --env-file hadoop.env colovu/hadoop:latest-deb /bin/bash
#   hdfs dfs -mkdir -p /input
#   hdfs dfs -copyFromLocal /usr/local/license/LICENSE /input/
#   cd /usr/local/hadoop/share/hadoop/mapreduce
#   hadoop jar hadoop-mapreduce-examples-3.2.1.jar wordcount /input /output