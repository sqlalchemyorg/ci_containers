#!/bin/bash

set -e
set -x

source /usr/local/jenkins/scripts/sql_env.sh

HERE=`pwd`
rm -fr run_alembic
mkdir run_alembic
cd run_alembic
virtualenv .
./bin/pip install tox
git clone https://github.com/sqlalchemy/alembic
cd alembic

sed -i.tmp "s#^\( *\)sqlamaster: .*#\1sqlamaster: git+file://$HERE#" tox.ini;
tox -r -e ${pyv}-sqlamaster-sqlite-postgresql-mysql-oracle -- --junitxml=junit-${pyv}-sqlamaster.xml
