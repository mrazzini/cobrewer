import uuid
from datetime import datetime

from pydantic import BaseModel


class BeanQuery(BaseModel):
    search: str | None = None
    origin: str | None = None
    process: str | None = None
    roast_level: str | None = None


class BeanCreate(BaseModel):
    name: str
    roaster: str | None = None
    origin: str | None = None
    variety: str | None = None
    process: str | None = None
    roast_level: str | None = None
    roast_date: datetime | None = None
    tasting_notes: list[str] | None = None
    cupping_score: float | None = None
    source_url: str | None = None


class BeanOut(BaseModel):
    id: uuid.UUID
    name: str
    roaster: str | None = None
    origin: str | None = None
    variety: str | None = None
    process: str | None = None
    roast_level: str | None = None
    roast_date: datetime | None = None
    tasting_notes: list[str] | None = None
    cupping_score: float | None = None
    source_url: str | None = None
    is_verified: bool
    created_at: datetime

    model_config = {"from_attributes": True}
