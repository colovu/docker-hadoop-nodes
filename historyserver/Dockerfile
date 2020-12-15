# Ver: 1.0 by Endial Fang (endial@126.com)
#
ARG registry_url="registry.cn-shenzhen.aliyuncs.com"
FROM ${registry_url}/colovu/hadoop:3.3

HEALTHCHECK CMD wget -O- -q http://localhost:8188/ || exit 1

ENV YARN_CONF_yarn_timeline___service_leveldb___timeline___store_path=/srv/data/hadoop/yarn/timeline

COPY customer /

EXPOSE 8188

CMD ["run.sh"]