#!/usr/bin/env bash

set -e

is_root() {
    CURRENT_USER=`whoami`

    if [ $CURRENT_USER != "root" ]; then
        echo "Not running as 'root'. Currently '${CURRENT_USER}'."
        exit 1
    fi
}

is_set() {
    if [ -z $1 ];
    then
        echo "false"
    else
        echo "true"
    fi
}

must_have() {
    TO_CHECK=$1
    ERROR_MESSAGE=$2

    ISSET=`is_set ${TO_CHECK}`

    if [ ${ISSET} == "false" ]; then
        echo $ERROR_MESSAGE
        exit 1
    fi
}
