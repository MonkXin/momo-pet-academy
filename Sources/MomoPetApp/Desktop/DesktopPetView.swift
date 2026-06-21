import SwiftUI

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
        .onTapGesture { store.dispatch(.petted) }
        .onTapGesture(count: 2, perform: openAcademy)
        .contextMenu {
            Button("喂食") { store.dispatch(.fed) }
            Button("休息") { store.dispatch(.rested) }
            Divider()
            Button("打开学堂", action: openAcademy)
            Button("退出", action: quit)
        }
        .accessibilityLabel("小白桌宠")
    }
}
