import XCTest
@testable import MomoPetApp

final class PetMotionProfileTests: XCTestCase {
    func testNappingUsesSlowerBreathingThanStudying() {
        XCTAssertGreaterThan(
            PetMotionProfile.forActivity(.napping).breathingDuration,
            PetMotionProfile.forActivity(.studying).breathingDuration
        )
    }

    func testHungryAndLonelyActivitiesHaveVisualEmphasis() {
        XCTAssertEqual(PetMotionProfile.forActivity(.hungry).emphasis, .needsCare)
        XCTAssertEqual(PetMotionProfile.forActivity(.lonely).emphasis, .affection)
    }

    func testPortraitAccessibilityDescribesTheCurrentActivity() {
        XCTAssertEqual(
            RabbitPortraitCopy.accessibilityLabel(for: .napping),
            "小白的 3D 形象，当前：午睡中"
        )
    }
}
