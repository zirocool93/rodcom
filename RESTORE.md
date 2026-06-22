# Восстановление из резервной копии

## Что содержит backup

Архив создается скриптом `deploy/scripts/backup.sh` и включает:

- дамп PostgreSQL;
- архив `media`;
- копии `.env`, `docker-compose.yml`, `deploy/nginx/nginx.conf`;
- файл `backup-info.json` с датой, именем БД и версией коммита.

## Команда восстановления

```bash
cd /opt/rodcom
bash deploy/scripts/restore.sh /backups/rodcom-YYYYmmdd-HHMMSS.tar.gz
```

## После восстановления

```bash
docker compose ps
curl http://localhost/api/v1/health
curl http://localhost/api/v1/health/db
```

Если проверка не прошла, посмотрите журналы:

```bash
docker compose logs --tail=200 backend
docker compose logs --tail=200 postgres
```
