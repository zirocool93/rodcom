#!/usr/bin/env bash
set -euo pipefail

REPO_URL="${REPO_URL:-https://github.com/zirocool93/rodcom.git}"
BRANCH="${BRANCH:-main}"
APP_DIR="${APP_DIR:-/opt/rodcom}"
BACKUP_BEFORE_UPDATE="${BACKUP_BEFORE_UPDATE:-true}"
ACTION="${1:-auto}"

log() {
  printf '\n[rodcom] %s\n' "$1"
}

fail() {
  printf '\n[rodcom] Ошибка: %s\n' "$1" >&2
  exit 1
}

require_root() {
  if [ "$(id -u)" -ne 0 ]; then
    fail "запустите скрипт от root или через sudo"
  fi
}

install_base_packages() {
  export DEBIAN_FRONTEND=noninteractive
  apt-get update
  apt-get install -y ca-certificates curl gnupg git lsb-release
}

install_docker() {
  if command -v docker >/dev/null 2>&1 && docker compose version >/dev/null 2>&1; then
    log "Docker и Docker Compose уже установлены."
    return
  fi

  log "Устанавливаю Docker и Docker Compose plugin."
  install_base_packages

  install -m 0755 -d /etc/apt/keyrings
  if [ ! -f /etc/apt/keyrings/docker.gpg ]; then
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    chmod a+r /etc/apt/keyrings/docker.gpg
  fi

  . /etc/os-release
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu ${VERSION_CODENAME} stable" > /etc/apt/sources.list.d/docker.list

  apt-get update
  apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
  systemctl enable --now docker
}

clone_or_update_repo() {
  if [ ! -d "$APP_DIR/.git" ]; then
    log "Клонирую RodCom из GitHub в ${APP_DIR}."
    mkdir -p "$(dirname "$APP_DIR")"
    git clone --branch "$BRANCH" "$REPO_URL" "$APP_DIR"
    return
  fi

  log "Обновляю локальный репозиторий из GitHub."
  cd "$APP_DIR"
  git remote set-url origin "$REPO_URL"
  git fetch origin "$BRANCH"
  git checkout "$BRANCH"
  git pull --ff-only origin "$BRANCH"
}

ensure_env() {
  cd "$APP_DIR"

  if [ ! -f .env ]; then
    log "Создаю .env из .env.example."
    cp .env.example .env
    chmod 600 .env
    log "Важно: перед публичным запуском замените секреты в ${APP_DIR}/.env."
  fi
}

run_backup_if_needed() {
  cd "$APP_DIR"

  if [ ! -f .env ]; then
    log ".env еще не создан, backup перед обновлением пропущен."
    return
  fi

  if [ "$BACKUP_BEFORE_UPDATE" != "true" ]; then
    log "Backup перед обновлением отключен через BACKUP_BEFORE_UPDATE=false."
    return
  fi

  if docker compose ps --services --filter "status=running" | grep -q '^postgres$'; then
    log "Создаю резервную копию перед обновлением."
    bash deploy/scripts/backup.sh
  else
    log "PostgreSQL еще не запущен, backup перед обновлением пропущен."
  fi
}

deploy_stack() {
  cd "$APP_DIR"
  mkdir -p media backups

  log "Собираю и запускаю контейнеры."
  docker compose up --build -d

  log "Применяю миграции и собираю static."
  docker compose exec -T backend python manage.py migrate
  docker compose exec -T backend python manage.py collectstatic --noinput

  log "Проверяю Django и health endpoint."
  docker compose exec -T backend python manage.py check
  curl -fsS http://localhost/api/v1/health >/dev/null
}

show_status() {
  cd "$APP_DIR"
  docker compose ps
  git --no-pager log --oneline -1
}

main() {
  require_root

  case "$ACTION" in
    auto|install|update)
      install_docker
      if [ -d "$APP_DIR/.git" ] && [ "$ACTION" != "install" ]; then
        run_backup_if_needed
      fi
      clone_or_update_repo
      ensure_env
      deploy_stack
      show_status
      log "Готово. RodCom установлен или обновлен из GitHub."
      ;;
    status)
      show_status
      ;;
    *)
      fail "неизвестная команда '${ACTION}'. Используйте: auto, install, update или status"
      ;;
  esac
}

main "$@"
