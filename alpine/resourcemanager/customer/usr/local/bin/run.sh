#!/bin/bash
# Ver: 1.1 by Endial Fang (endial@126.com)
# 
# 应用启动脚本

. /usr/local/bin/comm-${APP_NAME}.sh			# 应用专用函数库

. /usr/local/bin/comm-env.sh 			# 设置环境变量

LOG_I "Start ResourceManager process..."
yarn --config ${APP_CONF_DIR} resourcemanager