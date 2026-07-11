"""Shared FastAPI dependencies — Clerk JWT auth and user resolution."""

import time
from typing import Any

import httpx
from fastapi import Depends, Header, HTTPException, status
from jose import JWTError, jwt
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.config import settings
from app.db.models import User, UserAiCredits
from app.db.session import get_session

CLERK_JWKS_URL = "https://api.clerk.com/v1/jwks"
JWKS_CACHE_TTL_SECONDS = 3600

_jwks_cache: dict[str, Any] = {"keys": None, "fetched_at": 0.0}


async def _get_jwks() -> list[dict[str, Any]]:
    now = time.monotonic()
    if _jwks_cache["keys"] is None or now - _jwks_cache["fetched_at"] > JWKS_CACHE_TTL_SECONDS:
        async with httpx.AsyncClient(timeout=10) as client:
            resp = await client.get(
                CLERK_JWKS_URL,
                headers={"Authorization": f"Bearer {settings.CLERK_SECRET_KEY}"},
            )
            resp.raise_for_status()
            _jwks_cache["keys"] = resp.json()["keys"]
            _jwks_cache["fetched_at"] = now
    return _jwks_cache["keys"]


async def _verify_clerk_token(token: str) -> str:
    """Verify a Clerk session JWT and return the clerk user id (sub claim)."""
    try:
        header = jwt.get_unverified_header(token)
        keys = await _get_jwks()
        key = next((k for k in keys if k.get("kid") == header.get("kid")), None)
        if key is None:
            raise JWTError("No matching JWKS key")
        claims = jwt.decode(token, key, algorithms=[key.get("alg", "RS256")])
        return claims["sub"]
    except (JWTError, KeyError, httpx.HTTPError) as exc:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid or expired token"
        ) from exc


async def _get_or_create_user(session: AsyncSession, clerk_id: str) -> User:
    result = await session.execute(select(User).where(User.clerk_id == clerk_id))
    user = result.scalar_one_or_none()
    if user is None:
        user = User(clerk_id=clerk_id)
        session.add(user)
        await session.flush()
        session.add(UserAiCredits(user_id=user.id))
        await session.commit()
        await session.refresh(user)
    return user


async def get_current_user(
    session: AsyncSession = Depends(get_session),
    authorization: str | None = Header(None),
    x_dev_user: str | None = Header(None),
) -> User:
    """Resolve the authenticated user, creating the row on first request.

    In DEBUG mode without a Clerk key, an X-Dev-User header (or none at all)
    maps to a local dev identity so the API is usable without real auth.
    """
    if authorization and authorization.lower().startswith("bearer "):
        token = authorization.split(" ", 1)[1]
        if settings.CLERK_SECRET_KEY:
            clerk_id = await _verify_clerk_token(token)
            return await _get_or_create_user(session, clerk_id)

    if settings.DEBUG and not settings.CLERK_SECRET_KEY:
        clerk_id = f"dev_{x_dev_user or 'local'}"
        return await _get_or_create_user(session, clerk_id)

    raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Not authenticated")
