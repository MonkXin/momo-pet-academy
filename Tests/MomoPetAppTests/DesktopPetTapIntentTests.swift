import XCTest
@testable import MomoPetApp

final class DesktopPetTapIntentTests: XCTestCase {
    func testDoubleTapTakesPriorityOverPetting() {
        XCTAssertEqual(DesktopPetTapIntent.forTapCount(2), .openAcademy)
    }

    func testSingleTapPetsTheRabbit() {
        XCTAssertEqual(DesktopPetTapIntent.forTapCount(1), .pet)
    }
}
