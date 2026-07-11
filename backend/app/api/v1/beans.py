import uuid

from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy import func, or_, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.api.deps import get_current_user
from app.db.models import Bean, User
from app.db.session import get_session
from app.schemas.base import ApiResponse
from app.schemas.beans import BeanCreate, BeanOut

router = APIRouter(prefix="/beans", tags=["beans"])

MAX_PAGE_SIZE = 100


@router.get("", response_model=ApiResponse)
async def list_beans(
    search: str | None = Query(None),
    origin: str | None = Query(None),
    process: str | None = Query(None),
    roast_level: str | None = Query(None),
    limit: int = Query(50, ge=1, le=MAX_PAGE_SIZE),
    offset: int = Query(0, ge=0),
    session: AsyncSession = Depends(get_session),
) -> ApiResponse:
    query = select(Bean)
    if search:
        pattern = f"%{search}%"
        query = query.where(
            or_(
                Bean.name.ilike(pattern),
                Bean.roaster.ilike(pattern),
                Bean.origin.ilike(pattern),
                Bean.variety.ilike(pattern),
            )
        )
    if origin:
        query = query.where(Bean.origin.ilike(f"%{origin}%"))
    if process:
        query = query.where(func.lower(Bean.process) == process.lower())
    if roast_level:
        query = query.where(func.lower(Bean.roast_level) == roast_level.lower())

    total = await session.scalar(select(func.count()).select_from(query.subquery()))
    result = await session.execute(
        query.order_by(Bean.is_verified.desc(), Bean.name).limit(limit).offset(offset)
    )
    beans = result.scalars().all()
    return ApiResponse(
        data=[BeanOut.model_validate(b).model_dump(mode="json") for b in beans],
        meta={"total": total, "limit": limit, "offset": offset},
    )


@router.get("/{bean_id}", response_model=ApiResponse)
async def get_bean(
    bean_id: uuid.UUID,
    session: AsyncSession = Depends(get_session),
) -> ApiResponse:
    bean = await session.get(Bean, bean_id)
    if bean is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Bean not found")
    return ApiResponse(data=BeanOut.model_validate(bean).model_dump(mode="json"))


@router.post("", response_model=ApiResponse, status_code=status.HTTP_201_CREATED)
async def create_bean(
    payload: BeanCreate,
    session: AsyncSession = Depends(get_session),
    user: User = Depends(get_current_user),
) -> ApiResponse:
    bean = Bean(**payload.model_dump(), created_by=user.id, is_verified=False)
    session.add(bean)
    await session.commit()
    await session.refresh(bean)
    return ApiResponse(data=BeanOut.model_validate(bean).model_dump(mode="json"))
