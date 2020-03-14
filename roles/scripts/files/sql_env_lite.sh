#!/bin/bash

source /usr/local/jenkins/scripts/python_env.sh
source /etc/profile.d/oracle_env.sh

# TODO: template this....

# NOTE: these URLs need to work for old SQLAlchemy versions 0.9, 1.0 for
# alembic unit tests, so mysql80 is out.
export TOX_MYSQL=\
"--dburi mysql+pymysql://scott:tiger@mariadb104/test?charset=utf8mb4 "\
"--dburi mysql+mysqldb://scott:tiger@mysql57/test?charset=utf8mb4 "

export TOX_POSTGRESQL=\
"--postgresql-templatedb=ci_template "\
"--dburi postgresql+psycopg2://scott:tiger@pg96/test "

export TOX_ORACLE="--dburi oracle+cx_oracle://scott:tiger@oracle1120/xe"

export TOX_MSSQL=\
"--dburi mssql+pyodbc://scott:tiger^5HHH@mssql2017:1433/test?driver=ODBC+Driver+13+for+SQL+Server "

#export TOX_MSSQL="--dburi mssql+pymssql://scott:tiger^5HHH@mssql2017:1433/test"
