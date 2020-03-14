#!/bin/bash

_exported() {
    if [[ ! $prj_exported ]]; then
        echo "Exported functionality change detected"
        export prj_exported=1
    fi
}

_general_dialects() {
    if [[ ! $prj_general_dialects ]]; then
        _exported
        echo "Misc dialects functionality change detected"
        export prj_general_dialects=1
    fi
}

_postgresql() {
    if [[ ! $prj_postgresql ]]; then
        _exported
        echo "Postgresql functionality change detected"
        export prj_postgresql=1
    fi
}

_mysql() {
    if [[ ! $prj_mysql ]]; then
        _exported
        echo "MySQL functionality change detected"
        export prj_mysql=1
    fi
}

_orm() {
    if [[ ! $prj_orm ]]; then
        _exported
        echo "ORM functionality change detected"
        export prj_orm=1
    fi
}

_tests() {
    if [[ ! $prj_tests ]]; then
        echo "test suite functionality change detected"
        export prj_tests=1
    fi
}

_doc() {
    if [[ ! $prj_doc ]]; then
        echo "documentation change detected"
        export prj_doc=1
    fi
}

_core() {
    if [[ ! $prj_core ]]; then
        _exported
        echo "Core functionality change detected"
        export prj_core=1
    fi
}

_keystone() {
    # note this isn't localized yet to just keystone in openstack.sh
    if [[ ! $prj_keystone ]]; then
        _exported
        echo "Keystone-specific functionality change detected"
        export prj_keystone=1
    fi
}

for line in $( git diff FETCH_HEAD~1..FETCH_HEAD --name-only ); do
    echo "CHECKING: ${line}"
    if [[ $line == *'sqlalchemy/dialects/postgresql'* ]]; then
        _postgresql
    elif [[ $line == *'sqlalchemy/dialects/mysql'* ]]; then
        _mysql
    elif [[ $line == *'sqlalchemy/dialects/'* ]]; then
         _general_dialects
    elif [[ $line == 'test'* ]]; then
        _tests
    elif [[ $line == *'sqlalchemy/orm'* ]]; then
        _orm
    elif [[ $line == *'sqlalchemy/ext'* ]]; then
        _orm
    elif [[ $line == *'sqlalchemy/testing'* ]]; then
        _tests
    elif [[ $line == 'alembic/ddl/postgresql.py' ]]; then
        _postgresql
    elif [[ $line == 'alembic/ddl/mysql.py' ]]; then
        _mysql
    elif [[ $line == 'alembic/testing'* ]]; then
        _tests
    elif [[ $line == *'sqlalchemy/'* ]]; then
        _core
    elif [[ $line == 'MANIFEST'* ]]; then
        _core
    elif [[ $line == 'setup'* ]]; then
        _core
    elif [[ $line == 'alembic/'* ]]; then
        _core
    elif [[ $line == 'dogpile/'* ]]; then
        _keystone
    elif [[ $line == 'doc/'* ]]; then
        _doc
    fi
done
