#!/bin/bash

# File Storage Backup Script for Tuition Management System
# Backs up profile photos and other uploaded files
# Usage: ./backup-storage.sh
# Makes script executable: chmod +x backup-storage.sh

set -e

# Configuration
STORAGE_DIR="${1:-./../storage/app/public}"
BACKUP_DIR="${2:-/var/backups/tuition-system/storage}"
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="$BACKUP_DIR/storage_backup_$DATE.tar.gz"
DAYS_TO_KEEP="${3:-30}"

# Create backup directory if it doesn't exist
mkdir -p "$BACKUP_DIR"

# Create compressed archive
echo "Starting storage backup at $(date)..."
echo "Backing up from: $STORAGE_DIR"

if [ ! -d "$STORAGE_DIR" ]; then
    echo "ERROR: Storage directory not found: $STORAGE_DIR"
        exit 1
        fi

        tar -czf "$BACKUP_FILE" "$STORAGE_DIR"

        if [ $? -eq 0 ]; then
            echo "Storage backup completed successfully: $BACKUP_FILE"
                echo "Backup size: $(du -h "$BACKUP_FILE" | cut -f1)"
                else
                    echo "ERROR: Backup failed"
                        exit 1
                        fi

                        # Delete old backups
                        echo "Cleaning up old backups (keeping last $DAYS_TO_KEEP days)..."
                        find "$BACKUP_DIR" -name "storage_backup_*.tar.gz" -mtime +"$DAYS_TO_KEEP" -delete

                        echo "Backup process completed at $(date)"
