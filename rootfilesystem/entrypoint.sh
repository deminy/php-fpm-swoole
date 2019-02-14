#!/usr/bin/env bash

set -e

if [ ! -z "$@" ] ; then
    exec $@
else
    sed -i s#"PHP_VERSION"#"$PHP_VERSION"#g /etc/supervisor/conf.d/supervisord.conf
    /usr/bin/supervisord
fi
