# Ver: 1.0 by Endial Fang (endial@126.com)
#
FROM colovu/hadoop:3.2

# 应用健康状态检查
HEALTHCHECK CMD wget -O- -q http://localhost:9864/ || exit 1

COPY customer /

EXPOSE 9864

CMD ["run.sh"]