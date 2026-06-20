import XCTest
@testable import MomoPetApp

final class SmokeTests: XCTestCase {
    func testAppModuleLoads() {
        XCTAssertEqual(AppMetadata.name, "小白的学堂时光")
    }
}
