Docker is using the host swapfile.

So need to add swap to the outside:

# error will be ORA-000845 if swap is not big enough
# http://www.dba-oracle.com/t_ora_00845_memory_target_not_supported_linux_hugepages.htm

dd if=/dev/zero of=/home/var/extra_swap_for_oracle bs=1k count=8000000
chmod 600 /home/var/extra_swap_for_oracle
mkswap /home/var/extra_swap_for_oracle
swapon -v /home/var/extra_swap_for_oracle




set verify off
DEFINE sysPassword = "oracle"
DEFINE systemPassword = "oracle"
host /u01/app/oracle/product/11.2.0/xe/bin/orapwd file=/u01/app/oracle/product/11.2.0/xe/dbs/orapwXE password=&&sysPassword force=y
@/u01/app/oracle/product/11.2.0/xe/config/scripts/CloneRmanRestore.sql
@/u01/app/oracle/product/11.2.0/xe/config/scripts/cloneDBCreation.sql
@/u01/app/oracle/product/11.2.0/xe/config/scripts/postScripts.sql
@/u01/app/oracle/product/11.2.0/xe/config/scripts/postDBCreation.sql
exit
