#!/bin/bash

set -e

CRON_SCHEDULE=${CRON_SCHEDULE:-0 1 * * *}

if [[ "$1" == 'no-cron' ]]; then
    exec /backup.sh
else
    LOGFIFO='/var/log/cron.fifo'
    if [[ ! -e "$LOGFIFO" ]]; then
        mkfifo "$LOGFIFO"
    fi
    CRON_ENV="MONGO_PORT_27017_TCP_ADDR='$MONGO_PORT_27017_TCP_ADDR'"
    CRON_ENV="$CRON_ENV\nMONGO_PORT_27017_TCP_PORT='$MONGO_PORT_27017_TCP_PORT'"
    CRON_ENV="$CRON_ENV\nS3_ACCESS_KEY='$S3_ACCESS_KEY'"
    CRON_ENV="$CRON_ENV\nS3_SECRET_KEY='$S3_SECRET_KEY'"
    CRON_ENV="$CRON_ENV\nS3_BUCKET='$S3_BUCKET'"
    echo -e "$CRON_ENV\n$CRON_SCHEDULE /backup.sh > $LOGFIFO 2>&1" | crontab -
    crontab -l
    cron
    tail -f "$LOGFIFO"
fi
