#!/bin/bash

LISTENER_ORA=/u01/app/oracle/product/11.2.0/xe/network/admin/listener.ora
TNSNAMES_ORA=/u01/app/oracle/product/11.2.0/xe/network/admin/tnsnames.ora

# use the .tmpl files we created during setup, swap in the
# current hostname for the container
cp "${LISTENER_ORA}.tmpl" "$LISTENER_ORA" &&
sed -i "s/%hostname%/$HOSTNAME/g" "${LISTENER_ORA}" &&
sed -i "s/%port%/1521/g" "${LISTENER_ORA}" &&
cp "${TNSNAMES_ORA}.tmpl" "$TNSNAMES_ORA" &&
sed -i "s/%hostname%/$HOSTNAME/g" "${TNSNAMES_ORA}" &&
sed -i "s/%port%/1521/g" "${TNSNAMES_ORA}"

/etc/init.d/oracle-xe start

# after start?   do we need this?
export ORACLE_HOME=/u01/app/oracle/product/11.2.0/xe
export PATH=$ORACLE_HOME/bin:$PATH
export ORACLE_SID=XE



function cleanup() {
    echo "cleaning up...."

    echo "stopping oracle..."
    /etc/init.d/oracle-xe stop

    echo "done!"
}

trap cleanup INT
trap cleanup EXIT

echo "services started"

sleep 5

# main loop
while ps -e | grep oracle > /dev/null; do
	sleep 5
done

