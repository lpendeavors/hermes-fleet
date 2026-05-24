#!/usr/bin/env bash
set -euo pipefail

BACKUP_DIR="/opt/backups/hermes"
DATA_DIR="/opt/hermes-fleet/hermes-data"
RETENTION_DAYS=7
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="$BACKUP_DIR/band-director_$TIMESTAMP.tar.gz"

# Pre-flight checks
if [[ ! -d "$DATA_DIR" ]]; then
    echo "ERROR: Data directory $DATA_DIR does not exist"
    exit 1
fi

# Check disk space (need at least 2x data size free)
DATA_SIZE=$(du -sb "$DATA_DIR" | cut -f1)
FREE_SPACE=$(df -B1 "$BACKUP_DIR" 2>/dev/null | awk 'NR==2 {print $4}')
if [[ -n "$FREE_SPACE" && "$DATA_SIZE" -gt 0 ]]; then
    if [[ "$FREE_SPACE" -lt "$((DATA_SIZE * 2))" ]]; then
        echo "WARNING: Low disk space. Backup may fail."
    fi
fi

# Create backup directory with restricted permissions
mkdir -p "$BACKUP_DIR"
chmod 700 "$BACKUP_DIR"

# Prevent concurrent runs
exec 200>"$BACKUP_DIR/.lock"
if ! flock -n 200; then
    echo "ERROR: Another backup is already running"
    exit 1
fi

# Cleanup partial files on exit
cleanup() {
    if [[ -f "$BACKUP_FILE" && ! -s "$BACKUP_FILE" ]]; then
        rm -f "$BACKUP_FILE"
    fi
}
trap cleanup EXIT ERR

# Create backup with restricted permissions
(umask 077; tar -czf "$BACKUP_FILE" -C "$DATA_DIR" .)

# Verify backup integrity
tar -tzf "$BACKUP_FILE" > /dev/null

# Cleanup old backups
find "$BACKUP_DIR" -name "band-director_*.tar.gz" -mtime +$RETENTION_DAYS -delete

BACKUP_SIZE=$(du -h "$BACKUP_FILE" | cut -f1)
echo "Backup created: $BACKUP_FILE"
echo "Backup size: $BACKUP_SIZE"
echo "Backup verified successfully"
