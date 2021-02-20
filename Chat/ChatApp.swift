//
//  ChatApp.swift
//  Chat
//
//  Created by Sean King on 2/19/21.
//

import AppKit
import SwiftUI

final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationWillFinishLaunching(_ notification: Notification) {
        
        NSApplication.shared.windows.forEach { window in
            window.setFrameAutosaveName("Main Window")
            window.isReleasedWhenClosed = false
        }
    }
}

@main
struct ChatApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var delegate
    var body: some Scene {
        WindowGroup {
            WebBrowserView(url: URL(string: "https://chat.google.com")!)
        }
    }
}
