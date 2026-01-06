# Encrypted Database Backups Guide

**Implementation Date:** 2026-01-06
**Status:** ✅ COMPLETED
**Security Level:** High Priority

---

## Overview

The Encrypted Database Backups feature provides GPG-encrypted backups of your MySQL database. This ensures that backup files are protected from unauthorized access, even if storage media is compromised.

**Key Benefits:**
- 🔒 **End-to-End Encryption** - Backups encrypted with GPG (AES256)
- 🛡️ **Data Protection** - Secure even if backup storage is breached
- 🔑 **Key or Passphrase** - Supports both asymmetric and symmetric encryption
- 📦 **Compression** - Gzip compression before encryption
- 🧹 **Auto Cleanup** - Automatic deletion of old backups (30-day retention)
- ✅ **Integrity Checks** - MD5 and SHA256 checksums for verification

---

## Quick Start

### Prerequisites

1. **Install GPG** (if not already installed):

```bash
# Ubuntu/Debian
sudo apt-get install gnupg

# Alpine Linux (Docker)
apk add gnupg

# macOS
brew install gnupg
```

2. **Set Environment Variables** in `.env`:

```env
# For symmetric encryption (passphrase-based)
BACKUP_GPG_PASSPHRASE=your-very-strong-passphrase-here

# For asymmetric encryption (key-based)
BACKUP_GPG_RECIPIENT=backup@tuitionms.com
```

### Create Encrypted Backup

```bash
# From project root
./scripts/backup-database-encrypted.sh
```

### Restore from Encrypted Backup

```bash
# List available backups
ls -lh /backups/database/*.gpg

# Restore specific backup
./scripts/restore-database-encrypted.sh /backups/database/backup_20260106_154230.sql.gz.gpg
```

---

## Encryption Methods

### Method 1: Symmetric Encryption (Recommended for Simple Setups)

**How it works:**
- Uses a passphrase to encrypt/decrypt
- Same passphrase encrypts and decrypts
- No GPG key management required

**Setup:**

1. Generate a strong passphrase:
```bash
# Generate random 32-character passphrase
openssl rand -base64 32
```

2. Add to `.env`:
```env
BACKUP_GPG_PASSPHRASE="K8x2Pq9Lm3Nv7Zt5Wb4Yr6Ua1Cd8Ef0Gh=="
```

3. Run backup:
```bash
./scripts/backup-database-encrypted.sh
```

**Advantages:**
✅ Simple setup
✅ No key management
✅ Works immediately

**Disadvantages:**
❌ Same passphrase for all backups
❌ Passphrase must be securely stored

---

### Method 2: Asymmetric Encryption (Recommended for Production)

**How it works:**
- Uses GPG public/private key pair
- Public key encrypts backups
- Private key decrypts backups
- More secure key rotation

**Setup:**

1. **Generate GPG Key Pair:**

```bash
gpg --full-generate-key
```

Follow prompts:
- Key type: `(1) RSA and RSA`
- Key size: `4096`
- Expiration: `0 = key does not expire`
- Name: `Tuition MS Backup`
- Email: `backup@tuitionms.com`
- Passphrase: Set a strong passphrase

2. **Export Public Key (for encryption):**

```bash
gpg --export --armor backup@tuitionms.com > backup-public-key.asc
```

3. **Export Private Key (for decryption - KEEP SECURE!):**

```bash
gpg --export-secret-keys --armor backup@tuitionms.com > backup-private-key.asc
chmod 600 backup-private-key.asc
```

4. **Import Keys on Backup Server:**

```bash
# Import public key (for creating backups)
gpg --import backup-public-key.asc

# Import private key (for restoring backups)
gpg --import backup-private-key.asc
```

5. **Set Recipient in `.env`:**

```env
BACKUP_GPG_RECIPIENT=backup@tuitionms.com
```

6. **Run Backup:**

```bash
./scripts/backup-database-encrypted.sh
```

**Advantages:**
✅ Separate encryption and decryption keys
✅ Can distribute public key safely
✅ Better for team environments
✅ Supports key rotation

**Disadvantages:**
❌ More complex setup
❌ Requires key management

---

## Backup Script Features

### Automated Backup Process

The `backup-database-encrypted.sh` script performs these steps automatically:

1. **Database Dump**
   - Creates complete MySQL dump
   - Includes routines, triggers, events
   - Uses single-transaction for consistency
   - Compresses with gzip

2. **GPG Encryption**
   - Encrypts compressed dump
   - Uses AES256 cipher
   - Generates `.sql.gz.gpg` file

3. **Secure Deletion**
   - Shreds unencrypted backup (3-pass overwrite)
   - Only encrypted file remains

4. **File Permissions**
   - Sets restrictive `600` permissions
   - Only owner can read/write

5. **Manifest Generation**
   - Creates backup metadata
   - Includes MD5 and SHA256 checksums
   - Records timestamp, size, database name

6. **Cleanup**
   - Deletes backups older than 30 days
   - Maintains retention policy

