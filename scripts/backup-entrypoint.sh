#!/bin/sh
# Backup service entrypoint script
# Runs automated backups on schedule

set -e

echo "Starting backup service..."

# Wait for database to be ready
echo "Waiting for database to be ready..."
while ! mysqladmin ping -h"$MYSQL_HOST" --silent; do
    sleep 1
done

echo "Database is ready. Starting scheduled backups..."

# Run backup every 6 hours
while true; do
    echo "Running backup at $(date)"
    /scripts/backup-database.sh
    /scripts/backup-storage.sh

    echo "Backup completed. Next backup in 6 hours..."
    sleep 21600  # 6 hours
done
