#!/bin/bash

# generic gerrit checkout script to run on jenkins

# after many years of fighting with the jenkins git plugin and how it
# interacts with gerrit, performing slow queries, hanging, being very
# difficult to configure, demanding constant SSH key format changes, and just
# being completely opaque, I realized that a lot of our jobs just do the
# git checkout right in the script, using local ssh keys.   totally simple.
# let's just do that.

set -x

export GERRIT_BASE=https://gerrit.sqlalchemy.org/

if [[ ! -d ${GERRIT_PROJECT} ]]; then
    git clone ${GERRIT_BASE}${GERRIT_PROJECT}.git ${GERRIT_PROJECT}
fi

cd ${GERRIT_PROJECT}

echo $(date) : ${GERRIT_REFSPEC} >> GERRIT_BUILD_LOG.txt

git fetch --prune ${GERRIT_BASE}${GERRIT_PROJECT} ${GERRIT_REFSPEC}

# wave a chicken at weird "HEAD.lock file exists issue"
git reset --hard || true

# still waving....
sleep 2

# success!
git reset --hard

git checkout FETCH_HEAD

