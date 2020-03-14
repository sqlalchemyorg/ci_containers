#!/bin/bash

set -x

MYSQL_VERSION=$1

DATADIR="/var/lib/mysql"
MYSQLD=/usr/sbin/mysqld
MYSQLD_OPTS="--user=mysql --datadir=${DATADIR}"
MYSQL_PIDDIR="/var/run/mysqld/"
MYSQL_CNF="/etc/my.cnf"
MYSQL_CNF_DIR="/etc/my.cnf.d/"

if [ `echo "${MYSQL_VERSION}" | sed -n '/mysql_/ p'` ]; then
	IS_MYSQL=1
else
	IS_MYSQL=0
fi

if [ ! -d "${MYSQL_PIDDIR}" ]; then
	mkdir -p "${MYSQL_PIDDIR}"
	chown mysql:mysql "${MYSQL_PIDDIR}"
fi

if [ ! -d "${MYSQL_CNF_DIR}" ]; then
	mkdir -p "${MYSQL_CNF_DIR}"
	chown mysql:mysql "${MYSQL_CNF_DIR}"
fi

cat <<EOF > ${MYSQL_CNF_DIR}/server_custom.cnf
[mysqld]
max_connections=300
innodb_buffer_pool_size=500M
innodb_log_file_size=512M
innodb_flush_log_at_trx_commit=0
default-authentication-plugin=mysql_native_password

EOF

if [ ${IS_MYSQL} = 1 ]; then
	echo "!includedir /etc/my.cnf.d" >> ${MYSQL_CNF}
fi

if [ `echo "${MYSQL_VERSION}" | sed -n '/mysql_\(5.7\|8.0\)/ p'` ]; then
	# 5.7/8.0 only, we need insecure so that no root pw generated
	${MYSQLD} ${MYSQLD_OPTS} --initialize-insecure
else
	# all mariadb and mysql 5.6
	mysql_install_db ${MYSQLD_OPTS}
fi

# MySQL 5.7 has a --daemonize option but nobody else supports it
${MYSQLD} ${MYSQLD_OPTS} &

# this used to be 1 second, but with oracle^H^H^H^H mysql 8.0, no more
sleep 10

mysql << EOF
DROP DATABASE IF EXISTS test;
CREATE DATABASE test CHARSET utf8mb4;
CREATE USER scott@'%' IDENTIFIED BY 'tiger';
GRANT ALL ON *.* TO scott@'%';
CREATE DATABASE test_schema CHARSET utf8mb4;
CREATE DATABASE test_schema_2 CHARSET utf8mb4;
CREATE DATABASE openstack_citest CHARSET utf8mb4;
CREATE USER openstack_citest IDENTIFIED BY 'openstack_citest';
GRANT ALL ON *.* TO openstack_citest;
EOF
mysqladmin shutdown
