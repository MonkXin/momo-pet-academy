import XCTest
@testable import MomoPetApp

final class WeeklyGrowthTests: XCTestCase {
    func testStudyMultiplierUsesOneHundredSeventyAndFortyPercent() {
        XCTAssertEqual(WeeklyStudyRule.multiplier(forCompletedCourses: 0), 1.0)
        XCTAssertEqual(WeeklyStudyRule.multiplier(forCompletedCourses: 1), 0.7)
        XCTAssertEqual(WeeklyStudyRule.multiplier(forCompletedCourses: 2), 0.4)
        XCTAssertEqual(WeeklyStudyRule.scaled(8, completedCourses: 2), 3)
    }

    func testMilestoneContentChangesWithSchoolStage() {
        XCTAssertEqual(WeeklyGrowthMilestone.attentive.content(for: .kindergarten).rewardName, "认真小贴纸")
        XCTAssertEqual(WeeklyGrowthMilestone.attentive.content(for: .primarySchool).rewardName, "班级小贴纸")
    }
}
