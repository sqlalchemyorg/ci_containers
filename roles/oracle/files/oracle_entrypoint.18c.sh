#!/bin/bash

# create listener.ora and tnsnames.ora files based on the .tmpl
# versions that we created when we first made the image.
LISTENER_ORA=/opt/oracle/product/18c/dbhomeXE/network/admin/listener.ora
TNSNAMES_ORA=/opt/oracle/product/18c/dbhomeXE/network/admin/tnsnames.ora

# substitute current host/port into the template file which should
# have tokens %hostname% %port% inside of it.   oracle listener won't
# start if these aren't correct for the container's current hostname
cp "${LISTENER_ORA}.tmpl" "$LISTENER_ORA" &&
sed -i "s/%hostname%/$HOSTNAME/g" "${LISTENER_ORA}" &&
sed -i "s/%port%/1521/g" "${LISTENER_ORA}" &&
cp "${TNSNAMES_ORA}.tmpl" "$TNSNAMES_ORA" &&
sed -i "s/%hostname%/$HOSTNAME/g" "${TNSNAMES_ORA}" &&
sed -i "s/%port%/1521/g" "${TNSNAMES_ORA}"

/etc/init.d/oracle-xe-18c start


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

