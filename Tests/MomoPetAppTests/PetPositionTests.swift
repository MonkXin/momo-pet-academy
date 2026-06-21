import XCTest
@testable import MomoPetApp

final class PetPositionTests: XCTestCase {
    func testPositionClampsInsideVisibleFrame() {
        let position = PetPosition(x: -20, y: 900)
        let result = position.clamped(
            in: PetFrame(x: 0, y: 0, width: 800, height: 600),
            petSize: PetSize(width: 260, height: 300)
        )

        XCTAssertEqual(result, PetPosition(x: 0, y: 300))
    }

    func testDefaultPositionStartsAtTheDesktopCorner() {
        XCTAssertEqual(PetPosition.defaultPosition, PetPosition(x: 24, y: 48))
    }
}
