FROM centos:7

ARG product_version=2017

# docker files
# https://github.com/Microsoft/mssql-docker/tree/master/linux/preview

# how to import data and all that in entrypoint
# https://github.com/twright-msft/mssql-node-docker-demo-app

# MS odbc drivers, using 13.1, steps are different for different drivers
# https://docs.microsoft.com/en-us/sql/connect/odbc/linux-mac/installing-the-microsoft-odbc-driver-for-sql-server

# Install latest mssql-server package - seems to be the "stop working after 180 days"
# version, see https://github.com/Microsoft/mssql-docker/issues/137#issuecomment-330064493
# RUN curl https://packages.microsoft.com/config/rhel/7/mssql-server.repo > /etc/yum.repos.d/mssql-server.repo && \
#    curl https://packages.microsoft.com/config/rhel/7/prod.repo > /etc/yum.repos.d/msprod.repo && \
#    ACCEPT_EULA=Y yum install -y mssql-server mssql-tools && \
#    yum clean all

# this seems to be the current working one
RUN curl https://packages.microsoft.com/config/rhel/7/mssql-server-2017.repo > /etc/yum.repos.d/mssql-server-2017.repo && \
    curl https://packages.microsoft.com/config/rhel/7/prod.repo > /etc/yum.repos.d/msprod.repo && \
    ACCEPT_EULA=Y yum install -y mssql-server mssql-tools mssql-server-fts && \
    yum clean all

ENV PATH=${PATH}:/opt/mssql/bin:/opt/mssql-tools/bin

# Default SQL Server TCP/Port
EXPOSE 1433

COPY ./mssql_setup.sh /
COPY ./mssql_entrypoint.sh /
COPY ./mssql_setup.sql /


RUN \
  chmod 755 /mssql_setup.sh /mssql_entrypoint.sh && \
  /mssql_setup.sh


ENTRYPOINT ["/mssql_entrypoint.sh"]
