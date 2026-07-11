import uuid
from datetime import datetime
from typing import Literal

from pydantic import BaseModel, Field


class BrewLogCreate(BaseModel):
    bean_id: uuid.UUID
    brewer: str = Field(min_length=1, max_length=50)
    grinder: str | None = Field(default=None, max_length=50)
    grind_setting: float | None = Field(default=None, ge=0, le=500)
    dose_g: float | None = Field(default=None, gt=0, le=200)
    yield_g: float | None = Field(default=None, gt=0, le=2000)
    water_temp_c: float | None = Field(default=None, gt=0, le=100)
    brew_time_seconds: int | None = Field(default=None, gt=0, le=7200)
    tds: float | None = Field(default=None, ge=0, le=20)
    rating: int | None = Field(default=None, ge=1, le=5)
    notes: str | None = Field(default=None, max_length=2000)
    generated_by: Literal["rules", "manual"] | None = None


class BrewBeanSummary(BaseModel):
    """Slim bean payload embedded in brew responses so clients don't N+1."""

    id: uuid.UUID
    name: str
    roaster: str | None = None
    origin: str | None = None

    model_config = {"from_attributes": True}


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
    bean: BrewBeanSummary | None = None

    model_config = {"from_attributes": True}
