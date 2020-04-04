import Cocoa
import Foundation

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    let statusBarItem: NSStatusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    
    var timeUntilBreak = 0
    var timer: Timer? = nil
    var windowController: NSWindowController? = nil
    
    var isPaused = false
    var pausedFor = 0
    let skipTimes = [10, 30, 60, 120]
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
        DockIcon.standard.setVisibility(false)
        
        // Initialize Timer
        resetTime()
        initTimer()
        
        // Add Menu
        let statusMenu: NSMenu = {
            let menu = NSMenu()
            
            let resetItem: NSMenuItem = {
                let item = NSMenuItem(
                    title: "Reset",
                    action: #selector(resetTimer),
                    keyEquivalent: ""
                )
                item.target = self
                
                return item
            }()
            
            menu.addItem(resetItem)
            menu.addItem(.separator())
            let skipItem: NSMenuItem = {
                let item = NSMenuItem(
                    title: "Skip For",
                    action: nil,
                    keyEquivalent: ""
                )
                
                item.tag = 1
                item.target = self
                item.isEnabled  = false
                return item
            }()
            
            menu.addItem(skipItem)
            
            for stime in skipTimes {
                var menuTitle = ""
                
                if stime >= 60 {
                    menuTitle = "\(stime/60) hour(s)"
                } else {
                    menuTitle = "\(stime) min(s)"
                }
                
                let item:NSMenuItem = NSMenuItem(
                    title: menuTitle,
                    action: #selector(skipTimer),
                    keyEquivalent: ""
                )
                item.representedObject = stime
                item.target = self
                item.indentationLevel = 1
                menu.addItem(item)
            }
          
            
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
        updateStatusText()
        if (isPaused) {
            pausedFor-=1
            if pausedFor == 0 {
                isPaused = false
            }
        } else {
            timeUntilBreak -= 1
            
            
            // 1 chunk of 20s left
            if timeUntilBreak == 1 {
                showNotification("20 seconds left for next break")
            }
            // 20 minutes over
            else if timeUntilBreak == 0 {
                NSUserNotificationCenter.default.removeAllDeliveredNotifications()
                showWindow()
            }
            // 20s passed after showing window
            else if timeUntilBreak == -1 {
                NSSound(named: "Purr")?.play()
                closeWindow()
            }
        }
    }
    
    func updateStatusText() {
        guard let statusButton = statusBarItem.button else { return }
        if isPaused {
            statusButton.title = "👁️ Paused"
        } else {
            var intervalsToMin:Int = timeUntilBreak/3
            if timeUntilBreak % 3 != 0{
                intervalsToMin += 1
            }
            statusButton.title = "👁️ \(intervalsToMin) min"
        }
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
    func skipTimer(_ sender: NSMenuItem) {
        timer!.invalidate()
        let stime:Int = sender.representedObject as! Int
        isPaused = true
        pausedFor = stime * (60/20)
        initTimer()
        updateStatusText()
    }
    
    @objc
    func resetTimer(_ sender: NSMenuItem) {
        resetTime()
    }
}

// Events
extension AppDelegate : VCDelegate {
    func onSkip(_ sender: NSButton) {
        closeWindow()
    }
}
