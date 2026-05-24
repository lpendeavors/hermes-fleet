#!/usr/bin/env bash
set -e

BACKUP_DIR="/opt/backups/hermes"
DATA_DIR="/opt/hermes-fleet/hermes-data"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="$BACKUP_DIR/band-director_$TIMESTAMP.tar.gz"

# Create backup directory
mkdir -p "$BACKUP_DIR"

# Backup data volume
tar -czf "$BACKUP_FILE" -C "$DATA_DIR" .

# Cleanup old backups (keep 7 days)
find "$BACKUP_DIR" -name "band-director_*.tar.gz" -mtime +7 -delete

echo "Backup created: $BACKUP_FILE"
echo "Backup size: $(du -h "$BACKUP_FILE" | cut -f1)"
