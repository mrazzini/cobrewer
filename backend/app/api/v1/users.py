from fastapi import APIRouter, Depends
from sqlalchemy import delete, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.api.deps import get_current_user
from app.db.models import User, UserAiCredits, UserEquipment
from app.db.session import get_session
from app.schemas.base import ApiResponse
from app.schemas.users import EquipmentItem, EquipmentUpdate, UserOut

router = APIRouter(prefix="/users", tags=["users"])


async def _equipment_list(session: AsyncSession, user_id) -> list[dict]:
    result = await session.execute(select(UserEquipment).where(UserEquipment.user_id == user_id))
    return [
        EquipmentItem(
            equipment_type=e.equipment_type, brand=e.brand, model=e.model, burr_type=e.burr_type
        ).model_dump()
        for e in result.scalars().all()
    ]


@router.get("/me", response_model=ApiResponse)
async def get_me(
    session: AsyncSession = Depends(get_session),
    user: User = Depends(get_current_user),
) -> ApiResponse:
    credits = await session.scalar(select(UserAiCredits).where(UserAiCredits.user_id == user.id))
    return ApiResponse(
        data={
            **UserOut.model_validate(user).model_dump(mode="json"),
            "equipment": await _equipment_list(session, user.id),
            "ai_credits": {
                "extractions_used": credits.extractions_used if credits else 0,
                "extractions_limit": credits.extractions_limit if credits else 3,
            },
        }
    )


@router.put("/me/equipment", response_model=ApiResponse)
async def update_equipment(
    payload: EquipmentUpdate,
    session: AsyncSession = Depends(get_session),
    user: User = Depends(get_current_user),
) -> ApiResponse:
    # Full replace: the profile page always submits the complete equipment list.
    await session.execute(delete(UserEquipment).where(UserEquipment.user_id == user.id))
    for item in payload.equipment:
        session.add(UserEquipment(user_id=user.id, **item.model_dump()))
    await session.commit()
    return ApiResponse(data={"equipment": await _equipment_list(session, user.id)})