---

## Restoration Process

### Prerequisites for Restoration

- GPG private key (asymmetric) or passphrase (symmetric)
- MySQL credentials
- Target database (can be different from source)

### Step-by-Step Restoration

1. **List Available Backups:**

```bash
ls -lh /backups/database/*.gpg
```

Output:
```
-rw------- 1 root root 1.2M Jan 06 15:42 backup_20260106_154230.sql.gz.gpg
-rw------- 1 root root 1.1M Jan 06 09:15 backup_20260106_091542.sql.gz.gpg
```

2. **Choose Backup to Restore:**

```bash
# Most recent backup
LATEST_BACKUP=$(ls -t /backups/database/*.gpg | head -1)

# Or specific backup
BACKUP_FILE="/backups/database/backup_20260106_154230.sql.gz.gpg"
```

3. **Run Restoration:**

```bash
./scripts/restore-database-encrypted.sh "$BACKUP_FILE"
```

4. **Confirm Restoration:**

The script will prompt:
```
⚠️  WARNING: This will REPLACE all data in the database 'tuition_db'!
⚠️  All existing data will be PERMANENTLY DELETED!

Are you sure you want to continue? Type 'yes' to proceed:
```

Type `yes` and press Enter.

5. **Verify Success:**

```bash
# Check table count
mysql -u root -p -e "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema='tuition_db';"

# Check sample data
mysql -u root -p tuition_db -e "SELECT COUNT(*) FROM students;"
```

---

## Scheduled Backups

### Docker Compose Integration

Add backup service to `docker-compose.yml`:

```yaml
services:
  backup:
    image: mysql:8.0
    container_name: tuition-backup
    volumes:
      - ./scripts:/scripts
      - backup-data:/backups
    environment:
      - MYSQL_HOST=mysql
      - MYSQL_USER=${DB_USERNAME}
      - MYSQL_PASSWORD=${DB_PASSWORD}
      - MYSQL_DATABASE=${DB_DATABASE}
      - BACKUP_GPG_PASSPHRASE=${BACKUP_GPG_PASSPHRASE}
    command: >
      sh -c "apk add --no-cache gnupg bash &&
             while true; do
               /scripts/backup-database-encrypted.sh;
               sleep 21600;
             done"
    depends_on:
      - mysql
    networks:
      - tuition-network

volumes:
  backup-data:
```

**Backup Frequency:** Every 6 hours (21600 seconds)

### Cron Job Setup (Alternative)

For servers without Docker:

```bash
# Edit crontab
crontab -e

# Add backup job (runs at 2 AM daily)
0 2 * * * /path/to/scripts/backup-database-encrypted.sh >> /var/log/backup.log 2>&1

# Add cleanup job (runs weekly)
0 3 * * 0 find /backups/database -name "*.gpg" -mtime +30 -delete
```

---

## Security Best Practices

### ✅ DO:

1. **Store Passphrases Securely**
   - Use environment variables
   - Never commit to version control
   - Use secrets management (Vault, AWS Secrets Manager)

2. **Protect Private Keys**
   - Set `600` permissions
   - Store in secure location
   - Backup keys separately from data
   - Consider hardware security modules (HSM)

3. **Verify Backups Regularly**
   - Test restoration quarterly
   - Verify checksums
   - Monitor backup logs

4. **Rotate Keys**
   - Rotate GPG keys annually
   - Re-encrypt old backups with new keys
   - Document key rotation procedure

5. **Monitor Backup Health**
   - Alert on backup failures
   - Track backup sizes
   - Monitor retention compliance

### ❌ DON'T:

1. **Never Store Keys in Version Control**
   - Add `*.asc` to `.gitignore`
   - Use `.env` for passphrases
   - Keep keys separate from backups

2. **Never Use Weak Passphrases**
   - Minimum 20 characters
   - Use password generator
   - Avoid dictionary words

3. **Never Skip Backup Testing**
   - Untested backups are useless
   - Test restoration process
   - Verify data integrity

---

## Troubleshooting

### Issue: "GPG is not installed"

**Solution:**
```bash
# Install GPG
sudo apt-get install gnupg  # Ubuntu/Debian
apk add gnupg               # Alpine
brew install gnupg          # macOS
```

### Issue: "Decryption failed"

**Possible Causes:**
1. Wrong passphrase
2. Missing GPG private key
3. Corrupted backup file

**Solutions:**
```bash
# Test decryption manually
gpg --decrypt /backups/database/backup_*.gpg > test.sql.gz

# Check GPG keys
gpg --list-keys
gpg --list-secret-keys

# Verify backup integrity
md5sum /backups/database/backup_*.gpg
```

### Issue: "Permission denied"

**Solution:**
```bash
# Fix script permissions
chmod +x scripts/backup-database-encrypted.sh
chmod +x scripts/restore-database-encrypted.sh

# Fix backup directory permissions
chmod 755 /backups/database
chmod 600 /backups/database/*.gpg
```

