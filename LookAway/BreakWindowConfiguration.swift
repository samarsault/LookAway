import AppKit

enum BreakWindowConfiguration {
    static let styleMask: NSWindow.StyleMask = .borderless
    static let level: NSWindow.Level = .screenSaver

    static func collectionBehavior(
        for version: OperatingSystemVersion = ProcessInfo.processInfo.operatingSystemVersion
    ) -> NSWindow.CollectionBehavior {
        var behavior: NSWindow.CollectionBehavior = [.stationary, .ignoresCycle]

        if #available(macOS 13.0, *), version.majorVersion >= 13 {
            behavior.insert(.canJoinAllApplications)
        } else {
            behavior.formUnion([.canJoinAllSpaces, .fullScreenAuxiliary])
        }

        return behavior
    }

    static func apply(to window: NSWindow, on screen: NSScreen) {
        window.styleMask = styleMask
        window.level = level
        window.collectionBehavior = collectionBehavior()
        window.setFrame(screen.frame, display: false)
        window.isOpaque = false
        window.backgroundColor = NSColor.black.withAlphaComponent(0.9)
        window.hasShadow = false
        window.hidesOnDeactivate = false
        window.isReleasedWhenClosed = false
    }
}
