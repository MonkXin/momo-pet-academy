import Foundation

enum DesktopPetFeedback: Equatable {
    case heart
    case carrot
    case rest
    case study

    var duration: TimeInterval { self == .study ? 1.2 : 0.8 }

    var pose: DesktopPetPose {
        switch self {
        case .heart:
            return .petted
        case .carrot:
            return .fed
        case .rest:
            return .resting
        case .study:
            return .idle
        }
    }

    static func forEvent(_ event: PetEvent) -> Self? {
        switch event {
        case .petted:
            return .heart
        case .fed:
            return .carrot
        case .rested:
            return .rest
        case .weeklyGrowthPromptAcknowledged:
            return .study
        default:
            return nil
        }
    }
}
