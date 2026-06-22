from aiogram.client.session.aiohttp import AiohttpSession

from services.config import settings


def build_session() -> AiohttpSession:
    if not settings.telegram_proxy_enabled:
        return AiohttpSession()

    if not settings.telegram_proxy_host or not settings.telegram_proxy_port:
        raise RuntimeError("SOCKS5 proxy включен, но TELEGRAM_PROXY_HOST или TELEGRAM_PROXY_PORT не заданы.")

    auth = ""
    if settings.telegram_proxy_username:
        auth = settings.telegram_proxy_username
        if settings.telegram_proxy_password:
            auth = f"{auth}:{settings.telegram_proxy_password}"
        auth = f"{auth}@"

    proxy_url = f"{settings.telegram_proxy_type}://{auth}{settings.telegram_proxy_host}:{settings.telegram_proxy_port}"
    return AiohttpSession(proxy=proxy_url)
