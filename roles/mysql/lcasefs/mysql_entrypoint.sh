#!/bin/bash

set -e
set -x

DATADIR="/var/lib/mysql"
MYSQLD="/usr/sbin/mysqld"
MYSQL_SOCK="/var/run/mysqld/mysql.sock"
MYSQLD_OPTS="--user=mysql --datadir=${DATADIR} --socket=${MYSQL_SOCK}"
MYSQL_PIDFILE="/var/run/mysqld/mysqld.pid"
MYSQL_PIDDIR="/var/run/mysqld/"
MYSQL_CNF="/etc/my.cnf"
MYSQL_CNF_DIR="/etc/my.cnf.d/"
MYSQL="/usr/bin/mysql --socket=${MYSQL_SOCK}"
MYSQLADMIN="/usr/bin/mysqladmin --socket=${MYSQL_SOCK}"

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
innodb_flush_log_at_trx_commit=0
default-authentication-plugin=mysql_native_password
lower_case_table_names=2

EOF

if [ ${IS_MYSQL} = 1 ]; then
	echo "!includedir /etc/my.cnf.d" >> ${MYSQL_CNF}
fi


dd if=/dev/zero of=/mysql_disk.img bs=1024 count=976563
dev=$( losetup --show -f /mysql_disk.img )
mkfs -t vfat ${dev}
rm -fr /var/lib/mysql
mkdir /var/lib/mysql
mount ${dev} /var/lib/mysql -o uid=mysql,gid=mysql

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

${MYSQL} << EOF
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
${MYSQLADMIN} shutdown



echo "starting mysql..."
${MYSQLD} ${MYSQLD_OPTS} --pid-file=${MYSQL_PIDFILE} &

function cleanup() {
    echo "cleaning up...."

    echo "killing mysql..."
    [ -f ${MYSQL_PIDFILE} ] && kill -SIGTERM `cat ${MYSQL_PIDFILE}` || true && sleep 2

    echo "done!"
}

trap cleanup INT
trap cleanup EXIT

echo "services started"

sleep 5

# main loop
while [ -f "${MYSQL_PIDFILE}" ] && \
                ps -p `cat ${MYSQL_PIDFILE}` > /dev/null  ; do
        sleep 5
done


