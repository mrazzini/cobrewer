import uuid

from fastapi import APIRouter, Depends, Query
from sqlalchemy.ext.asyncio import AsyncSession

from app.db.session import get_session
from app.schemas.base import ApiResponse

router = APIRouter(prefix="/recommendations", tags=["recommendations"])


@router.get("", response_model=ApiResponse)
async def get_recommendations(
    bean_id: uuid.UUID = Query(...),
    brewer: str = Query(...),
    grinder: str | None = Query(None),
    session: AsyncSession = Depends(get_session),
) -> ApiResponse:
    # TODO: call recommendation_engine
    return ApiResponse(data=None, error="Not implemented")
