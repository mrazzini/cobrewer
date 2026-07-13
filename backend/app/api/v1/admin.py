from fastapi import APIRouter, HTTPException
from sqlalchemy import text

from app.config import settings
from app.db.models import Base
from app.db.session import engine
from scripts.seed_beans import DEFAULT_CSV, seed

router = APIRouter(prefix="/admin", tags=["admin"])


@router.get("/bootstrap")
async def bootstrap(token: str):
    """One-time setup for a fresh serverless deploy: extension + schema + seed beans.

    GET (not POST) so it can be triggered by opening a URL in a phone browser.
    Disabled unless ADMIN_BOOTSTRAP_TOKEN is set; safe to call more than once
    (create_all and the seed script are both idempotent).
    """
    if not settings.ADMIN_BOOTSTRAP_TOKEN or token != settings.ADMIN_BOOTSTRAP_TOKEN:
        raise HTTPException(status_code=403, detail="Invalid or missing bootstrap token")

    async with engine.begin() as conn:
        await conn.execute(text("CREATE EXTENSION IF NOT EXISTS unaccent"))
        await conn.run_sync(Base.metadata.create_all)

    await seed(DEFAULT_CSV)

    return {"data": {"status": "bootstrapped"}, "error": None, "meta": None}
