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
    @AppStorage("milkteaHasSeenDesktopPetHint") private var hasSeenDesktopPetHint = false

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

            if !hasSeenDesktopPetHint {
                Text("双击奶茶打开学堂\n右键可照料或退出")
                    .font(.caption.bold())
                    .multilineTextAlignment(.center)
                    .padding(8)
                    .background(.white.opacity(0.9), in: RoundedRectangle(cornerRadius: 10))
                    .offset(y: -110)
                    .allowsHitTesting(false)
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
            Button("休息") {
                store.dispatch(.rested)
                showFeedback(for: .rested)
            }
            Divider()
            Button("打开学堂", action: openAcademy)
            Button("退出", action: quit)
        }
        .accessibilityLabel("奶茶桌宠")
        .onChange(of: statePresentation) { presentation in
            guard presentation.prompt != displayedStatePrompt else { return }
            displayedStatePrompt = presentation.prompt
            guard feedback == nil, let prompt = presentation.prompt else { return }
            showFeedback(prompt)
        }
        .onChange(of: store.profile) { _ in
            showWeeklyGrowthPromptIfNeeded()
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
            hasSeenDesktopPetHint = true
            store.dispatch(.petted)
            showFeedback(for: .petted)
        case .openAcademy:
            hasSeenDesktopPetHint = true
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

    private func showWeeklyGrowthPromptIfNeeded() {
        guard feedback == nil,
              let milestone = store.profile.nextWeeklyGrowthMilestone,
              !store.profile.announcedWeeklyGrowthMilestones.contains(milestone) else { return }
        let period = StudyPeriod.current()
        store.dispatch(.weeklyGrowthPromptAcknowledged(milestone, period: period))
        showFeedback(.study)
    }

    @ViewBuilder
    private func feedbackOverlay(_ feedback: DesktopPetFeedback) -> some View {
        Image(systemName: feedback == .heart ? "heart" : feedback == .carrot ? "carrot.fill" : feedback == .rest ? "zzz" : "book.closed.fill")
            .font(.system(size: feedback == .heart ? 42 : 32, weight: .medium))
            .foregroundStyle(feedback == .heart ? Color.pink : feedback == .carrot ? Color.orange : feedback == .rest ? Color.blue : Color.purple)
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
        case .rest:
            return CGSize(width: 46, height: feedbackAtRest ? -48 : -18)
        case .study:
            return CGSize(width: 46, height: -42)
        }
    }
}
