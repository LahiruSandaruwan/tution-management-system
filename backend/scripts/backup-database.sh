#!/bin/bash

###############################################################################
# Database Backup Script for Tuition Management System
# Description: Automated MySQL database backup with compression and rotation
# Usage: ./backup-database.sh
# Schedule with cron: 0 2 * * * /path/to/backend/scripts/backup-database.sh
###############################################################################

# Configuration - Update these values for your environment
DB_NAME="${DB_NAME:-tuition_management}"
DB_USER="${DB_USER:-tuition_user}"
DB_PASS="${DB_PASS:-your_password}"
DB_HOST="${DB_HOST:-localhost}"

# Backup configuration
BACKUP_DIR="${BACKUP_DIR:-/var/backups/tuition-system/database}"
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="$BACKUP_DIR/backup_$DATE.sql"
DAYS_TO_KEEP=30
LOG_FILE="/var/log/tuition-backup.log"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Logging function
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# Error handling
error_exit() {
    echo -e "${RED}[ERROR] $1${NC}" | tee -a "$LOG_FILE"
    exit 1
}

# Success message
success() {
    echo -e "${GREEN}[SUCCESS] $1${NC}" | tee -a "$LOG_FILE"
}

# Warning message
warning() {
    echo -e "${YELLOW}[WARNING] $1${NC}" | tee -a "$LOG_FILE"
}

# Start backup process
log "========================================="
log "Starting database backup process"
log "========================================="

# Check if mysqldump is available
if ! command -v mysqldump &> /dev/null; then
    error_exit "mysqldump command not found. Please install MySQL client."
fi

# Create backup directory if it doesn't exist
if [ ! -d "$BACKUP_DIR" ]; then
    log "Creating backup directory: $BACKUP_DIR"
    mkdir -p "$BACKUP_DIR" || error_exit "Failed to create backup directory"
fi

# Check available disk space (require at least 1GB free)
AVAILABLE_SPACE=$(df "$BACKUP_DIR" | awk 'NR==2 {print $4}')
if [ "$AVAILABLE_SPACE" -lt 1048576 ]; then
    warning "Low disk space. Available: ${AVAILABLE_SPACE}KB"
fi

# Perform database backup
log "Backing up database: $DB_NAME"
log "Backup file: $BACKUP_FILE"

if [ -n "$DB_PASS" ]; then
    mysqldump -h"$DB_HOST" -u"$DB_USER" -p"$DB_PASS" \
        --single-transaction \
        --routines \
        --triggers \
        --events \
        "$DB_NAME" > "$BACKUP_FILE" 2>> "$LOG_FILE"
else
    mysqldump -h"$DB_HOST" -u"$DB_USER" \
        --single-transaction \
        --routines \
        --triggers \
        --events \
        "$DB_NAME" > "$BACKUP_FILE" 2>> "$LOG_FILE"
fi

# Check if backup was successful
if [ $? -eq 0 ] && [ -f "$BACKUP_FILE" ]; then
    BACKUP_SIZE=$(du -h "$BACKUP_FILE" | cut -f1)
    success "Database backup created successfully (Size: $BACKUP_SIZE)"
else
    error_exit "Database backup failed"
fi

# Compress the backup
log "Compressing backup file..."
gzip "$BACKUP_FILE" 2>> "$LOG_FILE"

if [ $? -eq 0 ]; then
    COMPRESSED_SIZE=$(du -h "$BACKUP_FILE.gz" | cut -f1)
    success "Backup compressed successfully (Size: $COMPRESSED_SIZE)"
else
    error_exit "Backup compression failed"
fi

# Calculate checksum for integrity verification
CHECKSUM=$(md5sum "$BACKUP_FILE.gz" | awk '{print $1}')
echo "$CHECKSUM" > "$BACKUP_FILE.gz.md5"
log "Checksum created: $CHECKSUM"

# Delete old backups
log "Cleaning up old backups (keeping last $DAYS_TO_KEEP days)..."
DELETED_COUNT=$(find "$BACKUP_DIR" -name "backup_*.sql.gz" -mtime +$DAYS_TO_KEEP -delete -print | wc -l)

if [ "$DELETED_COUNT" -gt 0 ]; then
    log "Deleted $DELETED_COUNT old backup(s)"
else
    log "No old backups to delete"
fi

# List recent backups
log "Recent backups:"
ls -lh "$BACKUP_DIR"/backup_*.sql.gz | tail -5 | tee -a "$LOG_FILE"

# Optional: Upload to cloud storage (uncomment to enable)
# if command -v aws &> /dev/null; then
#     log "Uploading backup to S3..."
#     aws s3 cp "$BACKUP_FILE.gz" s3://your-bucket/backups/ && \
#         success "Backup uploaded to S3" || \
#         warning "Failed to upload backup to S3"
# fi

# Backup completion
log "========================================="
success "Backup process completed successfully"
log "========================================="

exit 0
