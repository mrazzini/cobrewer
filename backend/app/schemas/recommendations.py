import uuid
from datetime import datetime
from typing import Any

from pydantic import BaseModel


class RecommendationQuery(BaseModel):
    bean_id: uuid.UUID
    brewer: str
    grinder: str | None = None


class RecommendationOut(BaseModel):
    id: uuid.UUID
    bean_id: uuid.UUID
    brewer: str
    grinder: str | None = None
    parameters: dict[str, Any] | None = None
    generated_by: str
    confidence_score: float | None = None
    created_at: datetime

    model_config = {"from_attributes": True}
