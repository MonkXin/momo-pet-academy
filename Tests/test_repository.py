import tempfile
import unittest
from pathlib import Path

from momo_pet.domain import PetProfile, Stat
from momo_pet.repository import CorruptSaveError, PetRepository


class PetRepositoryTests(unittest.TestCase):
    def setUp(self) -> None:
        self.temp_dir = tempfile.TemporaryDirectory()
        self.path = Path(self.temp_dir.name) / "pet.json"
        self.repository = PetRepository(self.path)

    def tearDown(self) -> None:
        self.temp_dir.cleanup()

    def test_save_then_load_returns_same_profile(self) -> None:
        expected = PetProfile(intelligence=Stat(12), courage=Stat(7))

        self.repository.save(expected)

        self.assertEqual(self.repository.load(), expected)

    def test_invalid_json_is_backed_up_and_reported(self) -> None:
        self.path.write_text("not-json", encoding="utf-8")

        with self.assertRaises(CorruptSaveError):
            self.repository.load()

        self.assertTrue(self.path.with_suffix(".json.corrupt").exists())


if __name__ == "__main__":
    unittest.main()
