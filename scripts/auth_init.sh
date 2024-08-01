#!/bin/sh
set -e

. ./scripts/loadenv.sh
. ./scripts/setupvenv.sh

echo 'Running "auth_init.py"'
./.venv/bin/python ./scripts/auth_init.py --appid "$AUTH_APP_ID"
