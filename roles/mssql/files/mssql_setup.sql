CREATE DATABASE test;
go
CREATE LOGIN scott with password='tiger^5HHH';
GRANT CONTROL SERVER TO scott;
USE test;
go
CREATE SCHEMA test_schema;
go
ALTER DATABASE test SET ALLOW_SNAPSHOT_ISOLATION ON
ALTER DATABASE test SET READ_COMMITTED_SNAPSHOT ON
go
