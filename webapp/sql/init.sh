#!/bin/bash
set -xe
set -o pipefail

sudo systemctl stop redis
sudo cp /tmp/dump.rdb /var/lib/redis/dump.rdb
sudo systemctl start redis

CURRENT_DIR=$(cd $(dirname $0);pwd)
export MYSQL_HOST=${MYSQL_HOST:-isucon9-3}
export MYSQL_PORT=${MYSQL_PORT:-3306}
export MYSQL_USER=${MYSQL_USER:-isucari}
export MYSQL_DBNAME=${MYSQL_DBNAME:-isucari}
export MYSQL_PWD=${MYSQL_PASS:-isucari}
export LANG="C.UTF-8"
cd $CURRENT_DIR

cat 01_schema.sql 02_categories.sql initial.sql custom.sql | mysql --defaults-file=/dev/null -h $MYSQL_HOST -P $MYSQL_PORT -u $MYSQL_USER $MYSQL_DBNAME
