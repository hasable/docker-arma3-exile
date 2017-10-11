#!/bin/bash
set -e
/opt/confd/bin/confd -onetime -backend env
exec "$@"
