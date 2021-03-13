import SwiftUI
import WebKit

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
            
            let notification = NSUserNotification()
            notification.title = title
            notification.subtitle = subtitle
            
            if let url = URL(string: icon) {
                if let image = NSImage(contentsOf: url) {
                    notification.contentImage = image
                }
            }
            
            notification.soundName = NSUserNotificationDefaultSoundName
            NSUserNotificationCenter.default.deliver(notification)
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
