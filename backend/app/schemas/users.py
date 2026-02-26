import uuid
from datetime import datetime

from pydantic import BaseModel


class EquipmentItem(BaseModel):
    equipment_type: str
    brand: str | None = None
    model: str | None = None
    burr_type: str | None = None


class EquipmentUpdate(BaseModel):
    equipment: list[EquipmentItem]


class UserOut(BaseModel):
    id: uuid.UUID
    clerk_id: str
    display_name: str | None = None
    created_at: datetime

    model_config = {"from_attributes": True}
