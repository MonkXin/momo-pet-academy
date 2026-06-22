import XCTest
@testable import MomoPetApp

final class DesktopPetFeedbackTests: XCTestCase {
    func testPetActionShowsHeartFeedback() {
        XCTAssertEqual(DesktopPetFeedback.forEvent(.petted), .heart)
    }

    func testFeedActionShowsCarrotFeedback() {
        XCTAssertEqual(DesktopPetFeedback.forEvent(.fed), .carrot)
    }

    func testRestActionShowsRestFeedback() {
        XCTAssertEqual(DesktopPetFeedback.forEvent(.rested), .rest)
    }

    func testFeedbackHasShortFixedDurations() {
        XCTAssertEqual(DesktopPetFeedback.heart.duration, 0.8)
        XCTAssertEqual(DesktopPetFeedback.carrot.duration, 0.8)
    }

    func testFeedbackSelectsMatchingOptionalPose() {
        XCTAssertEqual(DesktopPetFeedback.heart.pose, .petted)
        XCTAssertEqual(DesktopPetFeedback.carrot.pose, .fed)
    }

    func testRestFeedbackUsesRestingPose() {
        XCTAssertEqual(DesktopPetFeedback.rest.pose, .resting)
    }
}
