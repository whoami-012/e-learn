import app.models  # noqa: F401 — ensures all models are registered with Base.metadata
from app.db.base import Base
from app.db.session import engine


async def init_db():
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)
