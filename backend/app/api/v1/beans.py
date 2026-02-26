import uuid

from fastapi import APIRouter, Depends, Query
from sqlalchemy.ext.asyncio import AsyncSession

from app.db.session import get_session
from app.schemas.base import ApiResponse
from app.schemas.beans import BeanCreate, BeanOut

router = APIRouter(prefix="/beans", tags=["beans"])


@router.get("", response_model=ApiResponse)
async def list_beans(
    search: str | None = Query(None),
    origin: str | None = Query(None),
    process: str | None = Query(None),
    roast_level: str | None = Query(None),
    session: AsyncSession = Depends(get_session),
) -> ApiResponse:
    # TODO: implement query logic
    return ApiResponse(data=[])


@router.get("/{bean_id}", response_model=ApiResponse)
async def get_bean(
    bean_id: uuid.UUID,
    session: AsyncSession = Depends(get_session),
) -> ApiResponse:
    # TODO: implement
    return ApiResponse(data=None, error="Not implemented")


@router.post("", response_model=ApiResponse)
async def create_bean(
    payload: BeanCreate,
    session: AsyncSession = Depends(get_session),
) -> ApiResponse:
    # TODO: implement
    return ApiResponse(data=None, error="Not implemented")
