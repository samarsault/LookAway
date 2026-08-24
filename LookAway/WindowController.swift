import Cocoa

final class WindowController: NSWindowController {
    convenience init(screen: NSScreen, contentViewController: NSViewController) {
        let window = NSWindow(
            contentRect: screen.frame,
            styleMask: BreakWindowConfiguration.styleMask,
            backing: .buffered,
            defer: false,
            screen: screen
        )

        self.init(window: window)
        window.contentViewController = contentViewController
        BreakWindowConfiguration.apply(to: window, on: screen)
    }
}
