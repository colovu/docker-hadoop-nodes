#!/bin/bash

. /usr/local/bin/appcommon.sh			# 应用专用函数库

eval "$(app_env)"

# 需要启动两个？
# sbin/mr-jobhistory-daemon.sh start historyserver 
# sbin/yarn-daemon.sh start timelineserver

yarn --config ${APP_CONF_DIR} historyserver
