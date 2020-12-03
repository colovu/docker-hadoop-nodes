# Ver: 1.0 by Endial Fang (endial@126.com)
#
FROM colovu/hadoop:3.2-alpine

# 应用健康状态检查
HEALTHCHECK CMD wget -O- -q http://localhost:9870/ || exit 1

COPY customer /

EXPOSE 9000 9870 8020

CMD ["run.sh"]