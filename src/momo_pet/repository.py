"""Local, recoverable persistence for the pet profile."""

import json
import os
from pathlib import Path

from .domain import PetProfile, Stat


class CorruptSaveError(RuntimeError):
    """Raised after a malformed save is kept as a recoverable backup."""


class PetRepository:
    def __init__(self, path: Path) -> None:
        self.path = path

    def save(self, profile: PetProfile) -> None:
        self.path.parent.mkdir(parents=True, exist_ok=True)
        payload = {
            name: getattr(profile, name).value
            for name in (
                "hunger", "mood", "cleanliness", "energy", "intelligence",
                "strength", "charm", "creativity", "courage",
            )
        }
        payload["kindergarten_xp"] = profile.kindergarten_xp
        temporary_path = self.path.with_suffix(self.path.suffix + ".tmp")
        temporary_path.write_text(
            json.dumps(payload, ensure_ascii=False, indent=2), encoding="utf-8"
        )
        os.replace(temporary_path, self.path)

    def load(self) -> PetProfile:
        try:
            payload = json.loads(self.path.read_text(encoding="utf-8"))
            return PetProfile(
                hunger=Stat(payload["hunger"]),
                mood=Stat(payload["mood"]),
                cleanliness=Stat(payload["cleanliness"]),
                energy=Stat(payload["energy"]),
                intelligence=Stat(payload["intelligence"]),
                strength=Stat(payload["strength"]),
                charm=Stat(payload["charm"]),
                creativity=Stat(payload["creativity"]),
                courage=Stat(payload["courage"]),
                kindergarten_xp=int(payload["kindergarten_xp"]),
            )
        except (json.JSONDecodeError, KeyError, TypeError, ValueError) as error:
            backup_path = self.path.with_suffix(self.path.suffix + ".corrupt")
            if self.path.exists():
                os.replace(self.path, backup_path)
            raise CorruptSaveError("宠物档案无法读取，已保留损坏备份。") from error
