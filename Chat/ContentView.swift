import SwiftUI
import WebKit
import UserNotifications
import OSLog

struct WebBrowserView : NSViewRepresentable {
    
    let url: URL
    
    public func makeNSView(context: Context) -> WKWebView {
        let webConfiguration = WKWebViewConfiguration()
        
        if let script = notificationScript() {
            webConfiguration.userContentController.addUserScript(script)
            webConfiguration.userContentController.add(MessageHandler(), name: "notify")
        }
        
        let view = WKWebView(frame: .zero, configuration: webConfiguration)
        view.navigationDelegate = context.coordinator
        view.uiDelegate = context.coordinator
        view.autoresizingMask = [.width, .height]
        view.customUserAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 11_2_1) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.0.2 Safari/605.1.15"
        
        return view
    }
    
    public func updateNSView(_ nsView: WKWebView, context: Context) {
        nsView.load(URLRequest(url: url))
    }
    
    private func notificationScript() -> WKUserScript? {
        if let scriptUrl = Bundle.main.url(forResource: "Notification", withExtension: "js") {
            let sourceUrl = try! String(contentsOf: scriptUrl)
            return WKUserScript(source: sourceUrl, injectionTime: .atDocumentStart, forMainFrameOnly: false)
        }
        return nil
    }
    
    class Coordinator : NSObject, WKNavigationDelegate, WKUIDelegate {
        func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
            if let requestURL = navigationAction.request.url {
                print(requestURL.absoluteString)
                
                if let openURL = URL(string: requestURL.absoluteString) {
                    NSWorkspace.shared.open(openURL)
                }
                
            }
            return nil
        }
        
        func webView(_ webView: WKWebView, runOpenPanelWith parameters: WKOpenPanelParameters, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping ([URL]?) -> Void) {
            let openPanel = NSOpenPanel()
            openPanel.canChooseFiles = true
            openPanel.begin { result in
                if result == NSApplication.ModalResponse.OK {
                    if let url = openPanel.url {
                        completionHandler([url])
                    }
                } else if result == NSApplication.ModalResponse.cancel {
                    completionHandler(nil)
                }
            }
        }
    }
    
    func makeCoordinator() -> WebBrowserView.Coordinator {
        Coordinator()
    }
}

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

struct WebView: View {
    var body: some View {
        WebBrowserView(url: URL(string: "https://chat.google.com")!)
    }
}

struct WebBrowserViewDemo: PreviewProvider {
    static var previews: some View {
        WebBrowserView(url: URL(string: "https://chat.google.com")!)
    }
}
