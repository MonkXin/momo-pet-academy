import unittest

from momo_pet.domain import Course, PetEvent, PetProfile, Stat, reduce_event


class StatTests(unittest.TestCase):
    def test_clamps_value_to_zero_through_one_hundred(self) -> None:
        self.assertEqual(Stat(105).value, 100)
        self.assertEqual(Stat(-1).value, 0)


class PetEventTests(unittest.TestCase):
    def test_literacy_raises_intelligence_and_creativity(self) -> None:
        profile = reduce_event(PetProfile(), PetEvent.course_completed(Course.LITERACY))

        self.assertEqual(profile.intelligence.value, 8)
        self.assertEqual(profile.creativity.value, 4)
        self.assertEqual(profile.energy.value, 72)
        self.assertEqual(profile.kindergarten_xp, 10)

    def test_offline_recovery_caps_at_three_days(self) -> None:
        profile = PetProfile(energy=Stat(10), mood=Stat(10))
        recovered = reduce_event(profile, PetEvent.recovered_offline(20))

        self.assertEqual(recovered.energy.value, 34)
        self.assertEqual(recovered.mood.value, 22)


if __name__ == "__main__":
    unittest.main()
