#!/bin/bash

. /usr/local/bin/appcommon.sh			# 应用专用函数库

eval "$(app_env)"

hadoop jar $JAR_FILEPATH $CLASS_TO_RUN $PARAMS