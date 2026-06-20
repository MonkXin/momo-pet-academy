import XCTest
@testable import MomoPetApp

final class PetStoreTests: XCTestCase {
    func testDispatchUpdatesProfileAndPersistsIt() throws {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("json")
        let repository = PetRepository(url: url)
        let store = PetStore(profile: PetProfile(), repository: repository)

        store.dispatch(.petted)

        XCTAssertEqual(store.profile.mood.value, 92)
        XCTAssertEqual(try repository.load().mood.value, 92)
        try? FileManager.default.removeItem(at: url)
    }

    func testReconcileOfflineTimeAppliesWholeDaysOnly() {
        let repository = PetRepository(url: FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString))
        let store = PetStore(profile: PetProfile(), repository: repository)

        store.reconcileOfflineTime(since: Date(timeIntervalSinceNow: -2.5 * 86_400), now: Date())

        XCTAssertEqual(store.profile.hunger.value, 68)
        XCTAssertEqual(store.profile.energy.value, 74)
    }
}
