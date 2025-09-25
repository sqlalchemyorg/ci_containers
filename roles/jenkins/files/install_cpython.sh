#!/bin/bash

set -x
set -e

function install_python() {

    RAWVERSION=$1

    # search and grep out "optimize"; an "o" at the end
    # of the version
    OPTIMIZE=`echo ${RAWVERSION} | sed -n 's/.*o$/o/p'`
    VERSION=`echo ${RAWVERSION} | sed 's/o$//'`

    # search and grep out "threaded"; a "t" at the end
    # of the version
    THREADED=`echo ${VERSION} | sed -n 's/.*t$/t/p'`
    DLVERSION=`echo ${VERSION} | sed 's/t$//'`

    REALLY_SIMPLE_NUMBER=`echo ${VERSION} | awk -F. '{ print $1"."$2 }'`
    SIMPLE_NUMBER="${REALLY_SIMPLE_NUMBER}${THREADED}"
    NODOTS_SIMPLE_NUMBER=`echo ${VERSION} | awk -F. '{ print $1$2 }'`
    MAJOR_VERSION=`echo ${VERSION} | awk -F. '{ print $1 }'`
    NON_BETA_VERSION=`echo ${VERSION} | sed -r 's/([0-9\.]+).*?/\1/'`

    cd /usr/local/src

    echo "VERSION=${VERSION} SIMPLE_NUMBER=${SIMPLE_NUMBER} MAJOR_VERSION=${MAJOR_VERSION} NON_BETA_VERSION=${NON_BETA_VERSION} OPTIMIZE=${OPTIMIZE} THREADED=${THREADED}"

    if [[ -d /opt/python-${VERSION} ]]; then
        echo "Version ${VERSION} is already present, not rebuilding"
        return
    fi

    # *try* to actually get the get-pip for this python version, since the
    # generic get-pip stops working as soon as a version is EOL
    # however, they dont put the per-version one up until it's EOL.
    # so --fail means it wont write a file if it's 404
    curl --fail -L https://bootstrap.pypa.io/pip/${REALLY_SIMPLE_NUMBER}/get-pip.py  -o get-pip-${NODOTS_SIMPLE_NUMBER}.py || true

    if [[ -f get-pip-${NODOTS_SIMPLE_NUMBER}.py ]]; then
        GET_PIP=get-pip-${NODOTS_SIMPLE_NUMBER}.py
    else
        curl -L -O https://bootstrap.pypa.io/get-pip.py
        GET_PIP="get-pip.py"
    fi

    if [[ "${MAJOR_VERSION}" == 3 ]]; then
        PYTHON_INTERP_NAME="python3"
        PIP_NAME="pip3"

        if [[ "${OPTIMIZE}" != "" ]]; then
            CONFIGURE_ARGS="--enable-optimizations"
        else
            CONFIGURE_ARGS="--with-lto"
        fi
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

    if [[ "${THREADED}" != "" ]]; then
        CONFIGURE_ARGS="${CONFIGURE_ARGS} --disable-gil"
    fi

    # rm -fr Python-${VERSION}

    if [ ! -f "Python-${DLVERSION}.tar.xz" ]; then
        curl -L -O https://www.python.org/ftp/python/${NON_BETA_VERSION}/Python-${DLVERSION}.tar.xz
    fi

    if [ ! -d "/opt/python-${RAWVERSION}" ]; then

        # untar to folder matching the build we're going to do
        mkdir -p "./Python-${RAWVERSION}"
        tar -xf Python-${DLVERSION}.tar.xz -C "./Python-${RAWVERSION}" --strip-components=1
        cd Python-${RAWVERSION}
        ./configure --prefix /opt/python-${VERSION} ${CONFIGURE_ARGS}
        make
        make install

        rm -f /opt/python${SIMPLE_NUMBER}
        ln -s /opt/python-${VERSION} /opt/python${SIMPLE_NUMBER}
    fi

    /opt/python${SIMPLE_NUMBER}/bin/${PYTHON_INTERP_NAME} /usr/local/src/${GET_PIP}

    /opt/python${SIMPLE_NUMBER}/bin/${PIP_NAME} install pip tox coverage flake8-junit-report --upgrade
}

for python_version in $@; do
    install_python ${python_version}
done
