#!/bin/bash

GITHUB_GIT_BASE=https://github.com/sqlalchemy/
OPENSTACK_GIT_BASE=https://opendev.org/openstack/
X_GIT_BASE=https://opendev.org/x/
GERRIT_BASE=https://gerrit.sqlalchemy.org/sqlalchemy/

SCRIPT_BASE=/usr/local/jenkins/scripts
HERE=`dirname $( readlink -f $0 )`
# SCRIPT_BASE="${HERE}"

UPPER_CONSTRAINTS=https://git.openstack.org/cgit/openstack/requirements/plain/upper-constraints.txt

PATCHES=${SCRIPT_BASE}/openstack_patches

# may be useful for reference
# https://git.openstack.org/cgit/openstack/requirements/plain/global-requirements.txt

db_urls ()
{
    if [[ ! $GERRIT || $prj_mysql || $prj_core || $prj_keystone ]]; then
        MYSQL=";mysql+pymysql://openstack_citest:openstack_citest@mariadb103/openstack_citest?charset=utf8"
    fi

    if [[ ! $GERRIT || $prj_postgresql || $prj_core ]]; then
        POSTGRESQL=";postgresql+psycopg2://openstack_citest:openstack_citest@pg94/openstack_citest"
    fi

    # TODO: template these
    export OS_TEST_DBAPI_ADMIN_CONNECTION="sqlite://${MYSQL}${POSTGRESQL}"

    export TOX_TESTENV_PASSENV="OS_TEST_DBAPI_ADMIN_CONNECTION ${TOX_TESTENV_PASSENV}"
}

prerequisites ()
{
    if [[ ! $WORKSPACE ]]; then
        echo "WORKSPACE not defined"
        exit -1
    fi
    # note: don't use $PYTHON !! tox or someone uses this.
    # b00m!
    if [[ ! $PYTHON_INTERP ]]; then
        echo "PYTHON_INTERP not defined"
        exit -1
    fi
    unset PYTHON
    PYTHON_BIN_DIR=`dirname $PYTHON_INTERP`

    if [[ ! $SQLALCHEMY_TAG ]]; then
        SQLALCHEMY_TAG=master
    fi

    if [[ ! $TOX ]]; then
        TOX=${PYTHON_BIN_DIR}/tox
    fi

    if [[ ! $PROJECTS ]]; then
        PROJECTS="oslo.db keystone nova neutron"
    fi

    PACKAGES=${WORKSPACE}/packages

}

setup ()
{
    cd $WORKSPACE
    if [[ ! -d ${PACKAGES} ]]; then
        mkdir ${PACKAGES}
    fi

    export UPPER_CONSTRAINTS_FILE=${WORKSPACE}/upper_constraints.txt
    export TOX_TESTENV_PASSENV="UPPER_CONSTRAINTS_FILE ${TOX_TESTENV_PASSENV}"

    curl --retry 3 "$UPPER_CONSTRAINTS" -L --insecure --progress-bar --output ${UPPER_CONSTRAINTS_FILE}

    for keyword in SQLAlchemy alembic dogpile.cache oslo.db oslo.cache sqlalchemy-migrate ; do
        sed -i.tmp "s/^${keyword}.*//" ${UPPER_CONSTRAINTS_FILE};
    done

}

upstream_deps() {

    # set up sqlalchemy/alembic/dogpile for specific versions/checkouts and
    # replace them into downloaded requirements

    # https://stackoverflow.com/questions/16577386/what-environment-variables-are-passed-go-jenkins-when-using-the-gerrit-trigger-p

    if [[ "${GERRIT_PROJECT}" == "sqlalchemy/sqlalchemy" ]]; then
        prepare_gerrit_dependency SQLAlchemy sqlalchemy
    else
        prepare_github_dependency SQLAlchemy sqlalchemy ${SQLALCHEMY_TAG}
    fi

    if [[ "${GERRIT_PROJECT}" == "sqlalchemy/alembic" ]]; then
        prepare_gerrit_dependency alembic alembic
    else
        prepare_github_dependency alembic alembic master
    fi

    if [[ "${GERRIT_PROJECT}" == "sqlalchemy/dogpile.cache" ]]; then
        prepare_gerrit_dependency dogpile.cache dogpile.cache
    else
        prepare_github_dependency dogpile.cache dogpile.cache master
    fi

    prepare_repaired_oslo_cache

    prepare_sqlalchemy_migrate
}

