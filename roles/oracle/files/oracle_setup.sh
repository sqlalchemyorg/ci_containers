#!/bin/bash

# tricks, tuning, techniques taken from
# https://github.com/wnameless/docker-oracle-xe-11g/

set -x
set -e

HERE=`dirname $0`

ORACLE_HOME=/u01/app/oracle/product/11.2.0/xe

INIT_ORA=${ORACLE_HOME}/config/scripts/init.ora
INIT_ORAXE=${ORACLE_HOME}/config/scripts/initXETemp.ora
LISTENER=${ORACLE_HOME}/network/admin/listener.ora
TNSNAMES=${ORACLE_HOME}/network/admin/tnsnames.ora

# https://docs.oracle.com/cd/B28359_01/server.111/b28320/initparams133.htm#REFRN10285
# https://docs.oracle.com/cd/B19306_01/server.102/b14237/initparams157.htm#REFRN10165
# https://docs.oracle.com/cd/B19306_01/server.102/b14237/initparams193.htm#REFRN10256

for file in "${INIT_ORA}" "${INIT_ORAXE}"; do
	sed -e '/memory_target/ s/^#*/#/' -i ${file}
	sed -e '/memory_target/ i pga_aggregate_target=200540160' -i ${file}
	sed -e '/memory_target/ i sga_target=610620480' -i ${file}
done


# Backup listener.ora as template
cp ${LISTENER} ${LISTENER}.tmpl
cp ${TNSNAMES} ${TNSNAMES}.tmpl


/etc/init.d/oracle-xe configure responseFile=${HERE}/oracle_responsefile.txt

ln -s  /u01/app/oracle/product/11.2.0/xe/bin/oracle_env.sh /etc/profile.d/oracle_env.sh
echo "export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:${ORACLE_HOME}/lib" >> /etc/profile.d/oracle_env.sh

source /etc/profile.d/oracle_env.sh
${ORACLE_HOME}/bin/sqlplus -s /nolog @/oracle_setup.sql


