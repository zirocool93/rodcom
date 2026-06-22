from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    telegram_bot_token: str = ""
    telegram_api_base_url: str = "http://backend:8000/api/v1"
    telegram_proxy_enabled: bool = False
    telegram_proxy_type: str = "socks5"
    telegram_proxy_host: str = ""
    telegram_proxy_port: int | None = None
    telegram_proxy_username: str = ""
    telegram_proxy_password: str = ""

    model_config = SettingsConfigDict(env_file=".env", env_file_encoding="utf-8", extra="ignore")


settings = Settings()
