import unittest

from momo_pet.app import current_activity
from momo_pet.domain import PetProfile, Stat


class AppRulesTests(unittest.TestCase):
    def test_low_energy_uses_napping_activity(self) -> None:
        profile = PetProfile(energy=Stat(15))

        self.assertEqual(current_activity(profile), "午睡中")


if __name__ == "__main__":
    unittest.main()
