# Ver: 1.0 by Endial Fang (endial@126.com)
#
FROM colovu/hadoop:3.3-alpine

# 应用健康状态检查
HEALTHCHECK CMD wget -O- -q http://localhost:8485/ || exit 1

COPY customer /

EXPOSE 8485

CMD ["run.sh"]