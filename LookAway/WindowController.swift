import Cocoa

final class WindowController: NSWindowController {
    convenience init(screen: NSScreen, contentViewController: NSViewController) {
        let window = NSWindow(
            contentRect: screen.frame,
            styleMask: .borderless,
            backing: .buffered,
            defer: false,
            screen: screen
        )

        self.init(window: window)
        window.contentViewController = contentViewController
        window.setFrame(screen.frame, display: false)
        window.level = .screenSaver
        if #available(macOS 13.0, *) {
            window.collectionBehavior = .canJoinAllApplications
        } else {
            window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        }
        window.isOpaque = false
        window.backgroundColor = NSColor.black.withAlphaComponent(0.9)
    }
}
