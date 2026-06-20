"""Core rules for 小白's growth."""

from dataclasses import dataclass, replace
from enum import Enum
from typing import Optional


@dataclass(frozen=True)
class Stat:
    """A score that always remains within the visible progress-bar range."""

    value: int

    def __post_init__(self) -> None:
        object.__setattr__(self, "value", max(0, min(100, self.value)))

    def changed(self, amount: int) -> "Stat":
        return Stat(self.value + amount)


class Course(Enum):
    LITERACY = "literacy"
    JUMPING = "jumping"
    STAGE = "stage"


class EventKind(Enum):
    FED = "fed"
    PETTED = "petted"
    RESTED = "rested"
    COURSE_COMPLETED = "course_completed"
    RECOVERED_OFFLINE = "recovered_offline"


@dataclass(frozen=True)
class PetEvent:
    kind: EventKind
    course: Optional[Course] = None
    days: int = 0

    @classmethod
    def fed(cls) -> "PetEvent":
        return cls(EventKind.FED)

    @classmethod
    def petted(cls) -> "PetEvent":
        return cls(EventKind.PETTED)

    @classmethod
    def rested(cls) -> "PetEvent":
        return cls(EventKind.RESTED)

    @classmethod
    def course_completed(cls, course: Course) -> "PetEvent":
        return cls(EventKind.COURSE_COMPLETED, course=course)

    @classmethod
    def recovered_offline(cls, days: int) -> "PetEvent":
        return cls(EventKind.RECOVERED_OFFLINE, days=days)


@dataclass(frozen=True)
class PetProfile:
    hunger: Stat = Stat(80)
    mood: Stat = Stat(80)
    cleanliness: Stat = Stat(80)
    energy: Stat = Stat(80)
    intelligence: Stat = Stat(0)
    strength: Stat = Stat(0)
    charm: Stat = Stat(0)
    creativity: Stat = Stat(0)
    courage: Stat = Stat(0)
    kindergarten_xp: int = 0


def reduce_event(profile: PetProfile, event: PetEvent) -> PetProfile:
    if event.kind is EventKind.FED:
        return replace(profile, hunger=profile.hunger.changed(18))
    if event.kind is EventKind.PETTED:
        return replace(profile, mood=profile.mood.changed(12))
    if event.kind is EventKind.RESTED:
        return replace(profile, energy=profile.energy.changed(20))
    if event.kind is EventKind.RECOVERED_OFFLINE:
        recovered_days = min(3, max(0, event.days))
        return replace(
            profile,
            energy=profile.energy.changed(recovered_days * 8),
            mood=profile.mood.changed(recovered_days * 4),
        )
    if event.course is Course.LITERACY:
        return replace(
            profile,
            intelligence=profile.intelligence.changed(8),
            creativity=profile.creativity.changed(4),
            energy=profile.energy.changed(-8),
            kindergarten_xp=profile.kindergarten_xp + 10,
        )
    if event.course is Course.JUMPING:
        return replace(
            profile,
            strength=profile.strength.changed(8),
            courage=profile.courage.changed(4),
            energy=profile.energy.changed(-10),
            kindergarten_xp=profile.kindergarten_xp + 10,
        )
    if event.course is Course.STAGE:
        return replace(
            profile,
            charm=profile.charm.changed(8),
            courage=profile.courage.changed(3),
            energy=profile.energy.changed(-7),
            kindergarten_xp=profile.kindergarten_xp + 10,
        )
    raise ValueError("A completed course requires a course type.")
