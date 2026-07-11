from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy import func, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.api.deps import get_current_user
from app.db.models import Bean, BrewLog, User
from app.db.session import get_session
from app.schemas.base import ApiResponse
from app.schemas.brews import BrewLogCreate, BrewLogOut

router = APIRouter(prefix="/brews", tags=["brews"])

MAX_PAGE_SIZE = 100


@router.post("", response_model=ApiResponse, status_code=status.HTTP_201_CREATED)
async def create_brew(
    payload: BrewLogCreate,
    session: AsyncSession = Depends(get_session),
    user: User = Depends(get_current_user),
) -> ApiResponse:
    bean = await session.get(Bean, payload.bean_id)
    if bean is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Bean not found")

    brew = BrewLog(**payload.model_dump(), user_id=user.id)
    session.add(brew)
    await session.commit()
    await session.refresh(brew)
    return ApiResponse(data=BrewLogOut.model_validate(brew).model_dump(mode="json"))


@router.get("", response_model=ApiResponse)
async def list_brews(
    limit: int = Query(50, ge=1, le=MAX_PAGE_SIZE),
    offset: int = Query(0, ge=0),
    session: AsyncSession = Depends(get_session),
    user: User = Depends(get_current_user),
) -> ApiResponse:
    query = select(BrewLog).where(BrewLog.user_id == user.id)
    total = await session.scalar(select(func.count()).select_from(query.subquery()))
    result = await session.execute(
        query.order_by(BrewLog.timestamp.desc()).limit(limit).offset(offset)
    )
    brews = result.scalars().all()
    return ApiResponse(
        data=[BrewLogOut.model_validate(b).model_dump(mode="json") for b in brews],
        meta={"total": total, "limit": limit, "offset": offset},
    )
