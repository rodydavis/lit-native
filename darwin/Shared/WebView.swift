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

class WebViewController: NSViewController, WKNavigationDelegate, WKUIDelegate {
    lazy var prefs: WebConfig = WebConfig()
    lazy var webview: WKWebView = WKWebView()
    var urlObservation: NSKeyValueObservation?
    var titleObservation: NSKeyValueObservation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.webview.frame = self.view.frame
        self.webview.configuration.mediaTypesRequiringUserActionForPlayback = []
        self.webview.navigationDelegate = self
        self.webview.uiDelegate = self
        self.webview.isHidden = false
        self.view.addSubview(self.webview)
        titleObservation = self.webview.observe(\.title, changeHandler: { (webView, change) in
            if let title = self.webview.title {
                if self.prefs.title != title {
                    self.prefs.title = title
                }
            }
        })
    }
    
    func loadContent() {
        loadLocal(self.webview, prefs: self.prefs)
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

class WebViewController: UIViewController, WKNavigationDelegate, WKUIDelegate {
    lazy var prefs: WebConfig = WebConfig()
    lazy var webview: WKWebView = WKWebView()
    lazy var progressbar: UIProgressView = UIProgressView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.webview.frame = self.view.frame
        self.webview.configuration.allowsInlineMediaPlayback = false
        self.webview.configuration.mediaTypesRequiringUserActionForPlayback = []
        self.webview.navigationDelegate = self
        self.webview.uiDelegate = self
        self.webview.scrollView.bounces = false
        self.webview.scrollView.isScrollEnabled = false
        self.webview.isOpaque = false
        self.webview.isHidden = false
        self.view.addSubview(self.webview)
        
        self.view.addSubview(self.progressbar)
        self.progressbar.translatesAutoresizingMaskIntoConstraints = false
        self.view.addConstraints([
            self.progressbar.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.progressbar.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.progressbar.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
        ])
        
        self.progressbar.progress = 0.1
        webview.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        switch keyPath {
        case "estimatedProgress":
            if self.webview.estimatedProgress >= 1.0 {
                UIView.animate(withDuration: 0.3, animations: { () in
                    self.progressbar.alpha = 0.0
                }, completion: { finished in
                    self.progressbar.setProgress(0.0, animated: false)
                    self.prefs.title = self.webview.title ?? self.prefs.title
                })
            } else {
                self.progressbar.isHidden = false
                self.progressbar.alpha = 1.0
                progressbar.setProgress(Float(self.webview.estimatedProgress), animated: true)
            }
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
}


#endif

func loadRemote(_ webview: WKWebView, url: URL) {
    let request = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad)
    webview.load(request)
}

func loadLocal(_ webview: WKWebView, prefs: WebConfig) {
    webview.configuration.defaultWebpagePreferences.allowsContentJavaScript = true
    let bundle = AppBundle(prefs: prefs)
    let script = WKUserScript(source: bundle.get(), injectionTime: .atDocumentEnd, forMainFrameOnly: false)
    webview.configuration.userContentController.addUserScript(script)
//    let url = Bundle.main.url(forResource: "index", withExtension: "html", subdirectory: "build")!
//    webview.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())
    webview.loadHTMLString(getHTML(tagname: "my-element", title: prefs.title), baseURL: URL(string: prefs.url))
    
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
