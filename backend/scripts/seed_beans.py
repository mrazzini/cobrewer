"""Seed ~200 beans from CSV into the database.

Usage (from backend/):  python -m scripts.seed_beans [path/to/beans.csv]

Idempotent: beans already present (matched on name + roaster) are skipped.
"""

import asyncio
import csv
import sys
from pathlib import Path

from sqlalchemy import select, tuple_

from app.db.models import Bean
from app.db.session import async_session_factory

DEFAULT_CSV = Path(__file__).parent / "data" / "beans.csv"


def load_rows(csv_path: Path) -> list[dict]:
    with csv_path.open(newline="") as f:
        rows = []
        for row in csv.DictReader(f):
            rows.append(
                {
                    "name": row["name"],
                    "roaster": row["roaster"] or None,
                    "origin": row["origin"] or None,
                    "variety": row["variety"] or None,
                    "process": row["process"] or None,
                    "roast_level": row["roast_level"] or None,
                    "tasting_notes": row["tasting_notes"].split("|")
                    if row["tasting_notes"]
                    else None,
                    "cupping_score": float(row["cupping_score"]) if row["cupping_score"] else None,
                    "source_url": row["source_url"] or None,
                    "is_verified": True,
                }
            )
        return rows


async def seed(csv_path: Path) -> None:
    rows = load_rows(csv_path)
    async with async_session_factory() as session:
        existing = set(
            (
                await session.execute(
                    select(Bean.name, Bean.roaster).where(
                        tuple_(Bean.name, Bean.roaster).in_(
                            [(r["name"], r["roaster"]) for r in rows]
                        )
                    )
                )
            ).all()
        )
        new_rows = [r for r in rows if (r["name"], r["roaster"]) not in existing]
        session.add_all(Bean(**r) for r in new_rows)
        await session.commit()
        print(f"Seeded {len(new_rows)} beans ({len(rows) - len(new_rows)} already present)")


if __name__ == "__main__":
    path = Path(sys.argv[1]) if len(sys.argv) > 1 else DEFAULT_CSV
    asyncio.run(seed(path))
