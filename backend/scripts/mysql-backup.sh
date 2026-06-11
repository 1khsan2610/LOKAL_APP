#!/bin/bash

# MySQL Automatic Backup Script
# Backs up MySQL database automatically at 02:00 AM WIB
# Retention: 30 days (SRS Bab 6)
# Location: /app/storage/backups/mysql/

BACKUP_DIR="/app/storage/backups/mysql"
DB_HOST="${DB_HOST:-127.0.0.1}"
DB_PORT="${DB_PORT:-3306}"
DB_NAME="${DB_DATABASE:-lokal_app}"
DB_USER="${DB_USERNAME:-root}"
DB_PASSWORD="${DB_PASSWORD:-}"
RETENTION_DAYS=30
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="$BACKUP_DIR/${DB_NAME}_backup_${TIMESTAMP}.sql.gz"
LOG_FILE="/app/storage/logs/mysql-backup.log"

# Create backup directory if not exists
mkdir -p "$BACKUP_DIR"

# Function to log messages
log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

log_message "Starting MySQL backup..."

# Check if DB_PASSWORD is set
if [ -z "$DB_PASSWORD" ]; then
    # No password
    mysqldump \
        -h "$DB_HOST" \
        -P "$DB_PORT" \
        -u "$DB_USER" \
        --single-transaction \
        --quick \
        --lock-tables=false \
        "$DB_NAME" 2>> "$LOG_FILE" | gzip > "$BACKUP_FILE"
else
    # With password
    mysqldump \
        -h "$DB_HOST" \
        -P "$DB_PORT" \
        -u "$DB_USER" \
        -p"$DB_PASSWORD" \
        --single-transaction \
        --quick \
        --lock-tables=false \
        "$DB_NAME" 2>> "$LOG_FILE" | gzip > "$BACKUP_FILE"
fi

# Check backup status
if [ $? -eq 0 ]; then
    BACKUP_SIZE=$(du -h "$BACKUP_FILE" | cut -f1)
    log_message "✓ Backup completed successfully - Size: $BACKUP_SIZE - File: $BACKUP_FILE"
else
    log_message "✗ Backup failed!"
    exit 1
fi

# Clean up old backups (older than 30 days)
log_message "Cleaning up old backups (retention: $RETENTION_DAYS days)..."
find "$BACKUP_DIR" -name "${DB_NAME}_backup_*.sql.gz" -mtime +$RETENTION_DAYS -delete

# Count remaining backups
BACKUP_COUNT=$(ls -1 "$BACKUP_DIR"/${DB_NAME}_backup_*.sql.gz 2>/dev/null | wc -l)
log_message "Backup cleanup completed - Remaining backups: $BACKUP_COUNT"

log_message "MySQL backup script finished."
