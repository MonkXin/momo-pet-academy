import tempfile
import unittest
from pathlib import Path

from momo_pet.domain import PetEvent, PetProfile
from momo_pet.repository import PetRepository
from momo_pet.store import PetStore


class PetStoreTests(unittest.TestCase):
    def test_dispatch_petted_updates_mood_and_saves(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            repository = PetRepository(Path(directory) / "pet.json")
            store = PetStore(PetProfile(), repository)

            store.dispatch(PetEvent.petted())

            self.assertEqual(store.profile.mood.value, 92)
            self.assertEqual(repository.load().mood.value, 92)


if __name__ == "__main__":
    unittest.main()
