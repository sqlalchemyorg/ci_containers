connect "SYS"/"xe" as SYSDBA;
set echo on;

alter system disable restricted session;
ALTER DATABASE default tablespace users;
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
