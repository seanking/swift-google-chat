//
//  MessageHandler.swift
//  Chat
//
//  Created by Sean King on 3/13/21.
//

import Foundation
import WebKit
import UserNotifications
import OSLog

class MessageHandler : NSObject, WKScriptMessageHandler {
    
    fileprivate func displayNotification(_ message: WKScriptMessage) {
        if let messageBody = message.body as? [String: Any],
           let title = messageBody["title"] as? String,
           let subtitle = messageBody["subtitle"] as? String,
           let icon = messageBody["icon"] as? String {
            
            let content = UNMutableNotificationContent()
            content.title = title
            content.subtitle = subtitle
            content.sound = UNNotificationSound.default
            
            if let url = URL(string: icon) {
                if let image = NSImage(contentsOf: url) {
                    let attachment = UNNotificationAttachment.create(identifier: url.lastPathComponent, image: image, options: nil)
                    if let attachment = attachment {
                        content.attachments = [attachment]
                    }
                }
            }
            
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
            UNUserNotificationCenter.current().add(request)
        }
    }
    
    fileprivate func updateBadge() {
        let badge = NSApplication.shared.dockTile.badgeLabel ?? "0"
        let count = Int(badge) ?? 0
        NSApplication.shared.dockTile.badgeLabel = String(count + 1)
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        
        if !NSApplication.shared.isActive {
            updateBadge()
            displayNotification(message)
        }
    }
}

extension UNNotificationAttachment {
    static func create(identifier: String, image: NSImage, options: [NSObject : AnyObject]?) -> UNNotificationAttachment? {
        let logger = Logger()
        do {
            if let cachesDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first {
                let imageFileIdentifier = "\(identifier).png"
                let fileURL = cachesDirectory.appendingPathComponent(imageFileIdentifier)
                
                if !FileManager.default.fileExists(atPath: fileURL.path) {
                    logger.debug("File not found in cache: \(fileURL.path)")
                    try image.pngWrite(to: fileURL)
                    logger.debug("Saved file to cache: \(fileURL.path)")
                } else {
                    logger.debug("File loaded from cache: \(fileURL.path)")
                }
                
                return try UNNotificationAttachment.init(identifier: imageFileIdentifier, url: fileURL, options: options)
            }
        } catch {
            logger.error("Error creating temporary images. \(error.localizedDescription)")
        }
        
        return nil
    }
}

extension NSImage {
    func pngWrite(to url: URL, options: Data.WritingOptions = .atomic) throws {
        if let tiffRepresentation = tiffRepresentation, let bitmapImage = NSBitmapImageRep(data: tiffRepresentation) {
            if let png = bitmapImage.representation(using: .png, properties: [:]) {
                try png.write(to: url, options: options)
            }
        }
    }
}
