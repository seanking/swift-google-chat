import Cocoa
import SwiftUI
import OSLog
import UserNotifications

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    var window: NSWindow!

    fileprivate func requestAuthorizationForNotifications() {
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            let logger = Logger()
            logger.info("Granted: \(granted.description)")
            
            if let error = error {
                logger.error("Error occurred requesting notification center authorization.")
                logger.error("\(error.localizedDescription)")
            }
        }
    }
    
    fileprivate func createWindow() -> NSWindow {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 480, height: 300),
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered, defer: false)
        window.isReleasedWhenClosed = false
        window.center()
        window.setFrameAutosaveName("Main Window")
        window.contentView = NSHostingView(rootView: WebView())
        window.makeKeyAndOrderFront(nil)
        
        return window
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        window = createWindow()
        requestAuthorizationForNotifications()
    }
    
    func applicationDidBecomeActive(_ notification: Notification) {
        NSApplication.shared.dockTile.badgeLabel = ""
    }
    
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if !flag {
            window.makeKeyAndOrderFront(nil)
        }
        return true
    }
}
