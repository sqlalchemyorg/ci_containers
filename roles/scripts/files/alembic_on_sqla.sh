#!/bin/bash

set -e
set -x

source /usr/local/jenkins/scripts/sql_env.sh

# we want to run on light weight instances so
# don't include oracle for the moment
TARGETS="sqlamaster-sqlite-postgresql-mysql"
#TARGETS="sqlamaster-sqlite"


HERE=`pwd`
rm -fr run_alembic
mkdir run_alembic
cd run_alembic
virtualenv .
./bin/pip install tox
git clone https://github.com/sqlalchemy/alembic
cd alembic

# no way to check out from Jenkins file with @ sign in it within tox.
# make a temp directory :(


tmp_dir=$(mktemp -d -t ci-XXXXXXXXXX)

trap "rm -rf $tmp_dir" EXIT

BASENAME=$(basename ${HERE})

ln -s ${HERE} ${tmp_dir}/${BASENAME}

sed -i.tmp "s#^\( *\)sqlamaster: .*#\1sqlamaster: git+file://${tmp_dir}/${BASENAME}#" tox.ini;
tox -r -e ${pyv}-${TARGETS} -- --junitxml=junit-${pyv}-sqlamaster.xml

