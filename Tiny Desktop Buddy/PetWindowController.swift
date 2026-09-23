import AppKit
import SwiftUI

final class PetWindowController {

    private var window: NSWindow?
    private let behaviorEngine = PetBehaviorEngine()

    func show() {
        let petView = NSHostingView(
            rootView: ContentView(engine: behaviorEngine)
        )

        let window = DraggablePetWindow(
            contentRect: NSRect(
                x: 300,
                y: 300,
                width: 260,
                height: 260
            ),
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )

        window.behaviorEngine = behaviorEngine
        behaviorEngine.window = window

        window.contentView = petView

        // Transparent window
        window.backgroundColor = .clear
        window.isOpaque = false

        // Keep pet above normal windows and menu bar
        window.level = .statusBar

        // Show across all Spaces including full screen
        window.collectionBehavior = [
            .canJoinAllSpaces,
            .fullScreenAuxiliary
        ]

        // Allow mouse interaction
        window.ignoresMouseEvents = false

        // Remove window shadow
        window.hasShadow = false

        window.makeKeyAndOrderFront(nil)

        self.window = window
    }
}


// MARK: - Draggable Pet Window

final class DraggablePetWindow: NSWindow {

    weak var behaviorEngine: PetBehaviorEngine?

    private var initialMouseLocation: NSPoint = .zero
    private var initialWindowOrigin: NSPoint = .zero
    private var hasDragged = false

    override var canBecomeKey: Bool {
        true
    }

    override var canBecomeMain: Bool {
        true
    }

    // Allow window to be dragged anywhere, including over the menu bar area
    override func constrainFrameRect(_ frameRect: NSRect, to screen: NSScreen?) -> NSRect {
        frameRect
    }

    override func mouseDown(with event: NSEvent) {
        initialMouseLocation = NSEvent.mouseLocation
        initialWindowOrigin = frame.origin
        hasDragged = false
    }

    override func mouseDragged(with event: NSEvent) {
        hasDragged = true
        behaviorEngine?.userStartedDragging()

        let currentMouseLocation = NSEvent.mouseLocation

        let deltaX = currentMouseLocation.x - initialMouseLocation.x
        let deltaY = currentMouseLocation.y - initialMouseLocation.y

        let newOrigin = NSPoint(
            x: initialWindowOrigin.x + deltaX,
            y: initialWindowOrigin.y + deltaY
        )

        setFrameOrigin(newOrigin)
    }

    override func mouseUp(with event: NSEvent) {
        if hasDragged {
            behaviorEngine?.userStoppedDragging()
        }
        hasDragged = false
    }
}
