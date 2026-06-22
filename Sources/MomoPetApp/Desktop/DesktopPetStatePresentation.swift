import Foundation

struct DesktopPetStatePresentation: Equatable {
    let pose: DesktopPetPose
    let prompt: DesktopPetFeedback?

    static func forActivity(_ activity: PetActivity) -> Self {
        switch activity {
        case .napping:
            return .init(pose: .resting, prompt: nil)
        case .hungry:
            return .init(pose: .idle, prompt: .carrot)
        case .lonely:
            return .init(pose: .idle, prompt: .heart)
        case .studying, .hopping:
            return .init(pose: .idle, prompt: nil)
        }
    }
}
