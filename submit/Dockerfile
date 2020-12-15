# Ver: 1.0 by Endial Fang (endial@126.com)
#
ARG registry_url="registry.cn-shenzhen.aliyuncs.com"
FROM ${registry_url}/colovu/hadoop:3.3

COPY WordCount.jar /opt/hadoop/applications/WordCount.jar

ENV JAR_FILEPATH="/opt/hadoop/applications/WordCount.jar"
ENV CLASS_TO_RUN="WordCount"
ENV PARAMS="/input /output"

COPY customer /

EXPOSE 9000 9870

CMD ["run.sh"]