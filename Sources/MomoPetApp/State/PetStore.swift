import Combine
import Foundation

final class PetStore: ObservableObject {
    @Published private(set) var profile: PetProfile

    private let repository: PetRepository

    init(profile: PetProfile, repository: PetRepository) {
        self.profile = profile
        self.repository = repository
    }

    func dispatch(_ event: PetEvent) {
        profile = PetReducer.reduce(event, profile: profile)
        try? repository.save(profile)
    }

    func reconcileOfflineTime(since lastOpened: Date, now: Date) {
        let elapsed = max(0, now.timeIntervalSince(lastOpened))
        let wholeDays = Int(elapsed / 86_400)
        guard wholeDays > 0 else { return }
        dispatch(.dayPassed(days: wholeDays))
    }
}
