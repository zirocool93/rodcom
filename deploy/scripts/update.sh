#!/usr/bin/env bash
set -euo pipefail

APP_DIR="${APP_DIR:-/opt/rodcom}"

log() {
  printf '\n[rodcom] %s\n' "$1"
}

cd "$APP_DIR"

log "Создаю резервную копию перед обновлением."
bash deploy/scripts/backup.sh || log "Backup не выполнен, продолжаю обновление только если это ожидаемо."

log "Получаю свежие изменения."
git pull --ff-only

log "Пересобираю и перезапускаю сервисы."
docker compose up --build -d

log "Применяю миграции и собираю static."
docker compose exec -T backend python manage.py migrate
docker compose exec -T backend python manage.py collectstatic --noinput

log "Проверяю health endpoint."
curl -fsS http://localhost/api/v1/health >/dev/null

log "Обновление завершено."
