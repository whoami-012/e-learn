import os
from dataclasses import dataclass
from pathlib import Path
from urllib.parse import quote_plus


def _load_dotenv() -> None:
    current = Path(__file__).resolve()
    candidates = (current.parents[1] / ".env", current.parents[2] / ".env")

    for env_path in candidates:
        if not env_path.exists():
            continue

        for raw_line in env_path.read_text(encoding="utf-8").splitlines():
            line = raw_line.strip()
            if not line or line.startswith("#") or "=" not in line:
                continue

            key, value = line.split("=", 1)
            os.environ.setdefault(key.strip(), value.strip().strip("'\""))
        break


_load_dotenv()


def _default_database_url() -> str:
    database = os.getenv("DB_NAME", "elearndb")
    host = os.getenv("DB_HOST", "127.0.0.1")
    port = os.getenv("DB_PORT", "5432")
    user = os.getenv("DB_USER", "postgres")
    password = os.getenv("DB_PASSWORD", "postgres")

    auth = quote_plus(user)
    if password:
        auth = f"{auth}:{quote_plus(password)}"
    auth = f"{auth}@"

    return f"postgresql+asyncpg://{auth}{host}:{port}/{database}"


@dataclass(frozen=True)
class Settings:
    DATABASE_URL: str = os.getenv(
        "DATABASE_URL",
        _default_database_url(),
    )
    JWT_SECRET: str = os.getenv("JWT_SECRET", "your-secret-key")
    JWT_ALGORITHM: str = os.getenv("JWT_ALGORITHM", "HS256")
    ACCESS_TOKEN_EXPIRE_MINUTES: int = int(os.getenv("ACCESS_TOKEN_EXPIRE_MINUTES", "60"))   # Fix #8: cast to int
    REFRESH_TOKEN_EXPIRE_DAYS: int = int(os.getenv("REFRESH_TOKEN_EXPIRE_DAYS", "7"))        # Fix #5: new setting


settings = Settings()
