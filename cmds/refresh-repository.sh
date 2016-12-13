#!/usr/bin/env bash

# -------------------------------------------------------
# Clone / Pull vpn-init repo
# -------------------------------------------------------
# If repo exists then performs a pull to update to latest revision. Otherwise, performs a clone.

set -e

REPOSITORY_PATH="/tmp/vpn-init"

# Does the repository already exist on the filesystem?
if [ -d ${REPOSITORY_PATH} ]; then
    REPOSITORY_EXISTS="true"
else
    REPOSITORY_EXISTS="false"
fi

# If not, then perform a clone.
if [ ${REPOSITORY_EXISTS} = "false" ]; then
    apt-get install -y git
    git clone https://github.com/aaronheath/vpn-init.git ${REPOSITORY_PATH}
    cd ${REPOSITORY_PATH}
    git checkout server-init-bug
fi

# If so, then just perform a pull.
if [ ${REPOSITORY_EXISTS} = "true" ]; then
    cd ${REPOSITORY_PATH}
    git pull
fi
