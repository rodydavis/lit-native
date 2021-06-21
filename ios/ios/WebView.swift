//
//  WebView.swift
//  app
//
//  Created by Rody Davis on 6/16/21.
//

import Foundation
import SwiftUI
import WebKit

struct WebView: UIViewControllerRepresentable {
    let state: AppState
    let tag: String
    let size: CGSize
  
    let webview: WKWebView = WKWebView()
    
    func makeUIViewController(context: Context) -> WebViewController {
        let vc = WebViewController()
        vc.context = self
        return vc
    }
    
    func updateUIViewController(_ webviewController: WebViewController, context: Context) {
        webviewController.resize(size: size)
//        print("update webview -> w: \(width), h: \(height)")
    }
    
   
}

class WebViewController: UIViewController, WKNavigationDelegate, WKUIDelegate, WKScriptMessageHandler, UIWindowSceneDelegate {
    lazy var context: WebView? = nil
    let config = WKWebViewConfiguration()
    lazy var webview: WKWebView = WKWebView()
    
    func resize(size: CGSize) {
    //        webview.frame = UIScreen.main.bounds
    //        webview.frame = vc.view.frame
        webview.frame = CGRect(x: 0 , y: 0, width: size.width, height: size.height)
//        webview.reload()
        webview.sizeToFit()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        webview = WKWebView(frame: .zero, configuration: config)
        webview.invalidateIntrinsicContentSize()
        webview.translatesAutoresizingMaskIntoConstraints = true
        webview.autoresizesSubviews = true
        webview.contentMode = .redraw
        webview.configuration.mediaTypesRequiringUserActionForPlayback = []
        webview.isHidden = false
        webview.configuration.allowsInlineMediaPlayback = false
        webview.scrollView.bounces = false
        webview.scrollView.isScrollEnabled = false
        webview.isOpaque = false
        webview.navigationDelegate = self
        webview.uiDelegate = self
        webview.frame = view.frame
        webview.configuration.userContentController.add(self, name: "handler")
        loadHtml()
        view.addSubview(webview)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        switch keyPath {
        default:
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        context!.state.events.handler(webview, message: message)
    }
    
    func loadHtml() {
        webview.configuration.defaultWebpagePreferences.allowsContentJavaScript = true
        let bundle = AppBundle(state: context!.state)
        addScript(source: bundle.get())
        addScript(source: context!.state.events.script())
        webview.loadHTMLString(getHTML(title: context!.state.title), baseURL: URL(string: context!.state.url))
    }

    func addScript(source: String) {
        let script = WKUserScript(source: source, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        webview.configuration.userContentController.addUserScript(script)
    }
    
    
    func getHTML(title: String = "", slot: String = "") -> String {
        return """
        <!DOCTYPE html>
        <html lang="en">
          <head>
            <meta charset="UTF-8" />
            <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, user-scalable=no" />
            <title>\(title)</title>
            <style>
                body {
                    width: 100%;
                    height: 100vh;
                    padding: 0;
                    margin: 0;
                }
            </style>
          </head>
          <body>
            <\(context!.tag)>
                \(slot)
            </\(context!.tag)>
          </body>
        </html>
        """
    }

}

extension Calendar {
    public func daysSince(date: Date) -> Int? {
        return self.dateComponents([.day], from: date, to: Date()).day
    }
}
