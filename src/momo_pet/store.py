"""The single mutable state entry point for the desktop pet."""

from .domain import PetEvent, PetProfile, reduce_event
from .repository import PetRepository


class PetStore:
    def __init__(self, profile: PetProfile, repository: PetRepository) -> None:
        self.profile = profile
        self._repository = repository

    def dispatch(self, event: PetEvent) -> PetProfile:
        self.profile = reduce_event(self.profile, event)
        self._repository.save(self.profile)
        return self.profile