prepare_github_dependency ()
{

    PACKAGE=$1
    GIT_NAME=$2
    VERSION=$3

    echo "git+${GITHUB_GIT_BASE}${GIT_NAME}.git@${VERSION}#egg=${PACKAGE}" >> ${UPPER_CONSTRAINTS_FILE}
}


prepare_sqlalchemy_migrate()
{
    PACKAGE=sqlalchemy-migrate
    GIT_NAME=sqlalchemy-migrate

    cd ${WORKSPACE}

    if [[ ! -d ${GIT_NAME} ]]; then
        git clone ${X_GIT_BASE}sqlalchemy-migrate
    fi
    cd ${GIT_NAME}
    git remote set-url origin ${X_GIT_BASE}sqlalchemy-migrate
    git reset --hard origin/master
    git pull

    # has to be a git install.  so we have to commit the file.  whatevs.

    git config user.email "jenkins@sqlalchemy.org"
    git config user.name "Jenkins SQLAlchemy"

    for patchfile in `ls ${PATCHES}/${PACKAGE}_*.patch`
    do
        patch -p1 < ${patchfile}
    done

    # note this won't work if the patch adds new files
    git commit -a --allow-empty -m "apply patches"

    echo "git+file://${WORKSPACE}/${GIT_NAME}@master#egg=${PACKAGE}" >> ${UPPER_CONSTRAINTS_FILE}

}

prepare_repaired_oslo_cache()
{
    PACKAGE=oslo.cache
    GIT_NAME=oslo.cache

    cd ${WORKSPACE}

    if [[ ! -d ${GIT_NAME} ]]; then
        git clone ${OPENSTACK_GIT_BASE}oslo.cache
    fi
    cd ${GIT_NAME}
    git remote set-url origin ${OPENSTACK_GIT_BASE}oslo.cache
    git reset --hard origin/master
    git pull
    sed -i.tmp "s/^dogpile.cache.*/dogpile.cache/" requirements.txt

    # has to be a git install.  so we have to commit the file.  whatevs.

    git config user.email "jenkins@sqlalchemy.org"
    git config user.name "Jenkins SQLAlchemy"

    git commit -m "unblock dogpile.cache" requirements.txt

    echo "git+file://${WORKSPACE}/${GIT_NAME}@master#egg=${PACKAGE}" >> ${UPPER_CONSTRAINTS_FILE}

}

prepare_gerrit_dependency()
{
    PACKAGE=$1
    GIT_NAME=$2

    cd ${WORKSPACE}

    if [[ ! -d ${GIT_NAME} ]]; then
        git clone ${GITHUB_GIT_BASE}${GIT_NAME}.git
    fi

    cd ${GIT_NAME}
    git fetch ${GERRIT_BASE}${GIT_NAME} ${GERRIT_REFSPEC}
    git checkout FETCH_HEAD
    GERRIT=1

    source ${SCRIPT_BASE}/categorize_gerrit_changes.sh

    # TODO: project-specific, e.g. prj_keystone only
    if [[ ! $prj_exported ]] ; then
        echo "No exported functionality paths found for refspec ${GERRIT_REFSPEC}; skipping tests"
        for proj in $PROJECTS; do
            write_blank_junit $proj
        done
        exit
    fi

    # we can't use file:// because oslo.db is using some thing called edit_constraints
    # on the upper_constraints.txt which is buggy and blows away the URL.  hide
    # behind "git+"
    echo "git+file://${WORKSPACE}/${GIT_NAME}@${GERRIT_PATCHSET_REVISION}#egg=${PACKAGE}" >> ${UPPER_CONSTRAINTS_FILE}
}

write_blank_junit ()
{
    PROJECT=$1
    BLANKXML='<?xml version="1.0" encoding="utf-8"?><testsuite errors="0" failures="0" name="pytest" skips="0" tests="0" time="0"></testsuite>'
    echo "writing empty junit file ${WORKSPACE}/junit-${PROJECT}-.xml"
    echo $BLANKXML > ${WORKSPACE}/junit-${PROJECT}-.xml

}

prepare_openstack_project ()
{
    cd ${WORKSPACE}
    PROJECT=$1
    if [[ -d ${PROJECT} ]]; then
        cd ${PROJECT}
        git reset --hard
        git remote set-url origin ${OPENSTACK_GIT_BASE}${PROJECT}.git
        git pull origin master
    else
        git clone ${OPENSTACK_GIT_BASE}${PROJECT}.git
        cd ${PROJECT}
    fi

    for patchfile in `ls ${PATCHES}/${PROJECT}_*.patch`
    do
        patch -p1 < ${patchfile}
    done

}

