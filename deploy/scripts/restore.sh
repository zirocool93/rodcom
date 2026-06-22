#!/usr/bin/env bash
set -euo pipefail

APP_DIR="${APP_DIR:-/opt/rodcom}"
BACKUP_ARCHIVE="${1:-}"

if [ -z "$BACKUP_ARCHIVE" ] || [ ! -f "$BACKUP_ARCHIVE" ]; then
  echo "Укажите путь к backup tar.gz: bash deploy/scripts/restore.sh /backups/rodcom-YYYYmmdd-HHMMSS.tar.gz" >&2
  exit 1
fi

cd "$APP_DIR"
if [ -f .env ]; then
  set -a
  # shellcheck disable=SC1091
  . ./.env
  set +a
fi

RESTORE_DIR="$(mktemp -d)"
trap 'rm -rf "$RESTORE_DIR"' EXIT

tar -xzf "$BACKUP_ARCHIVE" -C "$RESTORE_DIR"
INNER_DIR="$(find "$RESTORE_DIR" -mindepth 1 -maxdepth 1 -type d | head -n 1)"

docker compose up -d postgres
docker compose exec -T postgres dropdb -U "${POSTGRES_USER:-rodcom}" --if-exists "${POSTGRES_DB:-rodcom}"
docker compose exec -T postgres createdb -U "${POSTGRES_USER:-rodcom}" "${POSTGRES_DB:-rodcom}"
docker compose exec -T postgres psql -U "${POSTGRES_USER:-rodcom}" -d "${POSTGRES_DB:-rodcom}" < "${INNER_DIR}/postgres.sql"

if [ -f "${INNER_DIR}/media.tar.gz" ]; then
  docker run --rm -v rodcom_media_data:/data -v "${INNER_DIR}:/backup" alpine sh -c "rm -rf /data/* && tar -xzf /backup/media.tar.gz -C /data"
fi

docker compose up -d
curl -fsS http://localhost/api/v1/health >/dev/null

echo "Восстановление завершено."
