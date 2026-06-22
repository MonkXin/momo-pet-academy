import SwiftUI

enum DesktopPetTapIntent: Equatable {
    case pet
    case openAcademy

    static func forTapCount(_ count: Int) -> Self {
        count >= 2 ? .openAcademy : .pet
    }
}

struct DesktopPetView: View {
    @ObservedObject var store: PetStore
    let openAcademy: () -> Void
    let quit: () -> Void
    @State private var feedback: DesktopPetFeedback?
    @State private var feedbackAtRest = false
    @State private var clearFeedbackWorkItem: DispatchWorkItem?
    @State private var displayedStatePrompt: DesktopPetFeedback?

    private var statePresentation: DesktopPetStatePresentation {
        DesktopPetStatePresentation.forActivity(PetActivity.current(for: store.profile))
    }

    var body: some View {
        ZStack {
            Group {
                if let image = PetVisualAsset.desktopPetImage(for: feedback?.pose ?? statePresentation.pose) {
                    Image(nsImage: image)
                        .resizable()
                        .scaledToFit()
                } else {
                    Image(systemName: "photo")
                        .font(.system(size: 52))
                        .foregroundColor(.secondary)
                }
            }

            if let feedback {
                feedbackOverlay(feedback)
            }
        }
        .contentShape(Rectangle())
        .gesture(
            TapGesture(count: 2)
                .onEnded { perform(.openAcademy) }
                .exclusively(before: TapGesture().onEnded { perform(.pet) })
        )
        .contextMenu {
            Button("喂食") {
                store.dispatch(.fed)
                showFeedback(for: .fed)
            }
            Button("休息") { store.dispatch(.rested) }
            Divider()
            Button("打开学堂", action: openAcademy)
            Button("退出", action: quit)
        }
        .accessibilityLabel("小白桌宠")
        .onChange(of: statePresentation) { presentation in
            guard presentation.prompt != displayedStatePrompt else { return }
            displayedStatePrompt = presentation.prompt
            guard feedback == nil, let prompt = presentation.prompt else { return }
            showFeedback(prompt)
        }
        .onDisappear {
            clearFeedbackWorkItem?.cancel()
            clearFeedbackWorkItem = nil
            feedback = nil
        }
    }

    private func perform(_ intent: DesktopPetTapIntent) {
        switch intent {
        case .pet:
            store.dispatch(.petted)
            showFeedback(for: .petted)
        case .openAcademy:
            openAcademy()
        }
    }

    private func showFeedback(for event: PetEvent) {
        guard let nextFeedback = DesktopPetFeedback.forEvent(event) else { return }
        showFeedback(nextFeedback)
    }

    private func showFeedback(_ nextFeedback: DesktopPetFeedback) {

        clearFeedbackWorkItem?.cancel()
        feedback = nextFeedback
        feedbackAtRest = false

        DispatchQueue.main.async {
            guard feedback == nextFeedback else { return }
            withAnimation(.easeOut(duration: nextFeedback.duration)) {
                feedbackAtRest = true
            }
        }

        let cleanup = DispatchWorkItem {
            withAnimation(.easeIn(duration: 0.16)) {
                feedback = nil
                feedbackAtRest = false
            }
        }
        clearFeedbackWorkItem = cleanup
        DispatchQueue.main.asyncAfter(deadline: .now() + nextFeedback.duration, execute: cleanup)
    }

    @ViewBuilder
    private func feedbackOverlay(_ feedback: DesktopPetFeedback) -> some View {
        Image(systemName: feedback == .heart ? "heart" : "carrot.fill")
            .font(.system(size: feedback == .heart ? 42 : 32, weight: .medium))
            .foregroundStyle(feedback == .heart ? Color.pink : Color.orange)
            .offset(feedbackOffset(for: feedback))
            .opacity(feedbackAtRest ? 0 : 1)
            .allowsHitTesting(false)
    }

    private func feedbackOffset(for feedback: DesktopPetFeedback) -> CGSize {
        switch feedback {
        case .heart:
            return CGSize(width: 0, height: feedbackAtRest ? -78 : -22)
        case .carrot:
            return CGSize(width: feedbackAtRest ? 2 : 84, height: 32)
        }
    }
}
