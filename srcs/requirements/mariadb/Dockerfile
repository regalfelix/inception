FROM debian:12.15

RUN apt-get update && \
    apt-get install -y --no-install-recommends mariadb-server mariadb-client && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

COPY tools/docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh && \
    mkdir -p /run/mysqld && chown mysql:mysql /run/mysqld

#overwrite localhost for 0.0.0.0 to connect wordpress
RUN echo "[mysqld]\nbind-address = 0.0.0.0" > /etc/mysql/mariadb.conf.d/50-server.cnf

ENTRYPOINT ["docker-entrypoint.sh"]

EXPOSE 3306
