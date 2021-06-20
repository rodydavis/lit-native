//
//  WebView.swift
//  app
//
//  Created by Rody Davis on 6/16/21.
//

import Foundation
import SwiftUI
import WebKit

struct Webview: UIViewControllerRepresentable {
    let state: AppState
    let tag: String
    let vc = WebViewController()
    
    func makeUIViewController(context: Context) -> WebViewController {
        vc.state = state
        vc.loadContent(tag: tag)
        return vc
    }
    
    func updateUIViewController(_ webviewController: WebViewController, context: Context) {
        vc.updateContent()
    }
}

class WebViewController: UIViewController, WKNavigationDelegate, WKUIDelegate, WKScriptMessageHandler, UIWindowSceneDelegate {
    lazy var state = AppState()
    lazy var webview: WKWebView = createWebView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        webview.frame = view.frame
        webview.navigationDelegate = self
        webview.uiDelegate = self
        view.addSubview(webview)
        webview.configuration.userContentController.add(self, name: "handler")
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        switch keyPath {
        default:
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
    
   
    func loadContent(tag: String) {
        loadLocal(webview, state: state, tag: tag)
    }
    
    func updateContent() {
        webview.frame = self.view.frame
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        state.events.handler(webview, message: message)
    }
}

func createWebView() -> WKWebView {
    let webview = WKWebView()
    webview.translatesAutoresizingMaskIntoConstraints = false
    webview.configuration.mediaTypesRequiringUserActionForPlayback = []
    webview.isHidden = false
    #if os(iOS)
    webview.configuration.allowsInlineMediaPlayback = false
    webview.scrollView.bounces = false
    webview.scrollView.isScrollEnabled = false
    webview.isOpaque = false
    #endif
   return webview
}

func loadRemote(_ webview: WKWebView, url: URL) {
    let request = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad)
    webview.load(request)
}

func loadLocal(_ webview: WKWebView, state: AppState, tag: String) {
    webview.configuration.defaultWebpagePreferences.allowsContentJavaScript = true
    let bundle = AppBundle(state: state)
    addScript(webview, source: bundle.get())
    addScript(webview, source: state.events.script())
    webview.loadHTMLString(getHTML(tagname: tag, title: state.title), baseURL: URL(string: state.url))
}

func addScript(_ webview: WKWebView, source: String) {
    let script = WKUserScript(source: source, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
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
