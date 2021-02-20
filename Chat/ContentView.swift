//
//  ContentView.swift
//  Chat
//
//  Created by Sean King on 2/19/21.
//

import SwiftUI
import WebKit

struct WebBrowserView : NSViewRepresentable {
    
    let url: URL
    
    public func makeNSView(context: Context) -> WKWebView {
        let webConfiguration = WKWebViewConfiguration()
        webConfiguration.applicationNameForUserAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 11_2_1) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.0.2 Safari/605.1.15"
        
        let view = WKWebView(frame: .zero, configuration: webConfiguration)
        view.navigationDelegate = context.coordinator
        view.uiDelegate = context.coordinator
        view.autoresizingMask = [.width, .height]
        
        return view
        
    }
    
    public func updateNSView(_ nsView: WKWebView, context: Context) {
        nsView.load(URLRequest(url: url))
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
    }
    
    func makeCoordinator() -> WebBrowserView.Coordinator {
        Coordinator()
    }
    
}

struct WebBrowserViewDemo: PreviewProvider {
    static var previews: some View {
        WebBrowserView(url: URL(string: "https://chat.google.com")!)
    }
}
