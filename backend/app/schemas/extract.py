from pydantic import BaseModel


class ExtractionResult(BaseModel):
    name: str | None = None
    roaster: str | None = None
    origin: str | None = None
    variety: str | None = None
    process: str | None = None
    roast_level: str | None = None
    tasting_notes: list[str] | None = None
