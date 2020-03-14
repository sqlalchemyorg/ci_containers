FROM centos

ARG product_version=9.6
ARG repotag=9.6-3

WORKDIR /opt

RUN \
	VERSION_TOKEN=`echo "${product_version}" | awk -F. '{ print $1$2 }'` && \
	curl -OL https://download.postgresql.org/pub/repos/yum/${product_version}/redhat/rhel-7-x86_64/pgdg-redhat-repo-latest.noarch.rpm && \
	rpm -i pgdg-redhat-repo-latest.noarch.rpm

RUN \
	VERSION_TOKEN=`echo "${product_version}" | awk -F. '{ print $1$2 }'` && \
	yum install -y \
		postgresql${VERSION_TOKEN} \
		postgresql${VERSION_TOKEN}-contrib \
		postgresql${VERSION_TOKEN}-server

COPY ./postgresql_setup.sh /
COPY ./postgresql_entrypoint.sh /

RUN \
	chmod 755 /postgresql_setup.sh /postgresql_entrypoint.sh && \
	/postgresql_setup.sh "${product_version}"

EXPOSE 5432


ENTRYPOINT ["/postgresql_entrypoint.sh"]



