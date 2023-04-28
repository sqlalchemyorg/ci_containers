#!/bin/bash

set -x


POSTGRESQL_VERSION=$1

ln -s /usr/pgsql-${POSTGRESQL_VERSION} /usr/pgsql
POSTGRESQL_BIN=/usr/pgsql/bin

RUNASPG="su -l postgres -c"

VERSION_TOKEN=`echo '${POSTGRESQL_VERSION}' | awk -F. '{ print $1$2 }'`

PGBASE=/var/lib/pgsql

# rm the "9.x" directory that seems to get
# put here by the package
rm -fr /var/lib/pgsql/*

PGDATA=${PGBASE}/data
PGLOG=${PGBASE}/initdb.log

mkdir -p "$PGDATA"
chown postgres:postgres "$PGDATA"
chmod go-rwx "$PGDATA"

touch "$PGLOG"
chown postgres:postgres "$PGLOG"
chmod go-rwx "$PGLOG"

# Initialize the database
# locale thing: https://stackoverflow.com/questions/50746147/postgresqls-initdb-fails-with-invalid-locale-settings-check-lang-and-lc-e/50748554
#initdbcmd="$POSTGRESQL_BIN/initdb --pgdata='$PGDATA' --auth='ident' --no-locale --encoding=UTF8"
initdbcmd="$POSTGRESQL_BIN/initdb --pgdata='$PGDATA' --auth='ident' --locale en_US.UTF8  --encoding=UTF8"


${RUNASPG} "$initdbcmd" >> "$PGLOG" 2>&1 < /dev/null

# listen on all interfaces
sed -ie "/port/ i listen_addresses = '*'"  /var/lib/pgsql/data/postgresql.conf

# TODO: template the timezone
sed -ie "s/^timezone.*/timezone='America\/New_York'/" /var/lib/pgsql/data/postgresql.conf

sed -ie "/max_prepared_transactions/ i max_prepared_transactions = 10" /var/lib/pgsql/data/postgresql.conf

sed -ie "s/^max_connections.*/max_connections = 200/" /var/lib/pgsql/data/postgresql.conf

# set password auth
sed -ie 's/\(.*\)127.0.0.1\/32 \+ident/\1 0.0.0.0\/0        md5/' /var/lib/pgsql/data/pg_hba.conf

# Create directory for postmaster log files
mkdir "$PGDATA/pg_log"
chown postgres:postgres "$PGDATA/pg_log"
chmod go-rwx "$PGDATA/pg_log"

${RUNASPG} "${POSTGRESQL_BIN}/pg_ctl start -D ${PGDATA} -s -w"

cat <<'EOF' | ${RUNASPG} "${POSTGRESQL_BIN}/psql"
CREATE ROLE scott WITH LOGIN PASSWORD 'tiger';
ALTER USER scott CREATEDB;
create database test with owner=scott encoding='utf8' template=template0;
grant all privileges on database test to scott;

\c test;
create extension hstore;
CREATE EXTENSION btree_gist;
create schema test_schema authorization scott;
create schema test_schema_2 authorization scott;

create database ci_template with owner=scott template=test;
update pg_database set datistemplate=true, datallowconn=false where datname='ci_template';

CREATE ROLE openstack_citest WITH LOGIN PASSWORD 'openstack_citest';
CREATE DATABASE openstack_citest WITH OWNER=openstack_citest encoding='utf8' template=template0;
ALTER USER openstack_citest CREATEDB;
EOF

${RUNASPG} "${POSTGRESQL_BIN}/pg_ctl stop -D ${PGDATA} -s -m fast"


