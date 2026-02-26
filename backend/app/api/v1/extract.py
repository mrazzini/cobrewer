from fastapi import APIRouter, Depends, UploadFile
from sqlalchemy.ext.asyncio import AsyncSession

from app.db.session import get_session
from app.schemas.base import ApiResponse

router = APIRouter(prefix="/extract", tags=["extract"])


@router.post("/bag-photo", response_model=ApiResponse)
async def extract_bag_photo(
    file: UploadFile,
    session: AsyncSession = Depends(get_session),
) -> ApiResponse:
    # TODO: validate credits, upload to R2, call OpenAI vision
    return ApiResponse(data=None, error="Not implemented")
