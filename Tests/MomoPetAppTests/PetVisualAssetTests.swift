import XCTest
import AppKit
@testable import MomoPetApp

final class PetVisualAssetTests: XCTestCase {
    func testUsesTheGeneratedRabbitMasterAsset() {
        XCTAssertEqual(PetVisualAsset.masterImageName, "momo-rabbit-3d")
    }

    func testGeneratedRabbitImageIsBundledForThePortrait() {
        XCTAssertNotNil(PetVisualAsset.masterImageURL)
    }

    func testGeneratedRabbitImageCanBeDecodedForDisplay() {
        XCTAssertNotNil(PetVisualAsset.masterImage())
    }
}
