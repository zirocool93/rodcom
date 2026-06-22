#!/usr/bin/env bash
set -euo pipefail

APP_DIR="${APP_DIR:-/opt/rodcom}"
BACKUP_DIR="${BACKUP_DIR:-/backups}"
RETENTION_DAYS="${BACKUP_RETENTION_DAYS:-14}"
TIMESTAMP="$(date +%Y%m%d-%H%M%S)"
WORK_DIR="${BACKUP_DIR}/rodcom-${TIMESTAMP}"
ARCHIVE="${BACKUP_DIR}/rodcom-${TIMESTAMP}.tar.gz"

cd "$APP_DIR"
mkdir -p "$WORK_DIR"

if [ -f .env ]; then
  set -a
  # shellcheck disable=SC1091
  . ./.env
  set +a
fi

docker compose exec -T postgres pg_dump -U "${POSTGRES_USER:-rodcom}" -d "${POSTGRES_DB:-rodcom}" > "${WORK_DIR}/postgres.sql"

if docker volume inspect rodcom_media_data >/dev/null 2>&1; then
  docker run --rm -v rodcom_media_data:/data -v "${WORK_DIR}:/backup" alpine tar -czf /backup/media.tar.gz -C /data .
else
  tar -czf "${WORK_DIR}/media.tar.gz" -C "$APP_DIR" media 2>/dev/null || true
fi

cp .env "${WORK_DIR}/.env" 2>/dev/null || true
cp docker-compose.yml "${WORK_DIR}/docker-compose.yml"
cp deploy/nginx/nginx.conf "${WORK_DIR}/nginx.conf"

cat > "${WORK_DIR}/backup-info.json" <<INFO
{
  "created_at": "${TIMESTAMP}",
  "database": "${POSTGRES_DB:-rodcom}",
  "git_commit": "$(git rev-parse --short HEAD 2>/dev/null || echo unknown)"
}
INFO

tar -czf "$ARCHIVE" -C "$BACKUP_DIR" "rodcom-${TIMESTAMP}"
rm -rf "$WORK_DIR"
find "$BACKUP_DIR" -name 'rodcom-*.tar.gz' -mtime "+${RETENTION_DAYS}" -delete

printf '%s\n' "$ARCHIVE"
