FROM mysql:5.7

MAINTAINER Ilya Kovalenko <agentsib@gmail.com>

COPY build.sh /opt/

COPY mysql-5.7.patch /opt/mysql-5.7.patch

COPY 10-pinba-db-init.sh /docker-entrypoint-initdb.d/

RUN cd /opt && ./build.sh

EXPOSE 30002
EXPOSE 3306