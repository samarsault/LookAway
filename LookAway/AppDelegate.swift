import Cocoa
import Foundation

struct Constants {
    static let resume = "Resume"
    static let pause = "Pause"
    static let maxTime = 2
}

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    let statusBarItem: NSStatusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    
    var timeUntilBreak = 0
    var timer: Timer? = nil
    var windowController: NSWindowController? = nil
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
        DockIcon.standard.setVisibility(false)
        
        // Initialize Timer
        resetTime()
        initTimer()
        
        // Add Menu
        let statusMenu: NSMenu = {
            let menu = NSMenu()
            let pauseItem: NSMenuItem = {
                let item = NSMenuItem(
                    title: "Pause",
                    action: #selector(pauseTimer),
                    keyEquivalent: ""
                )
                
                item.tag = 1
                item.target = self
                
                return item
            }()
            
            let quitItem: NSMenuItem = {
                let item = NSMenuItem(
                    title: "Quit",
                    action: #selector(quitApp),
                    keyEquivalent: ""
                )
                
                item.tag = 2
                item.target = self
                
                return item
            }()
            
            menu.addItem(pauseItem)
            menu.addItem(.separator())
            menu.addItem(quitItem)
            
            return menu
        }()
        
        statusBarItem.menu = statusMenu
        
        // Initialize  Window
        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        
        if let localWC = storyboard.instantiateController(withIdentifier: "WindowController") as? NSWindowController {
            let vc = localWC.contentViewController as? ViewController
            vc?.delegate = self
            windowController = localWC
        }
    }
    
    @objc
    func showWindow() {
        NSApp.activate(ignoringOtherApps: true)
        NSApp.presentationOptions.insert(.autoHideDock)
        NSApp.presentationOptions.insert(.autoHideMenuBar)
        
        windowController?.showWindow(self)
        
        // This is required to hide menu properly
        windowController?.window?.level = .mainMenu + 1
    }
    
    func closeWindow() {
        windowController?.close()
        NSApp.presentationOptions.remove(.autoHideDock)
        NSApp.presentationOptions.remove(.autoHideMenuBar)
        resetTime()
    }
    
    func showNotification(_ message: String) {
        let notif = NSUserNotification()
        notif.title = "Look Away"
        notif.informativeText = ""
        notif.subtitle = message
        NSUserNotificationCenter.default.deliver(notif)
    }

}

//
// Timer
//
extension AppDelegate {
    func initTimer() {
        timer = Timer.scheduledTimer(
            timeInterval: 20,
            target: self,
            selector: #selector(timerTick),
            userInfo: nil,
            repeats: true
        )
    }
    
    func resetTime() {
        // Number of intervals of 20 seconds in 20 mins
        timeUntilBreak = 20 * (60 / 20)
        updateStatusText()
    }
    
    @objc
    func timerTick(_ sender: Timer) {
        timeUntilBreak -= 1
        updateStatusText()
        
        // 1 chunk of 20s left
        if timeUntilBreak == 1 {
            showNotification("20 seconds left for next break")
        }
            // 20 minutes over
        else if timeUntilBreak == 0 {
            showWindow()
        }
            // 20s passed after showing window
        else if timeUntilBreak == -1 {
            showNotification("Well Done!")
            // Hide window
            closeWindow()
        }
    }
    
    func updateStatusText() {
        guard let statusButton = statusBarItem.button else { return }
        var intervalsToMin:Int = timeUntilBreak/3
        if timeUntilBreak % 3 != 0{
            intervalsToMin += 1
        }
        statusButton.title = "👁️ \(intervalsToMin) min"
    }
}

//
// Menu Items
//
extension AppDelegate {
    @objc
    func quitApp(_ sender: NSMenuItem) {
        NSApp.terminate(sender)
    }
    
    @objc
    func pauseTimer(_ sender: NSMenuItem) {
        if sender.title == Constants.pause {
            timer!.invalidate()
            sender.title = Constants.resume
        }
        else if sender.title == Constants.resume {
            initTimer()
            sender.title = Constants.pause
        }
        resetTime()
    }
}

// Events
extension AppDelegate : VCDelegate {
    func onSkip(_ sender: NSButton) {
        closeWindow()
    }
}
