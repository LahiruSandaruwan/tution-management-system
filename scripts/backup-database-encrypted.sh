#!/bin/bash
# Encrypted Database Backup Script
# Creates compressed and GPG-encrypted MySQL dumps with timestamp
# Security: Backups are encrypted using GPG for data protection

set -e

# Configuration
BACKUP_DIR="/backups/database"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="${BACKUP_DIR}/backup_${TIMESTAMP}.sql.gz"
ENCRYPTED_FILE="${BACKUP_FILE}.gpg"
RETENTION_DAYS=30
GPG_RECIPIENT="${BACKUP_GPG_RECIPIENT:-backup@tuitionms.com}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
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

# Check if GPG is installed
if ! command -v gpg &> /dev/null; then
    log_error "GPG is not installed! Please install GPG to use encrypted backups."
    log_info "On Ubuntu/Debian: sudo apt-get install gnupg"
    log_info "On Alpine: apk add gnupg"
    exit 1
fi

# Create backup directory if it doesn't exist
mkdir -p "$BACKUP_DIR"

log_info "Starting encrypted database backup..."
log_info "Timestamp: $TIMESTAMP"
log_info "GPG Recipient: $GPG_RECIPIENT"

# Step 1: Create database dump and compress
log_info "Creating database dump..."
mysqldump \
    -h"${MYSQL_HOST}" \
    -u"${MYSQL_USER}" \
    -p"${MYSQL_PASSWORD}" \
    "${MYSQL_DATABASE}" \
    --single-transaction \
    --quick \
    --lock-tables=false \
    --routines \
    --triggers \
    --events \
    --add-drop-database \
    --add-drop-table \
    | gzip > "$BACKUP_FILE"

# Verify unencrypted backup was created
if [ ! -f "$BACKUP_FILE" ]; then
    log_error "Database dump file was not created!"
    exit 1
fi

UNENCRYPTED_SIZE=$(du -h "$BACKUP_FILE" | cut -f1)
log_info "Unencrypted backup created: $UNENCRYPTED_SIZE"

# Step 2: Encrypt the backup with GPG
log_info "Encrypting backup with GPG..."

# Check if GPG key exists for recipient
if gpg --list-keys "$GPG_RECIPIENT" &> /dev/null; then
    # Encrypt using existing GPG key
    gpg --encrypt \
        --recipient "$GPG_RECIPIENT" \
        --trust-model always \
        --output "$ENCRYPTED_FILE" \
        "$BACKUP_FILE"
else
    log_warning "GPG key for '$GPG_RECIPIENT' not found. Using symmetric encryption with passphrase."

    # Fallback to symmetric encryption if no GPG key exists
    if [ -z "$BACKUP_GPG_PASSPHRASE" ]; then
        log_error "BACKUP_GPG_PASSPHRASE environment variable not set!"
        log_error "Set it in your .env file or export it before running this script."
        rm -f "$BACKUP_FILE"
        exit 1
    fi

    # Symmetric encryption with passphrase
    echo "$BACKUP_GPG_PASSPHRASE" | gpg \
        --batch \
        --yes \
        --passphrase-fd 0 \
        --symmetric \
        --cipher-algo AES256 \
        --output "$ENCRYPTED_FILE" \
        "$BACKUP_FILE"
fi

# Verify encrypted backup was created
if [ ! -f "$ENCRYPTED_FILE" ]; then
    log_error "Encrypted backup file was not created!"
    rm -f "$BACKUP_FILE"
    exit 1
fi

ENCRYPTED_SIZE=$(du -h "$ENCRYPTED_FILE" | cut -f1)
log_info "Encrypted backup created: $ENCRYPTED_SIZE"

# Step 3: Securely delete unencrypted backup
log_info "Securely deleting unencrypted backup..."
if command -v shred &> /dev/null; then
    # Use shred for secure deletion (overwrites file before deletion)
    shred -vfz -n 3 "$BACKUP_FILE"
else
    # Fallback to regular deletion if shred not available
    rm -f "$BACKUP_FILE"
    log_warning "shred not available, used regular deletion"
fi

# Step 4: Set restrictive permissions on encrypted backup
chmod 600 "$ENCRYPTED_FILE"
log_info "Set restrictive permissions (600) on encrypted backup"

# Step 5: Clean up old encrypted backups (keep last 30 days)
log_info "Cleaning up backups older than $RETENTION_DAYS days..."
DELETED_COUNT=$(find "$BACKUP_DIR" -name "backup_*.sql.gz.gpg" -type f -mtime +$RETENTION_DAYS -print -delete | wc -l)
if [ "$DELETED_COUNT" -gt 0 ]; then
    log_info "Deleted $DELETED_COUNT old encrypted backup(s)"
else
    log_info "No old backups to delete"
fi

# Step 6: Generate backup manifest
MANIFEST_FILE="${BACKUP_DIR}/backup_manifest.txt"
{
    echo "Backup Manifest"
    echo "==============="
    echo "Timestamp: $(date)"
    echo "Backup File: $(basename $ENCRYPTED_FILE)"
    echo "Size: $ENCRYPTED_SIZE"
    echo "Database: $MYSQL_DATABASE"
    echo "Encryption: GPG (${GPG_RECIPIENT:-Symmetric AES256})"
    echo "MD5 Checksum: $(md5sum "$ENCRYPTED_FILE" | cut -d' ' -f1)"
    echo "SHA256 Checksum: $(sha256sum "$ENCRYPTED_FILE" | cut -d' ' -f1)"
} > "$MANIFEST_FILE"

log_info "Backup manifest created: $MANIFEST_FILE"

# Step 7: List recent backups
log_info "Recent encrypted backups:"
ls -lh "$BACKUP_DIR"/*.gpg 2>/dev/null | tail -5 || log_warning "No previous backups found"

# Step 8: Display backup statistics
TOTAL_BACKUPS=$(find "$BACKUP_DIR" -name "backup_*.sql.gz.gpg" -type f | wc -l)
TOTAL_SIZE=$(du -sh "$BACKUP_DIR" | cut -f1)

echo ""
log_info "=== Backup Statistics ==="
log_info "Total encrypted backups: $TOTAL_BACKUPS"
log_info "Total backup size: $TOTAL_SIZE"
log_info "Retention period: $RETENTION_DAYS days"
echo ""

log_info "✅ Encrypted database backup completed successfully!"
log_info "Encrypted file: $ENCRYPTED_FILE"

# Exit successfully
exit 0
