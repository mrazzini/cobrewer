from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    # Database
    DATABASE_URL: str = "postgresql+asyncpg://postgres:postgres@localhost:5432/cobrewer"

    # Auth
    CLERK_SECRET_KEY: str = ""

    # Cloudflare R2
    CLOUDFLARE_R2_ENDPOINT: str = ""
    CLOUDFLARE_R2_ACCESS_KEY: str = ""
    CLOUDFLARE_R2_SECRET_KEY: str = ""
    CLOUDFLARE_R2_BUCKET: str = "cobrewer-uploads"

    # OpenAI
    OPENAI_API_KEY: str = ""

    # App
    DEBUG: bool = False

    model_config = {"env_file": ".env", "env_file_encoding": "utf-8"}


settings = Settings()
