"""Cloudflare R2 (S3-compatible) storage service."""

import asyncio
from functools import lru_cache

import boto3

from app.config import settings


@lru_cache(maxsize=1)
def _client():
    return boto3.client(
        "s3",
        endpoint_url=settings.CLOUDFLARE_R2_ENDPOINT,
        aws_access_key_id=settings.CLOUDFLARE_R2_ACCESS_KEY,
        aws_secret_access_key=settings.CLOUDFLARE_R2_SECRET_KEY,
        region_name="auto",
    )


def is_configured() -> bool:
    return bool(settings.CLOUDFLARE_R2_ENDPOINT and settings.CLOUDFLARE_R2_ACCESS_KEY)


async def upload_file(file_bytes: bytes, key: str, content_type: str) -> str:
    """Upload bytes to R2 and return the object key. boto3 is sync, so run in a thread."""
    await asyncio.to_thread(
        _client().put_object,
        Bucket=settings.CLOUDFLARE_R2_BUCKET,
        Key=key,
        Body=file_bytes,
        ContentType=content_type,
    )
    return key


async def presigned_url(key: str, expires_seconds: int = 3600) -> str:
    """Generate a presigned GET URL so private bucket objects can be read."""
    return await asyncio.to_thread(
        _client().generate_presigned_url,
        "get_object",
        Params={"Bucket": settings.CLOUDFLARE_R2_BUCKET, "Key": key},
        ExpiresIn=expires_seconds,
    )
