#!/bin/bash

# tricks, tuning, techniques taken from
# https://github.com/wnameless/docker-oracle-xe-11g/

set -x
set -e

HERE=`dirname $0`

export ORACLE_HOME=/opt/oracle/product/18c/dbhomeXE


LISTENER=${ORACLE_HOME}/network/admin/listener.ora
TNSNAMES=${ORACLE_HOME}/network/admin/tnsnames.ora



# create listener / tns templates.  this version of oracle doesn't
# give us one :|

cat <<EOF > $LISTENER.tmpl

DEFAULT_SERVICE_LISTENER = XE

LISTENER =
  (DESCRIPTION_LIST =
    (DESCRIPTION =
      (ADDRESS = (PROTOCOL = TCP)(HOST = %hostname%)(PORT = %port%))
      (ADDRESS = (PROTOCOL = IPC)(KEY = EXTPROC1521))
    )
  )

EOF


cat <<EOF > $TNSNAMES.tmpl

XE =
  (DESCRIPTION =
    (ADDRESS = (PROTOCOL = TCP)(HOST = %hostname%)(PORT = %port%))
    (CONNECT_DATA =
      (SERVER = DEDICATED)
      (SERVICE_NAME = XE)
    )
  )

LISTENER_XE =
  (ADDRESS = (PROTOCOL = TCP)(HOST = %hostname%)(PORT = %port%))


EOF


# note - this oracle-xe-18c thing has a "delete" command, so you can start
# all over again!  this is the only apparent way to "configure" again
# or change anything.

# the command it's running, the main help for createdatabase can be had
# like:
# su -s /bin/bash  oracle -c "dbca -silent -createDatabase -help"

(echo "xe"; echo "xe";) | /etc/init.d/oracle-xe-18c configure

# no clue why this isn't set up already?
chmod 777  /opt/oracle/product/18c/dbhomeXE/network/log/

ln -s  /oracle_env.18c.sh /etc/profile.d/oracle_env.sh

source /etc/profile.d/oracle_env.sh
${ORACLE_HOME}/bin/sqlplus -s /nolog @/oracle_setup.18c.sql


