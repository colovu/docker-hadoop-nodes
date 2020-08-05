# Ver: 1.0 by Endial Fang (endial@126.com)
#
FROM colovu/hadoop:3.3

# 应用健康状态检查
HEALTHCHECK CMD curl -f http://localhost:8088/ || exit 1

COPY run.sh /usr/local/bin/
RUN chmod a+x /usr/local/bin/run.sh

EXPOSE 8088

CMD ["run.sh"]