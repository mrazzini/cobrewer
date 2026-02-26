import uuid

from fastapi import APIRouter, Depends, Query
from sqlalchemy.ext.asyncio import AsyncSession

from app.db.session import get_session
from app.schemas.base import ApiResponse
from app.schemas.brews import BrewLogCreate

router = APIRouter(prefix="/brews", tags=["brews"])


@router.post("", response_model=ApiResponse)
async def create_brew(
    payload: BrewLogCreate,
    session: AsyncSession = Depends(get_session),
) -> ApiResponse:
    # TODO: implement
    return ApiResponse(data=None, error="Not implemented")


@router.get("", response_model=ApiResponse)
async def list_brews(
    user_id: uuid.UUID | None = Query(None),
    session: AsyncSession = Depends(get_session),
) -> ApiResponse:
    # TODO: implement
    return ApiResponse(data=[])
