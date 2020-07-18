#!/bin/bash

set -ex

sudo systemctl stop redis
sudo cp /tmp/dump.rdb /var/lib/redis/dump.rdb
sudo systemctl start redis
