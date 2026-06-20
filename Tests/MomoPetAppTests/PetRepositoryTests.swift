import XCTest
@testable import MomoPetApp

final class PetRepositoryTests: XCTestCase {
    func testSaveThenLoadReturnsSameProfile() throws {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("json")
        let repository = PetRepository(url: url)
        let expected = PetProfile(intelligence: Stat(value: 12), courage: Stat(value: 7))

        try repository.save(expected)

        XCTAssertEqual(try repository.load(), expected)
        try? FileManager.default.removeItem(at: url)
    }
}