### Issue: "Backup file too large"

**Cause:** Database has grown significantly

**Solutions:**
1. **Increase backup retention:**
   ```bash
   # In backup script, change:
   RETENTION_DAYS=15  # Reduce from 30
   ```

2. **Compress better:**
   ```bash
   # Use higher compression
   gzip -9 > "$BACKUP_FILE"
   ```

3. **Incremental backups:**
   - Consider implementing binary log backups
   - Use `mysqldump --single-transaction --flush-logs`

---

## Monitoring & Alerts

### Backup Success Monitoring

Create monitoring script:

```bash
#!/bin/bash
# Check if backup was created today

BACKUP_DIR="/backups/database"
TODAY=$(date +%Y%m%d)

if ls ${BACKUP_DIR}/backup_${TODAY}*.gpg 1> /dev/null 2>&1; then
    echo "✅ Backup exists for today"
    exit 0
else
    echo "❌ No backup found for today!"
    # Send alert (email, Slack, etc.)
    exit 1
fi
```

### Backup Size Monitoring

```bash
#!/bin/bash
# Alert if backup size is unusual

BACKUP_DIR="/backups/database"
LATEST_BACKUP=$(ls -t ${BACKUP_DIR}/*.gpg | head -1)
LATEST_SIZE=$(stat -f%z "$LATEST_BACKUP")
AVERAGE_SIZE=$(find ${BACKUP_DIR} -name "*.gpg" -exec stat -f%z {} \; | awk '{sum+=$1} END {print sum/NR}')

# Alert if latest backup is 50% smaller than average
THRESHOLD=$(echo "$AVERAGE_SIZE * 0.5" | bc)

if [ "$LATEST_SIZE" -lt "$THRESHOLD" ]; then
    echo "⚠️  Warning: Latest backup unusually small!"
    echo "Latest: $(numfmt --to=iec $LATEST_SIZE)"
    echo "Average: $(numfmt --to=iec $AVERAGE_SIZE)"
fi
```

---

## Disaster Recovery

### Complete System Recovery

1. **Set up new server**
2. **Install dependencies:**
   ```bash
   apt-get update
   apt-get install mysql-server gnupg
   ```

3. **Import GPG private key:**
   ```bash
   gpg --import backup-private-key.asc
   ```

4. **Copy latest backup:**
   ```bash
   scp user@backup-server:/backups/database/backup_latest.gpg .
   ```

5. **Restore database:**
   ```bash
   ./scripts/restore-database-encrypted.sh backup_latest.gpg
   ```

6. **Verify restoration:**
   ```bash
   mysql -u root -p tuition_db -e "SHOW TABLES;"
   ```

---

## Compliance & Regulations

### GDPR Compliance

✅ **Article 32 (Security of Processing):**
- Encrypted backups meet "state of the art" security requirements
- Protection against unauthorized access
- Pseudonymization through encryption

### PCI DSS Compliance

✅ **Requirement 3.4:**
- Render PAN unreadable (encryption at rest)
- Strong cryptography (AES256)

### HIPAA Compliance

✅ **164.312(a)(2)(iv):**
- Encryption of ePHI at rest
- Addressable implementation specification

---

## Key Management Policy

### Key Storage

| Key Type | Location | Permissions | Backup |
|----------|----------|-------------|--------|
| Public Key | `/etc/gpg/backup-public.asc` | `644` | Yes (multiple locations) |
| Private Key | `/etc/gpg/backup-private.asc` | `600` | Yes (secure vault) |
| Passphrase | Environment variable | N/A | Yes (secrets manager) |

### Key Rotation Schedule

- **Quarterly Review** - Check key health
- **Annual Rotation** - Generate new key pair
- **Migration Period** - 30 days with both keys active
- **Old Key Archival** - Store securely for old backups

---

## Performance Considerations

### Backup Duration

| Database Size | Backup Time | Encrypted Size |
|---------------|-------------|----------------|
| 100 MB | ~5 seconds | ~25 MB |
| 1 GB | ~45 seconds | ~250 MB |
| 10 GB | ~7 minutes | ~2.5 GB |
| 100 GB | ~70 minutes | ~25 GB |

### Optimization Tips

1. **Run backups during low-traffic periods**
2. **Use `--single-transaction` for InnoDB**
3. **Exclude logs and temporary tables**
4. **Use faster compression (gzip -1) if needed**
5. **Consider incremental backups for large databases**

---

## Conclusion

Encrypted database backups are a critical security measure that protects your data from unauthorized access. By following this guide, you can ensure your backups are secure, recoverable, and compliant with industry standards.

**Next Steps:**
1. ✅ Set up encryption (symmetric or asymmetric)
2. ✅ Test backup creation
3. ✅ Test restoration process
4. ✅ Schedule automated backups
5. ✅ Implement monitoring
6. ✅ Document key management procedures

---

**Version:** 1.0.0
**Last Updated:** 2026-01-06
**Maintainer:** Development Team
**Contact:** support@tuitionms.com
