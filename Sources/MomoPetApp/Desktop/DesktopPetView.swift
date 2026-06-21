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

    var body: some View {
        Group {
            if let image = PetVisualAsset.desktopPetImage() {
                Image(nsImage: image)
                    .resizable()
                    .scaledToFit()
            } else {
                Image(systemName: "photo")
                    .font(.system(size: 52))
                    .foregroundColor(.secondary)
            }
        }
        .contentShape(Rectangle())
        .gesture(
            TapGesture(count: 2)
                .onEnded { perform(.openAcademy) }
                .exclusively(before: TapGesture().onEnded { perform(.pet) })
        )
        .contextMenu {
            Button("喂食") { store.dispatch(.fed) }
            Button("休息") { store.dispatch(.rested) }
            Divider()
            Button("打开学堂", action: openAcademy)
            Button("退出", action: quit)
        }
        .accessibilityLabel("小白桌宠")
    }

    private func perform(_ intent: DesktopPetTapIntent) {
        switch intent {
        case .pet: store.dispatch(.petted)
        case .openAcademy: openAcademy()
        }
    }
}
