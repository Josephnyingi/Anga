"""
Livestock records: what animals a farmer keeps, keyed by phone number.

Backs personalized advice (AI assistant, ai_service.py) and personalized
alerts (livestock heat-stress messaging, alerts_service.py). Keyed by
phone_number rather than a User row - USSD callers have a phone number but
never "log in", so this has to work without one.
"""

from datetime import date as date_type
from typing import List

from sqlalchemy.orm import Session

from core.database import Livestock

ANIMAL_TYPES = ["cattle", "goat", "sheep", "poultry", "pig"]


def upsert_livestock(
    db: Session, phone_number: str, location: str, animal_type: str, count: int
) -> Livestock:
    animal_type = animal_type.lower().strip()
    if animal_type not in ANIMAL_TYPES:
        raise ValueError(f"Unknown animal_type '{animal_type}'. Supported: {ANIMAL_TYPES}")
    if count < 0:
        raise ValueError("count cannot be negative")

    record = (
        db.query(Livestock)
        .filter(Livestock.phone_number == phone_number, Livestock.animal_type == animal_type)
        .first()
    )
    if record:
        record.count = count
        record.location = location
        record.updated_at = date_type.today()
    else:
        record = Livestock(
            phone_number=phone_number,
            location=location,
            animal_type=animal_type,
            count=count,
            updated_at=date_type.today(),
        )
        db.add(record)

    db.commit()
    db.refresh(record)
    return record


def get_livestock(db: Session, phone_number: str) -> List[Livestock]:
    return (
        db.query(Livestock)
        .filter(Livestock.phone_number == phone_number)
        .order_by(Livestock.animal_type)
        .all()
    )


def delete_livestock(db: Session, phone_number: str, livestock_id: int) -> bool:
    record = (
        db.query(Livestock)
        .filter(Livestock.id == livestock_id, Livestock.phone_number == phone_number)
        .first()
    )
    if not record:
        return False
    db.delete(record)
    db.commit()
    return True


# cattle/sheep don't take a plural "s"; the rest do when count != 1.
_INVARIANT_PLURALS = {"cattle", "sheep"}


def _pluralize(animal_type: str, count: int) -> str:
    if animal_type in _INVARIANT_PLURALS or count == 1:
        return animal_type
    return f"{animal_type}s"


def livestock_summary_text(records: List[Livestock]) -> str:
    """Human-readable summary for prompts/messages, e.g. '2 cattle, 8 goats'."""
    parts = [f"{r.count} {_pluralize(r.animal_type, r.count)}" for r in records if r.count]
    return ", ".join(parts)
