#!/bin/bash

set -x
set -e

function install_python() {

	VERSION=$1
	SIMPLE_NUMBER=`echo ${VERSION} | awk -F. '{ print $1"."$2 }'`
	MAJOR_VERSION=`echo ${VERSION} | awk -F. '{ print $1 }'`
	NON_BETA_VERSION=`echo ${VERSION} | sed -r 's/([0-9\.]+).*?/\1/'`

	echo "VERSION=${VERSION} SIMPLE_NUMBER=${SIMPLE_NUMBER} MAJOR_VERSION=${MAJOR_VERSION} NON_BETA_VERSION=${NON_BETA_VERSION}"

	if [[ -d /opt/python-${VERSION} ]]; then
		echo "Version ${VERSION} is already present, not rebuilding"
		return
	fi


	if [[ "${MAJOR_VERSION}" == 3 ]]; then
		PYTHON_INTERP_NAME="python3"
		PIP_NAME="pip3"
		CONFIGURE_ARGS=""
	else
		PYTHON_INTERP_NAME="python"
		PIP_NAME="pip"

		# pylibmc has wheel files
		# the one for 2.7 is manylinux-mu only
		# set ucs4 so that an "mu" wheel can install,
		# see https://github.com/pypa/manylinux
		# centos8 has no libmemcached-devel, but there's
		# no pylibmc wheel for python 3.8 anyway so we are
		# still having to build libmemcached to get the header files
		CONFIGURE_ARGS="--enable-unicode=ucs4"
	fi

	cd /usr/local/src

	# rm -fr Python-${VERSION}

	if [ ! -f "Python-${VERSION}.tar.xz" ]; then
		curl -L -O https://www.python.org/ftp/python/${NON_BETA_VERSION}/Python-${VERSION}.tar.xz
	fi

	if [ ! -d "/opt/python-${VERSION}" ]; then
		ls -la
		tar -xf Python-${VERSION}.tar.xz
		cd Python-${VERSION}
		./configure --prefix /opt/python-${VERSION} ${CONFIGURE_ARGS}
		make
		make install

		rm -f /opt/python${SIMPLE_NUMBER}
		ln -s /opt/python-${VERSION} /opt/python${SIMPLE_NUMBER}
	fi

	/opt/python${SIMPLE_NUMBER}/bin/${PYTHON_INTERP_NAME} /usr/local/src/get-pip.py


	/opt/python${SIMPLE_NUMBER}/bin/${PIP_NAME} install pip tox coverage flake8-junit-report --upgrade
}

for python_version in $@; do
	install_python ${python_version}
done
