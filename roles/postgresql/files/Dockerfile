FROM centos

ARG product_version=9.6

WORKDIR /opt

# run huge locale dance:
# https://stackoverflow.com/questions/58304278/how-to-fix-character-map-file-utf-8-not-found
# https://unix.stackexchange.com/questions/140299/locale-gen-command-in-centos6
# also seems to return a nonzero error code but it makes PG work below so just || true it
RUN \
	yum -y install glibc-locale-source glibc-langpack-en && \
	localedef -v -c -i en_US -f UTF-8 en_US.UTF-8 || true


RUN \
	VERSION_TOKEN=`echo "${product_version}" | awk -F. '{ print $1$2 }'` && \
	curl -OL https://download.postgresql.org/pub/repos/yum/reporpms/EL-8-x86_64/pgdg-redhat-repo-latest.noarch.rpm && \
	rpm -i pgdg-redhat-repo-latest.noarch.rpm

# centos8 thing
# https://www.postgresql.org/download/linux/redhat/
RUN dnf -qy module disable postgresql


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



