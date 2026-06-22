import XCTest
@testable import MomoPetApp

final class PetDomainTests: XCTestCase {
    func testStatClampsToVisibleRange() {
        XCTAssertEqual(Stat(value: 105).value, 100)
        XCTAssertEqual(Stat(value: -1).value, 0)
    }

    func testLiteracyImprovesIntelligenceAndCreativity() {
        let profile = PetReducer.reduce(.courseCompleted(.literacy), profile: PetProfile())

        XCTAssertEqual(profile.intelligence.value, 8)
        XCTAssertEqual(profile.creativity.value, 4)
        XCTAssertEqual(profile.energy.value, 72)
    }

    func testSecondCourseOnSameDayUsesSeventyPercentAndAddsStamp() {
        let period = StudyPeriod(dayID: "2026-06-22", weekID: "2026-W26")
        var profile = PetProfile()
        profile = PetReducer.reduce(.datedCourseCompleted(.literacy, period: period), profile: profile)
        profile = PetReducer.reduce(.datedCourseCompleted(.literacy, period: period), profile: profile)

        XCTAssertEqual(profile.intelligence.value, 13)
        XCTAssertEqual(profile.weeklyStudyStampCount, 2)
    }

    func testNewWeekResetsDailyAndWeeklyProgress() {
        let old = StudyPeriod(dayID: "2026-06-22", weekID: "2026-W26")
        let next = StudyPeriod(dayID: "2026-06-29", weekID: "2026-W27")
        var profile = PetProfile(
            lastStudyDay: old.dayID,
            studyCountOnLastStudyDay: 3,
            weeklyStudyStampCount: 6,
            weeklyGrowthWeekID: old.weekID,
            claimedWeeklyGrowthMilestones: [.attentive]
        )
        profile = PetReducer.reduce(.datedCourseCompleted(.jumping, period: next), profile: profile)

        XCTAssertEqual(profile.strength.value, 8)
        XCTAssertEqual(profile.weeklyStudyStampCount, 1)
        XCTAssertEqual(profile.claimedWeeklyGrowthMilestones, [])
    }

    func testLowEnergyShowsNappingActivity() {
        XCTAssertEqual(PetActivity.current(for: PetProfile(energy: Stat(value: 15))), .napping)
    }

    func testLowHungerShowsHungryActivityBeforeStudy() {
        XCTAssertEqual(PetActivity.current(for: PetProfile(hunger: Stat(value: 20))), .hungry)
    }

    func testLowMoodShowsLonelyActivity() {
        XCTAssertEqual(PetActivity.current(for: PetProfile(mood: Stat(value: 20))), .lonely)
    }

    func testDayPassedGentlyReducesDailyNeeds() {
        let result = PetReducer.reduce(.dayPassed(days: 2), profile: PetProfile())

        XCTAssertEqual(result.hunger.value, 68)
        XCTAssertEqual(result.cleanliness.value, 72)
        XCTAssertEqual(result.energy.value, 74)
    }

    func testCleaningRestoresCleanliness() {
        let profile = PetProfile(cleanliness: Stat(value: 40))
        let result = PetReducer.reduce(.cleaned, profile: profile)

        XCTAssertEqual(result.cleanliness.value, 65)
    }

    func testKindergartenGraduationRequiresAllEventsAndSeventyXP() {
        let ready = PetProfile(
            kindergartenXP: 70,
            completedEvents: Set(KindergartenEvent.allCases)
        )

        XCTAssertTrue(ready.isKindergartenGraduate)
    }

    func testGraduationClaimAdvancesToPrimarySchool() {
        let profile = PetProfile(
            kindergartenXP: 70,
            completedEvents: Set(KindergartenEvent.allCases)
        )

        let result = PetReducer.reduce(.graduationClaimed, profile: profile)

        XCTAssertEqual(result.schoolStage, .primarySchool)
    }

    func testWinningStarCatchRaisesMoodAndKindergartenXP() {
        let profile = PetReducer.reduce(.miniGameCompleted(.starCatch, won: true), profile: PetProfile())

        XCTAssertEqual(profile.mood.value, 88)
        XCTAssertEqual(profile.kindergartenXP, 5)
    }

    func testPanelModeTogglesBetweenCompactAndAcademy() {
        XCTAssertEqual(PetPanelMode.compact.toggled, .academy)
        XCTAssertEqual(PetPanelMode.academy.toggled, .compact)
    }

    func testClaimingIntroductionAddsCharmAndBlueBowTie() {
        let profile = PetProfile(kindergartenXP: 10)
        let result = PetReducer.reduce(.kindergartenEventClaimed(.introduction), profile: profile)

        XCTAssertEqual(result.charm.value, 3)
        XCTAssertTrue(result.completedEvents.contains(.introduction))
        XCTAssertTrue(result.rewards.contains("蓝色领结"))
    }

    func testEquippingEarnedAccessoryUpdatesProfile() {
        var profile = PetProfile()
        profile.rewards.insert("蓝色领结")

        let result = PetReducer.reduce(.accessoryEquipped("蓝色领结"), profile: profile)

        XCTAssertEqual(result.equippedAccessory, "蓝色领结")
    }

    func testPlacingEarnedFurnitureUpdatesRoom() {
        var profile = PetProfile()
        profile.rewards.insert("云朵绘本")

        let result = PetReducer.reduce(.furniturePlaced("云朵绘本"), profile: profile)

        XCTAssertTrue(result.placedFurniture.contains("云朵绘本"))
    }

    func testPrimarySchoolCourseAddsPrimaryXPWithoutChangingKindergartenXP() {
        let profile = PetProfile(kindergartenXP: 70, schoolStage: .primarySchool)
        let result = PetReducer.reduce(.primaryCourseCompleted(.reading), profile: profile)

        XCTAssertEqual(result.primaryXP, 10)
        XCTAssertEqual(result.kindergartenXP, 70)
        XCTAssertEqual(result.intelligence.value, 7)
    }

    func testOldProfileJSONDecodesWithEmptyPrimaryProgress() throws {
        let data = #"{"hunger":{"value":80},"mood":{"value":80},"cleanliness":{"value":80},"energy":{"value":80}}"#.data(using: .utf8)!
        let result = try JSONDecoder().decode(PetProfile.self, from: data)

        XCTAssertEqual(result.primaryXP, 0)
        XCTAssertEqual(result.completedPrimaryEvents, [])
    }

    func testPrimaryEventRequiresPrimarySchoolAndXPThenAwardsReward() {
        let base = PetProfile(primaryXP: 30, schoolStage: .primarySchool)
        let result = PetReducer.reduce(.primaryEventClaimed(.introduction), profile: base)

        XCTAssertTrue(result.completedPrimaryEvents.contains(.introduction))
        XCTAssertTrue(result.rewards.contains("小红领巾"))
        XCTAssertEqual(result.charm.value, 3)
    }

    func testPrimaryCompletionNeedsAllEventsAndOneHundredTwentyXP() {
        let profile = PetProfile(
            primaryXP: 120,
            completedPrimaryEvents: Set(PrimaryEvent.allCases),
            schoolStage: .primarySchool
        )

        XCTAssertTrue(profile.isPrimarySchoolComplete)
    }

    func testPrimaryCourseIsIgnoredBeforeGraduation() {
        let result = PetReducer.reduce(.primaryCourseCompleted(.reading), profile: PetProfile())

        XCTAssertEqual(result.primaryXP, 0)
    }

}
