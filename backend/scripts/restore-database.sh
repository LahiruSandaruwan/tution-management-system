#!/bin/bash

###############################################################################
# Database Restore Script for Tuition Management System
# Description: Restore MySQL database from backup file
# Usage: ./restore-database.sh <backup-file.sql.gz>
###############################################################################

# Configuration
DB_NAME="${DB_NAME:-tuition_management}"
DB_USER="${DB_USER:-tuition_user}"
DB_PASS="${DB_PASS:-your_password}"
DB_HOST="${DB_HOST:-localhost}"
LOG_FILE="/var/log/tuition-restore.log"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Functions
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

error_exit() {
    echo -e "${RED}[ERROR] $1${NC}" | tee -a "$LOG_FILE"
    exit 1
}

success() {
    echo -e "${GREEN}[SUCCESS] $1${NC}" | tee -a "$LOG_FILE"
}

warning() {
    echo -e "${YELLOW}[WARNING] $1${NC}" | tee -a "$LOG_FILE"
}

# Check arguments
if [ -z "$1" ]; then
    echo "Usage: $0 <backup-file.sql.gz>"
    echo "Example: $0 /var/backups/tuition-system/database/backup_20251224_020000.sql.gz"
    exit 1
fi

BACKUP_FILE="$1"

# Verify backup file exists
if [ ! -f "$BACKUP_FILE" ]; then
    error_exit "Backup file not found: $BACKUP_FILE"
fi

# Verify checksum if available
if [ -f "$BACKUP_FILE.md5" ]; then
    log "Verifying backup file integrity..."
    STORED_CHECKSUM=$(cat "$BACKUP_FILE.md5")
    CURRENT_CHECKSUM=$(md5sum "$BACKUP_FILE" | awk '{print $1}')

    if [ "$STORED_CHECKSUM" == "$CURRENT_CHECKSUM" ]; then
        success "Checksum verification passed"
    else
        error_exit "Checksum verification failed. Backup file may be corrupted."
    fi
fi

# Confirmation
warning "========================================="
warning "  DATABASE RESTORE WARNING"
warning "========================================="
warning "This will REPLACE the current database:"
warning "Database: $DB_NAME"
warning "Host: $DB_HOST"
warning "Backup file: $BACKUP_FILE"
warning "========================================="
echo ""
read -p "Are you sure you want to continue? Type 'YES' to proceed: " confirm

if [ "$confirm" != "YES" ]; then
    log "Restore cancelled by user"
    exit 0
fi

# Create backup of current database before restore
log "Creating safety backup of current database..."
SAFETY_BACKUP="/tmp/pre-restore-backup-$(date +%Y%m%d_%H%M%S).sql.gz"

if [ -n "$DB_PASS" ]; then
    mysqldump -h"$DB_HOST" -u"$DB_USER" -p"$DB_PASS" \
        --single-transaction "$DB_NAME" | gzip > "$SAFETY_BACKUP" 2>> "$LOG_FILE"
else
    mysqldump -h"$DB_HOST" -u"$DB_USER" \
        --single-transaction "$DB_NAME" | gzip > "$SAFETY_BACKUP" 2>> "$LOG_FILE"
fi

if [ $? -eq 0 ]; then
    success "Safety backup created: $SAFETY_BACKUP"
else
    warning "Failed to create safety backup. Continue anyway? (yes/no)"
    read continue_anyway
    if [ "$continue_anyway" != "yes" ]; then
        exit 1
    fi
fi

# Decompress and restore
log "Starting database restore..."
log "Decompressing backup file..."

if gunzip -c "$BACKUP_FILE" | mysql -h"$DB_HOST" -u"$DB_USER" -p"$DB_PASS" "$DB_NAME" 2>> "$LOG_FILE"; then
    success "Database restored successfully from: $BACKUP_FILE"
    log "Safety backup kept at: $SAFETY_BACKUP"
    log "You can delete it manually if restore is successful"
else
    error_exit "Database restore failed. Safety backup available at: $SAFETY_BACKUP"
fi

# Verify restore
log "Verifying restore..."
TABLE_COUNT=$(mysql -h"$DB_HOST" -u"$DB_USER" -p"$DB_PASS" -N -e \
    "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema='$DB_NAME';" 2>> "$LOG_FILE")

if [ "$TABLE_COUNT" -gt 0 ]; then
    success "Restore verification passed. Found $TABLE_COUNT tables."
else
    error_exit "Restore verification failed. Database may be empty."
fi

log "========================================="
success "Restore process completed successfully"
log "========================================="

exit 0
