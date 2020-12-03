#!/bin/bash
# Ver: 1.1 by Endial Fang (endial@126.com)
# 
# 应用启动脚本

. /usr/local/bin/comm-${APP_NAME}.sh			# 应用专用函数库

. /usr/local/bin/comm-env.sh 			# 设置环境变量


if [ -e ${HDFS_NAMENODE_DATA_DIR}/lost+found ]; then
	LOG_I "remove lost+found from ${HDFS_NAMENODE_DATA_DIR}"
	rm -r ${HDFS_NAMENODE_DATA_DIR}/lost+found
fi

# 如果数据为空，初始化节点
#   - 如果 当前节点 与 集群活跃节点 相同，则初始化数据，并激活 zkfc
#   
if [ "`ls -A ${HDFS_NAMENODE_DATA_DIR}`" == "" ]; then
	LOG_D "Active Namenode: ${HADOOP_ACTIVED_NAMENODE}"
	LOG_D "Current Namenode: ${HADOOP_CURRENT_NAMENODE}"
	if [ "${HADOOP_ACTIVED_NAMENODE:-}" = "${HADOOP_CURRENT_NAMENODE}" ]; then
  		if [[ -n "${CORE_CONF_ha_zookeeper_quorum}" ]]; then
  			LOG_I "Formatting Zookeeper Failover Controller"
			hdfs --config ${APP_CONF_DIR} zkfc -formatZK -nonInteractive
		fi

  		LOG_I "Formatting namenode(HA) data directory: ${HDFS_NAMENODE_DATA_DIR}"
  		hdfs --config ${APP_CONF_DIR} namenode -format -nonInteractive
  		LOG_I "Start Zookeeper Failover Controller for Namenode HA"
  		hdfs --config ${APP_CONF_DIR} --daemon start zkfc
  	else
  		if [[ -n "${HADOOP_ACTIVED_NAMENODE:-}" ]]; then
  			LOG_I "Formatting secondary namenode, directory: ${HDFS_NAMENODE_DATA_DIR}"
  			#hdfs --config ${APP_CONF_DIR} namenode -bootstrapStandby -nonInteractive -skipSharedEditsCheck
  			hdfs --config ${APP_CONF_DIR} namenode -bootstrapStandby -nonInteractive
  			LOG_I "Start Zookeeper Failover Controller for Namenode HA"
  			hdfs --config ${APP_CONF_DIR} --daemon start zkfc
  		else
  			LOG_I "Formatting namenode data directory: ${HDFS_NAMENODE_DATA_DIR}"
  			hdfs --config ${APP_CONF_DIR} namenode -format -nonInteractive
  		fi
  	fi
else
	if [[ -n "${HADOOP_ACTIVED_NAMENODE:-}" ]]; then
		LOG_I "Start Zookeeper Failover Controller for Namenode HA"
		hdfs --config ${APP_CONF_DIR} --daemon start zkfc
	fi
fi

LOG_I "Start NameNode process..."
hdfs --config ${APP_CONF_DIR} namenode