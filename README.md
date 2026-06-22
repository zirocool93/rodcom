# RodCom

RodCom - self-hosted PWA-сервис для родительского комитета: учет добровольных сборов, платежей, расходов, чеков, отчетов и уведомлений через Telegram-бота.

## Стек

- Backend: Django + Django REST Framework
- Frontend: Vue 3 + Vite + TypeScript + PWA
- База данных: PostgreSQL 17
- Очереди: Redis + Celery + Celery Beat
- Telegram Bot: aiogram 3 с поддержкой SOCKS5 proxy
- Deploy: Docker Compose на Ubuntu 24.04 LXC в Proxmox
- Reverse proxy: Nginx

## Быстрый запуск на сервере

```bash
git clone https://github.com/zirocool93/rodcom.git /opt/rodcom
cd /opt/rodcom
cp .env.example .env
nano .env
bash deploy/scripts/install.sh
```

После запуска приложение будет доступно через Nginx на порту `80`.

## Автоматическая установка или обновление с GitHub

На чистом Ubuntu 24.04 сервере можно запустить один standalone-скрипт:

```bash
curl -fsSL https://raw.githubusercontent.com/zirocool93/rodcom/main/deploy/scripts/server.sh | sudo bash
```

Повторный запуск этой же команды обновит проект из ветки `main`, пересоберет контейнеры, применит миграции и проверит `/api/v1/health`.

Дополнительные варианты:

```bash
# Установить или обновить в другой каталог
curl -fsSL https://raw.githubusercontent.com/zirocool93/rodcom/main/deploy/scripts/server.sh | sudo env APP_DIR=/srv/rodcom bash

# Обновить без backup перед обновлением
curl -fsSL https://raw.githubusercontent.com/zirocool93/rodcom/main/deploy/scripts/server.sh | sudo env BACKUP_BEFORE_UPDATE=false bash -s -- update

# Показать состояние сервисов
sudo APP_DIR=/opt/rodcom bash /opt/rodcom/deploy/scripts/server.sh status
```

## Локальный запуск через Docker Compose

```bash
cp .env.example .env
docker compose up --build -d
docker compose exec backend python manage.py migrate
docker compose exec backend python manage.py createsuperuser
```

Проверка:

```bash
curl http://localhost/api/v1/health
curl http://localhost/api/v1/health/db
curl http://localhost/api/v1/health/redis
```

## Обновление

```bash
cd /opt/rodcom
bash deploy/scripts/update.sh
```

Скрипт делает резервную копию перед обновлением, подтягивает код, пересобирает контейнеры, применяет миграции и проверяет health endpoint.

## Резервное копирование

```bash
bash deploy/scripts/backup.sh
```

Архивы сохраняются в `BACKUP_DIR`, по умолчанию `/backups`.

## Восстановление

```bash
bash deploy/scripts/restore.sh /backups/rodcom-YYYYmmdd-HHMMSS.tar.gz
```

Подробная инструкция находится в [RESTORE.md](RESTORE.md).

## Текущее состояние

Готов MVP-скелет: структура backend/frontend/bot, Docker Compose, Nginx, health endpoints, PWA-оболочка, Telegram bot-заготовка, скрипты установки, обновления, backup и restore.

Следующий этап: реализовать модели БД, миграции, API для цепочки «Класс -> Семьи -> Сбор -> Начисления -> Платеж -> Подтверждение -> Расход -> Баланс -> Отчет».
