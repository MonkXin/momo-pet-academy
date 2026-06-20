import SwiftUI

enum RabbitPortraitCopy {
    static func accessibilityLabel(for activity: PetActivity) -> String {
        let description: String
        switch activity {
        case .studying: description = "认真学习中"
        case .hopping: description = "开心蹦跳中"
        case .napping: description = "午睡中"
        case .hungry: description = "肚子咕咕叫"
        case .lonely: description = "想要摸摸"
        }
        return "小白的 3D 形象，当前：\(description)"
    }
}

struct RabbitPortraitView: View {
    let profile: PetProfile
    let size: CGFloat

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var breathing = false
    @State private var swaying = false
    @State private var blinking = false
    @State private var blinkWorkItem: DispatchWorkItem?

    private var activity: PetActivity { PetActivity.current(for: profile) }
    private var motion: PetMotionProfile { .forActivity(activity) }

    var body: some View {
        Group {
            if let image = PetVisualAsset.masterImage() {
                Image(nsImage: image)
                    .resizable()
                    .scaledToFit()
            } else {
                Image(systemName: "photo")
                    .font(.system(size: size * 0.3))
                    .foregroundColor(.secondary)
            }
        }
        .scaleEffect(reduceMotion ? 1 : (breathing ? motion.breathingScale : 1))
        .rotationEffect(.degrees(reduceMotion ? 0 : (swaying ? motion.swayAngle : -motion.swayAngle)))
        .overlay(blinkOverlay)
        .overlay(emphasisOverlay)
        .accessibilityLabel(RabbitPortraitCopy.accessibilityLabel(for: activity))
        .onAppear(perform: startMotionIfAllowed)
        .onDisappear { blinkWorkItem?.cancel() }
        .onChange(of: activity) { _ in startMotionIfAllowed() }
    }

    @ViewBuilder
    private var blinkOverlay: some View {
        if blinking {
            Capsule()
                .fill(Color.white.opacity(0.92))
                .frame(width: size * 0.42, height: max(5, size * 0.035))
                .offset(y: -size * 0.12)
                .transition(.opacity)
        }
    }

    @ViewBuilder
    private var emphasisOverlay: some View {
        switch motion.emphasis {
        case .none:
            EmptyView()
        case .restful:
            RoundedRectangle(cornerRadius: size * 0.12, style: .continuous)
                .fill(Color.blue.opacity(0.05))
        case .needsCare:
            RoundedRectangle(cornerRadius: size * 0.12, style: .continuous)
                .stroke(Color.orange.opacity(0.6), lineWidth: 2)
        case .affection:
            RoundedRectangle(cornerRadius: size * 0.12, style: .continuous)
                .stroke(Color.pink.opacity(0.62), lineWidth: 2)
        }
    }

    private func startMotionIfAllowed() {
        blinkWorkItem?.cancel()
        guard !reduceMotion else {
            breathing = false
            swaying = false
            return
        }
        breathing = false
        swaying = false
        withAnimation(.easeInOut(duration: motion.breathingDuration).repeatForever(autoreverses: true)) {
            breathing = true
        }
        if motion.swayAngle != 0 {
            withAnimation(.easeInOut(duration: motion.breathingDuration * 1.4).repeatForever(autoreverses: true)) {
                swaying = true
            }
        }
        scheduleBlink()
    }

    private func scheduleBlink() {
        let workItem = DispatchWorkItem {
            withAnimation(.easeOut(duration: 0.08)) { blinking = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.14) {
                withAnimation(.easeIn(duration: 0.08)) { blinking = false }
                scheduleBlink()
            }
        }
        blinkWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + motion.blinkInterval, execute: workItem)
    }
}
