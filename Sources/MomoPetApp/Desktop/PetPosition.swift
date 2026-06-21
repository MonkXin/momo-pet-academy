import Foundation

struct PetPosition: Codable, Equatable {
    let x: CGFloat
    let y: CGFloat

    static let defaultPosition = PetPosition(x: 24, y: 48)

    func clamped(in frame: PetFrame, petSize: PetSize) -> Self {
        .init(
            x: min(max(x, frame.x), frame.x + max(0, frame.width - petSize.width)),
            y: min(max(y, frame.y), frame.y + max(0, frame.height - petSize.height))
        )
    }
}

struct PetSize: Equatable {
    let width: CGFloat
    let height: CGFloat
}

struct PetFrame: Equatable {
    let x: CGFloat
    let y: CGFloat
    let width: CGFloat
    let height: CGFloat
}
