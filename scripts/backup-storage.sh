#!/bin/sh
# Storage backup script
# Creates compressed archives of application storage

set -e

STORAGE_DIR="/var/www/storage"
BACKUP_DIR="/backups/storage"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="${BACKUP_DIR}/storage_${TIMESTAMP}.tar.gz"
RETENTION_DAYS=30

# Create backup directory if it doesn't exist
mkdir -p "$BACKUP_DIR"

echo "Starting storage backup..."

# Create compressed archive of storage directory
# Excludes logs and cache to reduce backup size
tar -czf "$BACKUP_FILE" \
    --exclude='storage/logs/*' \
    --exclude='storage/framework/cache/*' \
    --exclude='storage/framework/sessions/*' \
    -C /var/www storage/

# Verify backup was created
if [ -f "$BACKUP_FILE" ]; then
    SIZE=$(du -h "$BACKUP_FILE" | cut -f1)
    echo "Storage backup created successfully: $BACKUP_FILE ($SIZE)"
else
    echo "ERROR: Storage backup file was not created!"
    exit 1
fi

# Clean up old backups (keep last 30 days)
echo "Cleaning up storage backups older than $RETENTION_DAYS days..."
find "$BACKUP_DIR" -name "storage_*.tar.gz" -type f -mtime +$RETENTION_DAYS -delete

# List recent backups
echo "Recent storage backups:"
ls -lh "$BACKUP_DIR" | tail -5

echo "Storage backup completed successfully!"
