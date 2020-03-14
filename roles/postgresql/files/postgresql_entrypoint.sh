#!/bin/bash

set -e

# symlink created by postgresql_setup
POSTGRESQL_BIN=/usr/pgsql/bin

RUNASPG="su -l postgres -c"

VERSION_TOKEN=`echo '${POSTGRESQL_VERSION}' | awk -F. '{ print $1$2 }'`

PGBASE=/var/lib/pgsql
PGDATA=${PGBASE}/data
PGLOG=${PGBASE}/initdb.log

POSTGRESQLCTL=${POSTGRESQL_BIN}/pg_ctl
PGSTARTTIMEOUT=270
PIDFILE=${PGDATA}/postmaster.pid


echo "starting postgresql..."
${RUNASPG} "${POSTGRESQLCTL} start -D ${PGDATA} -s -w -t ${PGSTARTTIMEOUT}"

function cleanup() {
    echo "cleaning up...."

    echo "killing postgresql..."
    [ -f ${PIDFILE} ] && kill -SIGTERM `head -1 ${PIDFILE}` || true && sleep 2

    echo "done!"
}

trap cleanup INT
trap cleanup EXIT

echo "services started"

sleep 5

# main loop
while [ -f "${PIDFILE}" ] && \
                ps -p `head -1 ${PIDFILE}` > /dev/null  ; do
        sleep 5
done


