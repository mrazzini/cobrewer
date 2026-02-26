"""Initial schema — all six tables.

Revision ID: 001
Revises: None
Create Date: 2026-02-26
"""

from typing import Sequence, Union

import sqlalchemy as sa
from alembic import op
from sqlalchemy.dialects import postgresql

revision: str = "001"
down_revision: Union[str, None] = None
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.create_table(
        "users",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True),
        sa.Column("clerk_id", sa.String(255), unique=True, nullable=False, index=True),
        sa.Column("display_name", sa.String(255), nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), server_default=sa.func.now()),
    )

    op.create_table(
        "beans",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True),
        sa.Column("name", sa.String(255), nullable=False),
        sa.Column("roaster", sa.String(255), nullable=True),
        sa.Column("origin", sa.String(255), nullable=True),
        sa.Column("variety", sa.String(255), nullable=True),
        sa.Column("process", sa.String(100), nullable=True),
        sa.Column("roast_level", sa.String(50), nullable=True),
        sa.Column("roast_date", sa.DateTime(timezone=True), nullable=True),
        sa.Column("tasting_notes", postgresql.ARRAY(sa.Text), nullable=True),
        sa.Column("cupping_score", sa.Float, nullable=True),
        sa.Column("source_url", sa.Text, nullable=True),
        sa.Column("created_by", postgresql.UUID(as_uuid=True), sa.ForeignKey("users.id"), nullable=True),
        sa.Column("is_verified", sa.Boolean, default=False),
        sa.Column("created_at", sa.DateTime(timezone=True), server_default=sa.func.now()),
    )

    op.create_table(
        "brew_logs",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True),
        sa.Column("user_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("users.id"), nullable=False),
        sa.Column("bean_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("beans.id"), nullable=False),
        sa.Column("brewer", sa.String(100), nullable=False),
        sa.Column("grinder", sa.String(100), nullable=True),
        sa.Column("grind_setting", sa.Float, nullable=True),
        sa.Column("dose_g", sa.Float, nullable=True),
        sa.Column("yield_g", sa.Float, nullable=True),
        sa.Column("water_temp_c", sa.Float, nullable=True),
        sa.Column("brew_time_seconds", sa.Integer, nullable=True),
        sa.Column("tds", sa.Float, nullable=True),
        sa.Column("rating", sa.Integer, nullable=True),
        sa.Column("notes", sa.Text, nullable=True),
        sa.Column("generated_by", sa.String(50), nullable=True),
        sa.Column("timestamp", sa.DateTime(timezone=True), server_default=sa.func.now()),
    )

    op.create_table(
        "recommendations",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True),
        sa.Column("bean_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("beans.id"), nullable=False),
        sa.Column("brewer", sa.String(100), nullable=False),
        sa.Column("grinder", sa.String(100), nullable=True),
        sa.Column("parameters", postgresql.JSONB, nullable=True),
        sa.Column("generated_by", sa.String(50), default="rules"),
        sa.Column("confidence_score", sa.Float, nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), server_default=sa.func.now()),
    )

    op.create_table(
        "user_equipment",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True),
        sa.Column("user_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("users.id"), nullable=False),
        sa.Column("equipment_type", sa.String(50), nullable=False),
        sa.Column("brand", sa.String(255), nullable=True),
        sa.Column("model", sa.String(255), nullable=True),
        sa.Column("burr_type", sa.String(100), nullable=True),
    )

    op.create_table(
        "user_ai_credits",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True),
        sa.Column("user_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("users.id"), unique=True, nullable=False),
        sa.Column("extractions_used", sa.Integer, default=0),
        sa.Column("extractions_limit", sa.Integer, default=3),
    )


def downgrade() -> None:
    op.drop_table("user_ai_credits")
    op.drop_table("user_equipment")
    op.drop_table("recommendations")
    op.drop_table("brew_logs")
    op.drop_table("beans")
    op.drop_table("users")
