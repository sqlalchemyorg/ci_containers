FROM centos

ARG product_version=11.2.0

WORKDIR /opt

RUN \
	yum install -y unzip libaio-devel libnsl bc redhat-rpm-config && \
	mkdir /usr/local/src/oracle && \
	cd /usr/local/src/oracle && \
	curl -L -O https://jenkins.sqlalchemy.org/downloads/oracle-xe-${product_version}-1.0.x86_64.rpm.zip && \
	unzip oracle-xe-${product_version}-1.0.x86_64.rpm.zip && \
	yum install -y /usr/local/src/oracle/Disk1/oracle-xe-${product_version}-1.0.x86_64.rpm && \
	cd .. && rm -fr oracle

COPY ./oracle_setup.sh /
COPY ./oracle_entrypoint.sh /
COPY ./oracle_responsefile.txt /
COPY ./oracle_setup.sql /
COPY ./functions /etc/init.d/functions

RUN \
	chmod 755 /oracle_setup.sh /oracle_entrypoint.sh && \
	/oracle_setup.sh

EXPOSE 8085/tcp
EXPOSE 1521/tcp

ENTRYPOINT ["/oracle_entrypoint.sh"]
