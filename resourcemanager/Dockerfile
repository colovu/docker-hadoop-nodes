# Ver: 1.0 by Endial Fang (endial@126.com)
#
ARG registry_url="registry.cn-shenzhen.aliyuncs.com"
FROM ${registry_url}/colovu/hadoop:3.3

# 应用健康状态检查
HEALTHCHECK CMD wget -O- -q http://localhost:8088/ || exit 1

COPY customer /

EXPOSE 8088

CMD ["run.sh"]