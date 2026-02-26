from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession

from app.db.session import get_session
from app.schemas.base import ApiResponse
from app.schemas.users import EquipmentUpdate

router = APIRouter(prefix="/users", tags=["users"])


@router.get("/me", response_model=ApiResponse)
async def get_current_user(
    session: AsyncSession = Depends(get_session),
) -> ApiResponse:
    # TODO: resolve user from Clerk JWT
    return ApiResponse(data=None, error="Not implemented")


@router.put("/me/equipment", response_model=ApiResponse)
async def update_equipment(
    payload: EquipmentUpdate,
    session: AsyncSession = Depends(get_session),
) -> ApiResponse:
    # TODO: implement
    return ApiResponse(data=None, error="Not implemented")
