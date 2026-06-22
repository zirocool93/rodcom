#!/usr/bin/env bash
set -euo pipefail

APP_DIR="${APP_DIR:-/opt/rodcom}"
REPO_URL="${REPO_URL:-https://github.com/zirocool93/rodcom.git}"

log() {
  printf '\n[rodcom] %s\n' "$1"
}

if ! command -v docker >/dev/null 2>&1; then
  log "Устанавливаю Docker."
  apt-get update
  apt-get install -y ca-certificates curl gnupg git
  install -m 0755 -d /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
  chmod a+r /etc/apt/keyrings/docker.gpg
  . /etc/os-release
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu ${VERSION_CODENAME} stable" > /etc/apt/sources.list.d/docker.list
  apt-get update
  apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
fi

if [ ! -d "$APP_DIR/.git" ]; then
  log "Клонирую репозиторий в $APP_DIR."
  mkdir -p "$(dirname "$APP_DIR")"
  git clone "$REPO_URL" "$APP_DIR"
fi

cd "$APP_DIR"

if [ ! -f .env ]; then
  log "Создаю .env из .env.example. Перед production-запуском замените секреты."
  cp .env.example .env
fi

mkdir -p media backups

log "Собираю и запускаю контейнеры."
docker compose up --build -d

log "Применяю миграции и собираю static."
docker compose exec -T backend python manage.py migrate
docker compose exec -T backend python manage.py collectstatic --noinput

log "Проверяю health endpoint."
docker compose exec -T backend python manage.py check
curl -fsS http://localhost/api/v1/health >/dev/null

log "Установка завершена."
