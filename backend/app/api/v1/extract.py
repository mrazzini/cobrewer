import uuid

from fastapi import APIRouter, Depends, HTTPException, UploadFile, status
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.api.deps import get_current_user
from app.db.models import User, UserAiCredits
from app.db.session import get_session
from app.schemas.base import ApiResponse
from app.services import extraction_service, storage_service

router = APIRouter(prefix="/extract", tags=["extract"])

MAX_UPLOAD_BYTES = 10 * 1024 * 1024
ALLOWED_CONTENT_TYPES = {"image/jpeg", "image/png", "image/webp", "image/heic"}


@router.post("/bag-photo", response_model=ApiResponse)
async def extract_bag_photo(
    file: UploadFile,
    session: AsyncSession = Depends(get_session),
    user: User = Depends(get_current_user),
) -> ApiResponse:
    if file.content_type not in ALLOWED_CONTENT_TYPES:
        raise HTTPException(
            status_code=status.HTTP_415_UNSUPPORTED_MEDIA_TYPE,
            detail="Upload a JPEG, PNG, WebP or HEIC image",
        )
    if not extraction_service.is_configured():
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="AI extraction is not configured on this server",
        )

    credits = await session.scalar(select(UserAiCredits).where(UserAiCredits.user_id == user.id))
    if credits is None:
        credits = UserAiCredits(user_id=user.id)
        session.add(credits)
        await session.flush()
    if credits.extractions_used >= credits.extractions_limit:
        raise HTTPException(
            status_code=status.HTTP_402_PAYMENT_REQUIRED,
            detail="Free extraction limit reached",
        )

    image_bytes = await file.read()
    if len(image_bytes) > MAX_UPLOAD_BYTES:
        raise HTTPException(
            status_code=status.HTTP_413_REQUEST_ENTITY_TOO_LARGE,
            detail="Image must be under 10MB",
        )

    photo_key: str | None = None
    if storage_service.is_configured():
        photo_key = f"bag-photos/{user.id}/{uuid.uuid4()}"
        await storage_service.upload_file(image_bytes, photo_key, file.content_type or "image/jpeg")

    try:
        extraction = await extraction_service.extract_from_image(
            image_bytes, file.content_type or "image/jpeg"
        )
    except Exception as exc:  # noqa: BLE001 — credit must not be burned on provider failure
        raise HTTPException(
            status_code=status.HTTP_502_BAD_GATEWAY,
            detail=f"Extraction failed: {exc}",
        ) from exc

    credits.extractions_used += 1
    await session.commit()

    return ApiResponse(
        data=extraction.model_dump(),
        meta={
            "photo_key": photo_key,
            "extractions_used": credits.extractions_used,
            "extractions_limit": credits.extractions_limit,
        },
    )
