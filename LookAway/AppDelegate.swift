import Cocoa
import Foundation
import UserNotifications

@main
class AppDelegate: NSObject, NSApplicationDelegate {

    let statusBarItem: NSStatusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    
    var timeUntilBreak = 0
    var timer: Timer? = nil
    var windowControllers: [WindowController] = []
    
    var isPaused = false
    var pausedFor = 0
    let skipTimes = [10, 30, 60, 120]
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
        DockIcon.standard.setVisibility(false)
        
        // Initialize Timer
        resetTime()
        initTimer()
        requestNotificationAuthorization()
        
        // Add Menu
        let statusMenu: NSMenu = {
            let menu = NSMenu()
            
            let resetItem: NSMenuItem = {
                let item = NSMenuItem(
                    title: "Reset Active Timer",
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
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(screenParametersDidChange),
            name: NSApplication.didChangeScreenParametersNotification,
            object: nil
        )
    }
    
    @objc
    func showWindow() {
        NSApp.activate(ignoringOtherApps: true)
        NSApp.presentationOptions.insert(.autoHideDock)
        NSApp.presentationOptions.insert(.autoHideMenuBar)

        rebuildBreakWindows()
    }
    
    func closeWindow() {
        closeBreakWindows()
        NSApp.presentationOptions.remove(.autoHideDock)
        NSApp.presentationOptions.remove(.autoHideMenuBar)
        resetTime()
    }
    
    func showNotification(_ message: String) {
        let content = UNMutableNotificationContent()
        content.title = "Look Away"
        content.body = message

        let request = UNNotificationRequest(
            identifier: "look-away-break-warning",
            content: content,
            trigger: nil
        )
        UNUserNotificationCenter.current().add(request)
    }

    func requestNotificationAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert]) { _, _ in }
    }

    func rebuildBreakWindows() {
        closeBreakWindows()

        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        windowControllers = NSScreen.screens.compactMap { screen in
            guard let viewController = storyboard.instantiateController(
                withIdentifier: "ViewController"
            ) as? ViewController else {
                return nil
            }

            viewController.delegate = self
            let controller = WindowController(
                screen: screen,
                contentViewController: viewController
            )
            controller.window?.orderFrontRegardless()
            return controller
        }

        windowControllers.first(where: { $0.window?.screen == NSScreen.main })?
            .window?.makeKeyAndOrderFront(self)
    }

    func closeBreakWindows() {
        windowControllers.forEach { $0.close() }
        windowControllers.removeAll()
    }

    @objc
    func screenParametersDidChange() {
        guard !windowControllers.isEmpty else { return }
        rebuildBreakWindows()
    }
    
    func resetSkipStates() {
        // Remove a skip state if it already exists
        for menuItem in statusBarItem.menu!.items {
            if menuItem.state == .on {
                menuItem.state = .off
                break
            }
        }
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
                resetSkipStates()
            }
        } else {
            timeUntilBreak -= 1
            
            // 1 chunk of 20s left
            if timeUntilBreak == 1 {
                showNotification("20 seconds left for next break")
            }
            // 20 minutes over
            else if timeUntilBreak == 0 {
                UNUserNotificationCenter.current().removeAllDeliveredNotifications()
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
        if (isPaused) {
            resetSkipStates()
        }
        timer!.invalidate()
        
        let stime:Int = sender.representedObject as! Int
        isPaused = true
        pausedFor = stime * (60/20)
        initTimer()
        updateStatusText()
        sender.state = .on
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
