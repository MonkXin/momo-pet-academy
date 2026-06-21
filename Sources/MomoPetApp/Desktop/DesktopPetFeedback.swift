import Foundation

enum DesktopPetFeedback: Equatable {
    case heart
    case carrot

    var duration: TimeInterval { 0.8 }

    var pose: DesktopPetPose {
        switch self {
        case .heart:
            return .petted
        case .carrot:
            return .fed
        }
    }

    static func forEvent(_ event: PetEvent) -> Self? {
        switch event {
        case .petted:
            return .heart
        case .fed:
            return .carrot
        default:
            return nil
        }
    }
}
