from typing import Any

from pydantic import BaseModel


class ApiResponse(BaseModel):
    data: Any | None = None
    error: str | None = None
    meta: dict[str, Any] | None = None
