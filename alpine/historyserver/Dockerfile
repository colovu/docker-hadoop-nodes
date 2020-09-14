# Ver: 1.0 by Endial Fang (endial@126.com)
#
FROM colovu/hadoop:latest-alpine

HEALTHCHECK CMD wget -O- -q http://localhost:8188/ || exit 1

ENV YARN_CONF_yarn_timeline___service_leveldb___timeline___store_path=/srv/data/hadoop/yarn/timeline

COPY customer /

EXPOSE 8188

CMD ["run.sh"]