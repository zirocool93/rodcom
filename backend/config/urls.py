from django.contrib import admin
from django.db import connections
from django.db.utils import OperationalError
from django.urls import path
from rest_framework.decorators import api_view
from rest_framework.response import Response
import redis
from django.conf import settings


def api_response(data: dict, errors: list | None = None, status: int = 200) -> Response:
    return Response({"data": data, "meta": {}, "errors": errors or []}, status=status)


@api_view(["GET"])
def health(_request):
    return api_response({"status": "ok", "service": "rodcom-backend"})


@api_view(["GET"])
def health_db(_request):
    try:
        connections["default"].cursor()
    except OperationalError as exc:
        return api_response({}, [{"code": "db_unavailable", "message": str(exc)}], status=503)
    return api_response({"status": "ok"})


@api_view(["GET"])
def health_redis(_request):
    try:
        client = redis.Redis.from_url(settings.REDIS_URL, socket_connect_timeout=2)
        client.ping()
    except redis.RedisError as exc:
        return api_response({}, [{"code": "redis_unavailable", "message": str(exc)}], status=503)
    return api_response({"status": "ok"})


urlpatterns = [
    path("admin/", admin.site.urls),
    path("api/v1/health", health),
    path("api/v1/health/db", health_db),
    path("api/v1/health/redis", health_redis),
]
