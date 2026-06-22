import XCTest
@testable import MomoPetApp

final class DesktopPetStatePresentationTests: XCTestCase {
    func testNappingUsesRestingPoseWithoutPrompt() {
        XCTAssertEqual(DesktopPetStatePresentation.forActivity(.napping), .init(pose: .resting, prompt: nil))
    }

    func testHungryUsesIdlePoseWithCarrotPrompt() {
        XCTAssertEqual(DesktopPetStatePresentation.forActivity(.hungry), .init(pose: .idle, prompt: .carrot))
    }

    func testLonelyUsesIdlePoseWithHeartPrompt() {
        XCTAssertEqual(DesktopPetStatePresentation.forActivity(.lonely), .init(pose: .idle, prompt: .heart))
    }
}
