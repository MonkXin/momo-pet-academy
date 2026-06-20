import SwiftUI

enum PetMotionEmphasis: Equatable {
    case none
    case restful
    case needsCare
    case affection
}

struct PetMotionProfile: Equatable {
    let breathingDuration: Double
    let breathingScale: CGFloat
    let swayAngle: Double
    let blinkInterval: Double
    let emphasis: PetMotionEmphasis

    static func forActivity(_ activity: PetActivity) -> Self {
        switch activity {
        case .studying:
            return .init(breathingDuration: 3.8, breathingScale: 1.012, swayAngle: 0.5, blinkInterval: 6.0, emphasis: .none)
        case .hopping:
            return .init(breathingDuration: 2.8, breathingScale: 1.018, swayAngle: 1.3, blinkInterval: 4.5, emphasis: .none)
        case .napping:
            return .init(breathingDuration: 5.2, breathingScale: 1.006, swayAngle: 0, blinkInterval: 9.0, emphasis: .restful)
        case .hungry:
            return .init(breathingDuration: 3.2, breathingScale: 1.014, swayAngle: -0.8, blinkInterval: 5.0, emphasis: .needsCare)
        case .lonely:
            return .init(breathingDuration: 3.0, breathingScale: 1.015, swayAngle: 1.0, blinkInterval: 4.0, emphasis: .affection)
        }
    }
}
