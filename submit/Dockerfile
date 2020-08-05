# Ver: 1.0 by Endial Fang (endial@126.com)
#
FROM colovu/hadoop:3.3

COPY WordCount.jar /opt/hadoop/applications/WordCount.jar

ENV JAR_FILEPATH="/opt/hadoop/applications/WordCount.jar"
ENV CLASS_TO_RUN="WordCount"
ENV PARAMS="/input /output"

COPY run.sh /usr/local/bin/
RUN chmod a+x /usr/local/bin/run.sh

EXPOSE 9000 9870

CMD ["run.sh"]