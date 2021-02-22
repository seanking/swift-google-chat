//
//  ChatApp.swift
//  Chat
//
//  Created by Sean King on 2/19/21.
//

import Cocoa
import SwiftUI


@main
class AppDelegate: NSObject, NSApplicationDelegate {
    var window: NSWindow!


    func applicationDidFinishLaunching(_ aNotification: Notification) {
        let contentView = WebView()

        window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 480, height: 300),
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered, defer: false)
        window.isReleasedWhenClosed = false
        window.center()
        window.setFrameAutosaveName("Main Window")
        window.contentView = NSHostingView(rootView: contentView)
        window.makeKeyAndOrderFront(nil)
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


//final class AppDelegate: NSObject, NSApplicationDelegate {
//    func applicationWillFinishLaunching(_ notification: Notification) {
//
//        NSApplication.shared.windows.forEach { window in
//            window.setFrameAutosaveName("Main Window")
//            window.isReleasedWhenClosed = false
//        }
//    }
//
//    func applicationDidBecomeActive(_ notification: Notification) {
//        NSApplication.shared.dockTile.badgeLabel = nil
//    }
//
//}
//
//@main
//struct ChatApp: App {
//    @NSApplicationDelegateAdaptor(AppDelegate.self) var delegate
//    var body: some Scene {
//        WindowGroup {
//            WebBrowserView(url: URL(string: "https://chat.google.com")!)
//        }
//    }
//}

