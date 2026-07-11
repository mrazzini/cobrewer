import uuid
from datetime import datetime

from sqlalchemy import (
    Boolean,
    DateTime,
    Float,
    ForeignKey,
    Integer,
    String,
    Text,
    func,
)
from sqlalchemy.dialects.postgresql import ARRAY, JSONB, UUID
from sqlalchemy.orm import DeclarativeBase, Mapped, mapped_column, relationship


class Base(DeclarativeBase):
    pass


class User(Base):
    __tablename__ = "users"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    clerk_id: Mapped[str] = mapped_column(String(255), unique=True, nullable=False, index=True)
    display_name: Mapped[str | None] = mapped_column(String(255))
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now())

    brew_logs: Mapped[list["BrewLog"]] = relationship(back_populates="user")
    equipment: Mapped[list["UserEquipment"]] = relationship(back_populates="user")
    ai_credits: Mapped["UserAiCredits | None"] = relationship(back_populates="user")


class Bean(Base):
    __tablename__ = "beans"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    name: Mapped[str] = mapped_column(String(255), nullable=False)
    roaster: Mapped[str | None] = mapped_column(String(255))
    origin: Mapped[str | None] = mapped_column(String(255))
    variety: Mapped[str | None] = mapped_column(String(255))
    process: Mapped[str | None] = mapped_column(String(100))
    roast_level: Mapped[str | None] = mapped_column(String(50))
    roast_date: Mapped[datetime | None] = mapped_column(DateTime(timezone=True))
    tasting_notes: Mapped[list[str] | None] = mapped_column(ARRAY(Text))
    cupping_score: Mapped[float | None] = mapped_column(Float)
    source_url: Mapped[str | None] = mapped_column(Text)
    created_by: Mapped[uuid.UUID | None] = mapped_column(UUID(as_uuid=True), ForeignKey("users.id"))
    is_verified: Mapped[bool] = mapped_column(Boolean, default=False)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now())

    brew_logs: Mapped[list["BrewLog"]] = relationship(back_populates="bean")
    recommendations: Mapped[list["Recommendation"]] = relationship(back_populates="bean")


class BrewLog(Base):
    __tablename__ = "brew_logs"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), ForeignKey("users.id"), nullable=False
    )
    bean_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), ForeignKey("beans.id"), nullable=False
    )
    brewer: Mapped[str] = mapped_column(String(100), nullable=False)
    grinder: Mapped[str | None] = mapped_column(String(100))
    grind_setting: Mapped[float | None] = mapped_column(Float)
    dose_g: Mapped[float | None] = mapped_column(Float)
    yield_g: Mapped[float | None] = mapped_column(Float)
    water_temp_c: Mapped[float | None] = mapped_column(Float)
    brew_time_seconds: Mapped[int | None] = mapped_column(Integer)
    tds: Mapped[float | None] = mapped_column(Float)
    rating: Mapped[int | None] = mapped_column(Integer)
    notes: Mapped[str | None] = mapped_column(Text)
    generated_by: Mapped[str | None] = mapped_column(String(50))
    timestamp: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now())

    user: Mapped["User"] = relationship(back_populates="brew_logs")
    bean: Mapped["Bean"] = relationship(back_populates="brew_logs")


class Recommendation(Base):
    __tablename__ = "recommendations"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    bean_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), ForeignKey("beans.id"), nullable=False
    )
    brewer: Mapped[str] = mapped_column(String(100), nullable=False)
    grinder: Mapped[str | None] = mapped_column(String(100))
    parameters: Mapped[dict | None] = mapped_column(JSONB)
    generated_by: Mapped[str] = mapped_column(String(50), default="rules")
    confidence_score: Mapped[float | None] = mapped_column(Float)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now())

    bean: Mapped["Bean"] = relationship(back_populates="recommendations")


class UserEquipment(Base):
    __tablename__ = "user_equipment"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), ForeignKey("users.id"), nullable=False
    )
    equipment_type: Mapped[str] = mapped_column(String(50), nullable=False)
    brand: Mapped[str | None] = mapped_column(String(255))
    model: Mapped[str | None] = mapped_column(String(255))
    burr_type: Mapped[str | None] = mapped_column(String(100))

    user: Mapped["User"] = relationship(back_populates="equipment")


class UserAiCredits(Base):
    __tablename__ = "user_ai_credits"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), ForeignKey("users.id"), unique=True, nullable=False
    )
    extractions_used: Mapped[int] = mapped_column(Integer, default=0)
    extractions_limit: Mapped[int] = mapped_column(Integer, default=3)

    user: Mapped["User"] = relationship(back_populates="ai_credits")
