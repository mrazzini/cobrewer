import uuid
from datetime import datetime

from pydantic import BaseModel, Field


class BrewLogCreate(BaseModel):
    bean_id: uuid.UUID
    brewer: str
    grinder: str | None = None
    grind_setting: float | None = None
    dose_g: float | None = None
    yield_g: float | None = None
    water_temp_c: float | None = None
    brew_time_seconds: int | None = None
    tds: float | None = None
    rating: int | None = Field(default=None, ge=1, le=5)
    notes: str | None = None
    generated_by: str | None = None


class BrewLogOut(BaseModel):
    id: uuid.UUID
    user_id: uuid.UUID
    bean_id: uuid.UUID
    brewer: str
    grinder: str | None = None
    grind_setting: float | None = None
    dose_g: float | None = None
    yield_g: float | None = None
    water_temp_c: float | None = None
    brew_time_seconds: int | None = None
    tds: float | None = None
    rating: int | None = None
    notes: str | None = None
    generated_by: str | None = None
    timestamp: datetime

    model_config = {"from_attributes": True}
