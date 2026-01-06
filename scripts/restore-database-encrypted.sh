#!/bin/bash
# Encrypted Database Restoration Script
# Restores MySQL database from GPG-encrypted backup file

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to log messages
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_question() {
    echo -e "${BLUE}[QUESTION]${NC} $1"
}

# Check if GPG is installed
if ! command -v gpg &> /dev/null; then
    log_error "GPG is not installed! Please install GPG to decrypt backups."
    exit 1
fi

# Check if backup file is provided
if [ -z "$1" ]; then
    log_error "Usage: $0 <encrypted_backup_file.sql.gz.gpg>"
    log_info "Example: $0 /backups/database/backup_20260106_154230.sql.gz.gpg"
    echo ""
    log_info "Available backups:"
    find /backups/database -name "backup_*.sql.gz.gpg" -type f -exec ls -lh {} \; 2>/dev/null | tail -10
    exit 1
fi

ENCRYPTED_BACKUP_FILE="$1"

# Verify encrypted backup file exists
if [ ! -f "$ENCRYPTED_BACKUP_FILE" ]; then
    log_error "Encrypted backup file not found: $ENCRYPTED_BACKUP_FILE"
    exit 1
fi

log_info "=== Encrypted Database Restoration ==="
log_info "Encrypted Backup File: $ENCRYPTED_BACKUP_FILE"
log_info "Target Database: ${MYSQL_DATABASE}"
log_info "Target Host: ${MYSQL_HOST}"

# Warning about data loss
echo ""
log_warning "⚠️  WARNING: This will REPLACE all data in the database '${MYSQL_DATABASE}'!"
log_warning "⚠️  All existing data will be PERMANENTLY DELETED!"
echo ""

# Confirmation prompt
read -p "$(echo -e ${BLUE}[QUESTION]${NC}) Are you sure you want to continue? Type 'yes' to proceed: " CONFIRMATION

if [ "$CONFIRMATION" != "yes" ]; then
    log_info "Restoration cancelled by user."
    exit 0
fi

# Create temporary directory for decryption
TEMP_DIR=$(mktemp -d)
DECRYPTED_FILE="${TEMP_DIR}/decrypted_backup.sql.gz"

cleanup() {
    log_info "Cleaning up temporary files..."
    if [ -f "$DECRYPTED_FILE" ]; then
        shred -vfz -n 3 "$DECRYPTED_FILE" 2>/dev/null || rm -f "$DECRYPTED_FILE"
    fi
    rm -rf "$TEMP_DIR"
}

# Trap to ensure cleanup on exit
trap cleanup EXIT

log_info "Decrypting backup file..."

# Try to decrypt (works for both asymmetric and symmetric encryption)
if echo "$BACKUP_GPG_PASSPHRASE" | gpg \
    --batch \
    --yes \
    --passphrase-fd 0 \
    --decrypt \
    --output "$DECRYPTED_FILE" \
    "$ENCRYPTED_BACKUP_FILE" 2>/dev/null; then
    log_info "✅ Decrypted using passphrase"
elif gpg --decrypt --output "$DECRYPTED_FILE" "$ENCRYPTED_BACKUP_FILE" 2>/dev/null; then
    log_info "✅ Decrypted using GPG key"
else
    log_error "Failed to decrypt backup file!"
    log_error "Make sure you have the correct GPG key or passphrase."
    exit 1
fi

# Verify decrypted file was created
if [ ! -f "$DECRYPTED_FILE" ]; then
    log_error "Decryption failed - output file not created!"
    exit 1
fi

DECRYPTED_SIZE=$(du -h "$DECRYPTED_FILE" | cut -f1)
log_info "Decrypted backup size: $DECRYPTED_SIZE"

# Restore database
log_info "Restoring database from backup..."

# Drop existing database and recreate (if needed)
mysql -h"${MYSQL_HOST}" -u"${MYSQL_USER}" -p"${MYSQL_PASSWORD}" -e "DROP DATABASE IF EXISTS ${MYSQL_DATABASE}; CREATE DATABASE ${MYSQL_DATABASE};" 2>/dev/null || true

# Restore from backup
gunzip < "$DECRYPTED_FILE" | mysql \
    -h"${MYSQL_HOST}" \
    -u"${MYSQL_USER}" \
    -p"${MYSQL_PASSWORD}" \
    "${MYSQL_DATABASE}"

# Verify restoration
TABLE_COUNT=$(mysql \
    -h"${MYSQL_HOST}" \
    -u"${MYSQL_USER}" \
    -p"${MYSQL_PASSWORD}" \
    -N -B \
    -e "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema='${MYSQL_DATABASE}'" \
    2>/dev/null)

if [ "$TABLE_COUNT" -gt 0 ]; then
    log_info "✅ Database restored successfully!"
    log_info "Total tables restored: $TABLE_COUNT"
else
    log_error "Database restoration may have failed - no tables found!"
    exit 1
fi

# Show restoration summary
echo ""
log_info "=== Restoration Summary ==="
log_info "Source: $(basename $ENCRYPTED_BACKUP_FILE)"
log_info "Database: ${MYSQL_DATABASE}"
log_info "Tables: $TABLE_COUNT"
log_info "Restoration completed at: $(date)"
echo ""

log_info "✅ Encrypted database restoration completed successfully!"

exit 0
