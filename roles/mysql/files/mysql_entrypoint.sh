#!/bin/bash

set -e

DATADIR="/var/lib/mysql"
MYSQLD="/usr/sbin/mysqld"
MYSQLD_OPTS="--user=mysql --datadir=${DATADIR}"
MYSQL_PIDFILE="/var/run/mysqld/mysqld.pid"

# this is a workaround for a not-understood failure mode
# where MySQL server won't start using the datadir that was initialized
# in the build image, but has not been accessed yet.   only with
# renaming/naming-back the datadir or touch etc. does it suddenly
# not have a problem (or just restarting mysql several times, as its own
# observation of the file changes it.  So something in the docker file driver
# (overlay2) is getting in the way.
# similar error seen in: https://github.com/docker-library/mysql/issues/216
# however they got past it without noticing it
find /var/lib/mysql -type f -exec touch {} \;

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


