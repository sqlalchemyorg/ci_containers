#!/bin/bash


source /usr/local/jenkins/scripts/python_env.sh
source /etc/profile.d/oracle_env.sh

# TODO: template this....
# mysqlconnector at the moment seems to have much better support for
# things provided we use the correct package.
export TOX_MYSQL=\
"--dburi mysql+mysqldb://scott:tiger@mariadb104/test?charset=utf8mb4 "\
"--dburi mysql+pymysql://scott:tiger@mariadb105/test?charset=utf8mb4 "\
"--dburi mysql+pymysql://scott:tiger@mysql57/test?charset=utf8mb4 "\
"--dburi mysql+mysqldb://scott:tiger@mysql56/test?charset=utf8mb4 "\
"--dburi mysql+mysqldb://scott:tiger@mysql80/test?charset=utf8mb4 "\
"--dburi mysql+pymysql://scott:tiger@mysql80/test?charset=utf8mb4 "


# "--dburi mysql+mysqldb://scott:tiger@mariadb102/test?charset=utf8 "\


export TOX_POSTGRESQL=\
"--postgresql-templatedb=ci_template "\
"--dburi postgresql+psycopg2://scott:tiger@pg12/test "\
"--dburi postgresql+psycopg2://scott:tiger@pg11/test "\
"--dburi postgresql+psycopg2://scott:tiger@pg10/test "\
"--dburi postgresql+psycopg2://scott:tiger@pg96/test "


export TOX_ORACLE="--dburi oracle+cx_oracle://scott:tiger@oracle1120/xe"

# the ODBC url needs to be fully qualified so that the
# process runner can create new database URLs
export TOX_MSSQL=\
"--dburi mssql+pyodbc://scott:tiger^5HHH@mssql2017:1433/test?driver=ODBC+Driver+13+for+SQL+Server "
#\
#"--dburi mssql+pymssql://scott:tiger^5HHH@mssql2017:1433/test "
