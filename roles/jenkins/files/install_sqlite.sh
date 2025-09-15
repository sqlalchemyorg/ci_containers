#!/bin/bash

set -x
set -e

function install_sqlite3() {
	VERSION=$1
	RELEASE_YEAR=`echo $VERSION | awk -F_ '{print $1}'`
	RELEASE_VERSION=`echo $VERSION | awk -F_ '{print $2}'`

	echo "RELEASE_YEAR=${RELEASE_YEAR} RELEASE_VERSION=${RELEASE_VERSION}"

	if [[ -d /opt/sqlite3-${RELEASE_VERSION} ]]; then
		echo "Version ${RELEASE_VERSION} is already present, not rebuilding"
		exit
	fi



	cd /usr/local/src

	# rm -fr Python-${VERSION}

	if [ ! -f "sqlite-autoconf-${RELEASE_VERSION}.tar.gz" ]; then
		curl -L -O https://www.sqlite.org/${RELEASE_YEAR}/sqlite-autoconf-${RELEASE_VERSION}.tar.gz
	fi

	tar -xf sqlite-autoconf-${RELEASE_VERSION}.tar.gz && \

	cd sqlite-autoconf-${RELEASE_VERSION}

	./configure --prefix=/opt/sqlite3-${RELEASE_VERSION}

	make

	make install

	# OK, we are installing a "list" of versions but then just doing only
	# one.   someday maybe we find a way to run against multiple sqlite
	# versions w/ LD_LIBRARY_PATH changing.
	rm -f /opt/sqlite3
	ln -s /opt/sqlite3-${RELEASE_VERSION} /opt/sqlite3
}

for version in $@; do
	install_sqlite3 ${version}
done
