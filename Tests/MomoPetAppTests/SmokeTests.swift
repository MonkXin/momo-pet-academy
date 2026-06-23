import XCTest
@testable import MomoPetApp

final class SmokeTests: XCTestCase {
    func testAppModuleLoads() {
        XCTAssertEqual(AppMetadata.name, "奶茶的学堂时光")
    }
}
