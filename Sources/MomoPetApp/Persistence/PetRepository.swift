import Foundation

final class PetRepository {
    private let url: URL
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    init(url: URL) {
        self.url = url
    }

    func save(_ profile: PetProfile) throws {
        let directory = url.deletingLastPathComponent()
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        try encoder.encode(profile).write(to: url, options: .atomic)
    }

    func load() throws -> PetProfile {
        try decoder.decode(PetProfile.self, from: Data(contentsOf: url))
    }
}
