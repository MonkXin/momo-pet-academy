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

    func testDesktopPetImageCanBeDecoded() {
        XCTAssertNotNil(PetVisualAsset.desktopPetImage())
    }

    func testIdleDesktopPetAssetCanBeDecoded() {
        XCTAssertNotNil(PetVisualAsset.desktopPetImage(for: .idle))
    }

    func testMissingActionPoseFallsBackToIdleImage() {
        XCTAssertNotNil(PetVisualAsset.desktopPetImage(for: .petted))
        XCTAssertNotNil(PetVisualAsset.desktopPetImage(for: .fed))
    }
}
