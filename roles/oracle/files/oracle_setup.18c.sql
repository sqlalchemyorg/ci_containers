-- https://docs.oracle.com/cd/B25329_01/doc/admin.102/b25107/users_secure.htm
connect sys/xe as sysdba;


set echo on;

alter system disable restricted session;
ALTER DATABASE default tablespace users;


-- need to set COMMON_USER_PREFIX, so that we can have normal looking usernames
-- https://docs.oracle.com/database/121/SQLRF/statements_8003.htm#SQLRF01503
-- need to use scope=SPFILE w/ shutdown as this is a non-runtime parameter
-- https://dbaclass.com/article/ora-02095-specified-initialization-parameter-cannot-modified/
-- we could also set these when the DB is created using -initParams but that
-- means we'd have to modify the very dense /etc/init.d/oracle-xe-18c script
-- which doesn' let us set this
ALTER SYSTEM SET COMMON_USER_PREFIX='' scope=SPFILE;
SHUTDOWN IMMEDIATE;
STARTUP;

ALTER PROFILE DEFAULT LIMIT  FAILED_LOGIN_ATTEMPTS UNLIMITED PASSWORD_LIFE_TIME UNLIMITED;
NOAUDIT ALL;
DELETE FROM SYS.AUD$;
create user scott identified by tiger;
grant create session to scott;
grant dba to scott;
create user test_schema identified by xe;
create user test_schema_2 identified by xe;
grant unlimited tablespace to scott;
grant unlimited tablespace to test_schema;
grant unlimited tablespace to test_schema_2;
create public database link test_link connect to scott identified by tiger using 'xe';
exit;
