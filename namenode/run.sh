#!/bin/bash

. /usr/local/bin/appcommon.sh			# 应用专用函数库

eval "$(docker_app_env)"

if [ -z "${HADOOP_CLUSTER_NAME}" ]; then
  echo "Cluster name not specified"
  exit 2
fi

echo "remove lost+found from ${HDFS_NAMENODE_DATA_DIR}"
rm -r ${HDFS_NAMENODE_DATA_DIR}/lost+found

if [ "`ls -A ${HDFS_NAMENODE_DATA_DIR}`" == "" ]; then
  echo "Formatting namenode name directory: ${HDFS_NAMENODE_DATA_DIR}"
  hdfs --config ${APP_CONF_DIR} namenode -format ${HADOOP_CLUSTER_NAME}
fi

hdfs --config ${APP_CONF_DIR} namenode