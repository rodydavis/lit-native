//
//  WebView.swift
//  app
//
//  Created by Rody Davis on 6/16/21.
//

import Foundation
import SwiftUI
import WebKit

#if os(macOS)
import AppKit
import Cocoa

struct Webview: NSViewRepresentable {
    typealias NSViewType = WKWebView
    
    let prefs: WebConfig
    let webviewController = WebViewController()
    
    func makeNSView(context: Context) -> WKWebView {
        webviewController.prefs = self.prefs
        webviewController.loadContent()
        return webviewController.webview
    }
    
    func updateNSView(_ nsView: WKWebView, context: Context) {
        webviewController.loadContent()
    }
}

class WebViewController: NSViewController, WKNavigationDelegate, WKUIDelegate, WKScriptMessageHandler {
    lazy var prefs: WebConfig = createWebView()
    lazy var webview: WKWebView = WKWebView()
    var urlObservation: NSKeyValueObservation?
    var titleObservation: NSKeyValueObservation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.webview.frame = self.view.frame
        self.webview.navigationDelegate = self
        self.webview.uiDelegate = self
        self.view.addSubview(self.webview)
        titleObservation = self.webview.observe(\.title, changeHandler: { (webView, change) in
            if let title = self.webview.title {
                if self.prefs.title != title {
                    self.prefs.title = title
                }
            }
        })
        self.webview.configuration.userContentController.add(self, name: "handler")
    }
    
    func loadContent() {
        loadLocal(self.webview, prefs: self.prefs)
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        prefs.events.handler(self.webview, message: message)
    }
}

#elseif os(iOS)

struct Webview: UIViewControllerRepresentable {
    let prefs: WebConfig
    
    func makeUIViewController(context: Context) -> WebViewController {
        let webviewController = WebViewController()
        webviewController.prefs = self.prefs
        webviewController.loadContent()
        return webviewController
    }
    
    func updateUIViewController(_ webviewController: WebViewController, context: Context) {
        webviewController.loadContent()
    }
}

class WebViewController: UIViewController, WKNavigationDelegate, WKUIDelegate, WKScriptMessageHandler {
    
    lazy var prefs: WebConfig = WebConfig()
    lazy var webview: WKWebView = createWebView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.webview.frame = self.view.frame
        self.webview.navigationDelegate = self
        self.webview.uiDelegate = self
        self.view.addSubview(self.webview)
        self.webview.configuration.userContentController.add(self, name: "handler")
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        switch keyPath {
        case "title":
            if let title = self.webview.title {
                if self.prefs.title != title {
                    self.prefs.title = title
                }
            }
        default:
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }

    func loadContent() {
        loadLocal(webview, prefs: self.prefs)
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        prefs.events.handler(self.webview, message: message)
    }
}


#endif

func createWebView() -> WKWebView {
    let webview = WKWebView()
    webview.translatesAutoresizingMaskIntoConstraints = false
    webview.configuration.allowsInlineMediaPlayback = false
    webview.configuration.mediaTypesRequiringUserActionForPlayback = []
    webview.scrollView.bounces = false
    webview.scrollView.isScrollEnabled = false
    webview.isOpaque = false
    webview.isHidden = false
   return webview
}



func loadRemote(_ webview: WKWebView, url: URL) {
    let request = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad)
    webview.load(request)
}

func loadLocal(_ webview: WKWebView, prefs: WebConfig) {
    webview.configuration.defaultWebpagePreferences.allowsContentJavaScript = true
    let bundle = AppBundle(prefs: prefs)
    addScript(webview, source: bundle.get())
    addScript(webview, source: prefs.events.script())
    webview.loadHTMLString(getHTML(tagname: "my-element", title: prefs.title), baseURL: URL(string: prefs.url))
}

func addScript(_ webview: WKWebView, source: String) {
    let script = WKUserScript(source: source, injectionTime: .atDocumentEnd, forMainFrameOnly: false)
    webview.configuration.userContentController.addUserScript(script)
}

func getHTML(tagname: String, title: String = "", slot: String = "") -> String {
    return """
    <!DOCTYPE html>
    <html lang="en">
      <head>
        <meta charset="UTF-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1.0" />
        <title>\(title)</title>
      </head>
      <body>
        <\(tagname)>
            \(slot)
        </\(tagname)>
      </body>
    </html>
    """
}

extension Calendar {
    public func daysSince(date: Date) -> Int? {
        return self.dateComponents([.day], from: date, to: Date()).day
    }
}
