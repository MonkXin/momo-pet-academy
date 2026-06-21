import AppKit
import SwiftUI

final class DesktopPetWindowController: NSObject, NSWindowDelegate {
    static let shared = DesktopPetWindowController()

    private let positionKey = "momoPetDesktopPosition"
    private let petSize = NSSize(width: 260, height: 300)
    private var panel: NSPanel?

    func show(store: PetStore, openAcademy: @escaping () -> Void) {
        let panel = panel ?? makePanel()
        let view = DesktopPetView(
            store: store,
            openAcademy: { [weak self] in
                self?.hide()
                openAcademy()
            },
            quit: { NSApp.terminate(nil) }
        )
        panel.contentView = NSHostingView(rootView: view)
        restorePosition(for: panel)
        panel.orderFrontRegardless()
    }

    func hide() {
        panel?.orderOut(nil)
    }

    func windowDidMove(_ notification: Notification) {
        guard let panel else { return }
        let position = PetPosition(x: panel.frame.origin.x, y: panel.frame.origin.y)
        guard let data = try? JSONEncoder().encode(position) else { return }
        UserDefaults.standard.set(data, forKey: positionKey)
    }

    private func makePanel() -> NSPanel {
        let panel = NSPanel(
            contentRect: NSRect(origin: .zero, size: petSize),
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        panel.level = .floating
        panel.isOpaque = false
        panel.backgroundColor = .clear
        panel.hasShadow = false
        panel.isMovableByWindowBackground = true
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .stationary]
        panel.delegate = self
        self.panel = panel
        return panel
    }

    private func restorePosition(for panel: NSPanel) {
        let saved = UserDefaults.standard.data(forKey: positionKey)
            .flatMap { try? JSONDecoder().decode(PetPosition.self, from: $0) }
            ?? .defaultPosition
        let visible = (NSScreen.main ?? NSScreen.screens[0]).visibleFrame
        let position = saved.clamped(
            in: PetFrame(x: visible.origin.x, y: visible.origin.y, width: visible.width, height: visible.height),
            petSize: PetSize(width: petSize.width, height: petSize.height)
        )
        panel.setFrameOrigin(NSPoint(x: position.x, y: position.y))
    }
}
