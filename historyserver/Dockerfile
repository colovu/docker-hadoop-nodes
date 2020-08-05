# Ver: 1.0 by Endial Fang (endial@126.com)
#
FROM colovu/hadoop:3.3

HEALTHCHECK CMD curl -f http://localhost:8188/ || exit 1

ENV YARN_CONF_yarn_timeline___service_leveldb___timeline___store_path=/srv/data/hadoop/yarn/timeline

COPY run.sh /usr/local/bin/
RUN chmod a+x /usr/local/bin/run.sh

EXPOSE 8188

CMD ["run.sh"]