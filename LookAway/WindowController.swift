import Cocoa

class WindowController: NSWindowController {
    
    override func windowDidLoad() {
        super.windowDidLoad()
        window?.styleMask.remove(.titled)
        window?.styleMask.insert(.fullScreen)
        window?.isMovableByWindowBackground = true
        
        window?.isOpaque = false
        window?.backgroundColor = .init(red: 0, green: 0, blue: 0, alpha: 0.9)
    }
}
