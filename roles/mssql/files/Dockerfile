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
# crashes on ryzen1 as of 2/2024
# set kernel to 6.6:
# root@ryzen1:/home/classic# grubby --set-default /boot/vmlinuz-6.6.4-100.fc38.x86_64
# The default is /boot/loader/entries/b32bbedf9c7941f7b8f8d2970941b280-6.6.4-100.fc38.x86_64.conf with index 2 and kernel /boot/vmlinuz-6.6.4-100.fc38.x86_64
# see https://github.com/microsoft/mssql-docker/issues/868
RUN curl https://packages.microsoft.com/config/rhel/7/mssql-server-2017.repo > /etc/yum.repos.d/mssql-server-2017.repo && \
    curl https://packages.microsoft.com/config/rhel/7/prod.repo > /etc/yum.repos.d/msprod.repo && \
    ACCEPT_EULA=Y yum install -y mssql-server mssql-tools mssql-server-fts && \
    yum clean all

# when fixed, we will use 2022:
# RUN curl https://packages.microsoft.com/config/rhel/9/mssql-server-2022.repo > /etc/yum.repos.d/mssql-server-2022.repo && \
#     curl https://packages.microsoft.com/config/rhel/9/prod.repo > /etc/yum.repos.d/msprod.repo && \
#     ACCEPT_EULA=Y dnf install -y mssql-server mssql-tools mssql-server-fts && \
#     dnf clean all

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
