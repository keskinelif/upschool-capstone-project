from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_file=".env", env_file_encoding="utf-8")

    app_name: str = "gri.api"
    jwt_secret: str = "change-me"
    jwt_algorithm: str = "HS256"
    access_token_ttl_minutes: int = 30
    refresh_token_ttl_minutes: int = 60 * 24 * 14
    admin_allowed_ips: str = "127.0.0.1,::1"
    pilot_areas: str = "Tunalı,Bahçelievler"


settings = Settings()