run_project ()
{

    PROJECT=$1
    TARGET=$2
    cd ${WORKSPACE}/${PROJECT}

    export OS_TEST_TIMEOUT

    # most openstacks wont honor this...
    export TOX_TESTENV_PASSENV="OS_TEST_TIMEOUT ${TOX_TESTENV_PASSENV}"

    # manually change the file for now
    sed -i.tmp "s/OS_TEST_TIMEOUT=.*/OS_TEST_TIMEOUT=${OS_TEST_TIMEOUT}/" tox.ini

    # we need the -r here at the very least to ensure we get the
    # latest SQLAlchemy / alembic / dogpile, as the verison number will not
    # have changed across commits within the same upcoming version
    PATH=${PYTHON_BIN_DIR}:$PATH ${TOX}  -v -r -e ${TARGET} -- $3 $4 $5 $6 $7
    TEST_EXIT=$?
}


gen_junit_results() {
    PROJECT=$1
    TARGET=$2
    QUALIFIER=$3
    cd ${WORKSPACE}/${PROJECT}

    if [ -d .testrepository ]; then
        TESTR=testr
    elif [ -d .stestr ]; then
        TESTR=stestr
    else
        echo "No .testrepository or .stestr directory found"
        exit -1
    fi

    .tox/${TARGET}/bin/pip install junitxml
    .tox/${TARGET}/bin/${TESTR} last --subunit | .tox/${TARGET}/bin/subunit2junitxml > ${WORKSPACE}/junit-${PROJECT}-${QUALIFIER}.xml

}

handle_exit() {
    if [ $TEST_EXIT != 0 ]; then
        exit ${TEST_EXIT}
    fi
}

run_projects() {
    # awesome testr notes:
    # http://haypo-notes.readthedocs.io/openstack.html#testr

    for proj in $PROJECTS; do
        if [ "${proj}" = "oslo.db" ]; then
            prepare_openstack_project oslo.db
            OS_TEST_TIMEOUT=0
            run_project oslo.db py37
            gen_junit_results oslo.db py37
            handle_exit

        elif [ "${proj}" = "keystone" ]; then
            prepare_openstack_project keystone
            OS_TEST_TIMEOUT=600
            find ${WORKSPACE}/keystone/keystone/tests/ -path "*/tmp/*" -type d -exec rm -fr {} \;
            run_project keystone py37 'keystone.tests.unit.*sql.*'
            gen_junit_results keystone py37
            handle_exit

        elif [ "${proj}" = "nova" ]; then
            prepare_openstack_project nova
            OS_TEST_TIMEOUT=400
            run_project nova py37 'nova.tests.unit.db'
            gen_junit_results nova py37
            handle_exit

        elif [ "${proj}" = "neutron" ]; then
            prepare_openstack_project neutron
            OS_TEST_TIMEOUT=0
            run_project neutron py37 ".*\.unit\.db\."
            gen_junit_results neutron py37 unit
            handle_exit

            # NOTE: the "functional" suite sets the test path to
            # neutron/tests/functional.  without this, neutron/tests/unit is
            # imported, specifically neutron/tests/unit/quota/__init__.py and
            # neutron/tests/unit/objects/test_rbac_db.py, bogus model classes
            # that create tables fakerbacmodels, othermehmodels, mehmodels are
            # run causing test_models_sync to fail

            export TOX_TESTENV_PASSENV="OS_LOG_PATH ${TOX_TESTENV_PASSENV}"
            export OS_LOG_PATH="${WORKSPACE}/_test_logs"

            echo "blowing away other neutron plugin tests which we can't "
            echo "prevent from being imported even though we're not running "
            echo "them and they include all kinds of deep assumptions about "
            echo "software we don't want to install that can't be overridden"
            rm -fr ${WORKSPACE}/neutron/neutron/tests/functional/plugins/

            run_project neutron functional ".*\.functional\.db\..*migrations"

            gen_junit_results neutron functional
            handle_exit

        else
            echo "no such project '${proj}'"
            exit -1
        fi
    done
}

set -e
set -x

prerequisites
setup
upstream_deps
db_urls

set +e

run_projects
