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
    let appSupportURL = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
    var urlObservation: NSKeyValueObservation?
    var titleObservation: NSKeyValueObservation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.webview.frame = self.view.frame
        self.webview.configuration.mediaTypesRequiringUserActionForPlayback = []
        self.webview.navigationDelegate = self
        self.webview.uiDelegate = self
        self.webview.isHidden = false
//        self.webview.autoresizingMask = [.height, .width]
        self.view.addSubview(self.webview)
        titleObservation = self.webview.observe(\.title, changeHandler: { (webView, change) in
            if let title = self.webview.title {
                if self.prefs.title != title {
                    self.prefs.title = title
                }
            }
        })
    }
    
    
    func loadLocal(_ webview: WKWebView) {
        let url = Bundle.main.url(forResource: "index", withExtension: "html", subdirectory: "build")!
        webview.configuration.defaultWebpagePreferences.allowsContentJavaScript = true
        
        // Download Local Bundle
        let js = self.getBundle()
        let script = WKUserScript(source: js, injectionTime: .atDocumentEnd, forMainFrameOnly: false)
        self.webview.configuration.userContentController.addUserScript(script)
        
        webview.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())
        
        // Download Remote Bundle
        self.downloadBundle()
    }
    
    func loadRemote(_ webview: WKWebView, url: URL) {
        let request = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad)
        webview.load(request)
    }
    
    func getBundle() -> String {
        // Check if bundle exists
//        do {
//            let url = self.appSupportURL.appendingPathComponent(self.prefs.bundle).appendingPathExtension("js")
//            let bundle: String = try String(contentsOfFile: url.path)
//            return bundle
//        } catch {
//            //            print("Bundle not cached", error)
//        }
        
        // Fallback to included bundle
        do {
            let url = Bundle.main.url(forResource: self.prefs.bundle, withExtension: "js", subdirectory: "build")!
            
            let bundle: String = try String(contentsOfFile: url.path)
//            self.updateBundle(content: bundle)
            return bundle
        } catch {
            print("Bundle not found", error)
        }
        
        // No bundle included
        return ""
    }
    
    func updateBundle(content: String) {
        let fileManager = FileManager.default
        let bundleUrl = self.appSupportURL.appendingPathComponent(self.prefs.bundle).appendingPathExtension("js")
        
        // Check if Application Support Exists
        if !fileManager.fileExists(atPath: self.appSupportURL.path) {
            do {
                try fileManager.createDirectory(
                    at: self.appSupportURL,
                    withIntermediateDirectories: true,
                    attributes: nil
                )
            } catch {
                print("Could not create app support directory", error)
            }
        }
        
        // Fallback to bundle included at compile time
        if fileManager.fileExists(atPath: bundleUrl.path) {
            do {
                try fileManager.removeItem(at: bundleUrl)
            } catch {
                print("Could not remove existing bundle", error)
            }
        }
        
        // Update the bundle
        do {
            try content.write(to: self.appSupportURL, atomically: true, encoding: String.Encoding.utf8)
        } catch {
            print("Error updating bundle", error)
        }
    }
    
    func downloadBundle() {
        if self.prefs.url.isEmpty { return }
        
        if let url = URL(string: self.prefs.url + "/" + self.prefs.bundle) {
            let key = "last-bundle-update";
            
            // Check if the bundle has already been downloaded
            if let value = UserDefaults.standard.object(forKey: key) as? Date {
                if Calendar.current.daysSince(date: value) ?? -1 < self.prefs.cacheDays {
                    return
                }
            }
            
            // Try downloading a new bundle from the network
            let downloadTask = URLSession.shared.downloadTask(with: url) { (tempUrl, response, error) in
                if let tempFileUrl = tempUrl {
                    do {
                        let remoteBundle = try String(contentsOf: tempFileUrl)
                        self.updateBundle(content: remoteBundle)
                        UserDefaults.standard.set(Date(), forKey: key)
                    } catch {
                        print("Error downloading bundle", error)
                    }
                }
            }
            downloadTask.resume()
        }
    }
    
    func loadContent() {
        // self.loadRemote(webview, url: URL(string: self.config.url)!)
        self.loadLocal(webview)
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
    let appSupportURL = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
    
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
    
    func loadLocal(_ webview: WKWebView) {
        let url = Bundle.main.url(forResource: "index", withExtension: "html", subdirectory: "build")!
        webview.configuration.defaultWebpagePreferences.allowsContentJavaScript = true
        
        // Download Local Bundle
        let js = self.getBundle()
        let script = WKUserScript(source: js, injectionTime: .atDocumentEnd, forMainFrameOnly: false)
        self.webview.configuration.userContentController.addUserScript(script)
        
        webview.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())
        
        // Download Remote Bundle
        self.downloadBundle()
    }
    
    func loadRemote(_ webview: WKWebView, url: URL) {
        let request = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad)
        webview.load(request)
    }
    
    func getBundle() -> String {
        // Check if bundle exists
        do {
            let url = self.appSupportURL.appendingPathComponent(self.prefs.bundle).appendingPathExtension("js")
            let bundle: String = try String(contentsOfFile: url.path)
            return bundle
        } catch {
            //            print("Bundle not cached", error)
        }
        
        // Fallback to included bundle
        do {
            let url = Bundle.main.url(forResource: self.prefs.bundle, withExtension: "js", subdirectory: "build")!
            let bundle: String = try String(contentsOfFile: url.path)
            self.updateBundle(content: bundle)
            return bundle
        } catch {
            print("Bundle not found", error)
        }
        
        // No bundle included
        return ""
    }
    
    func updateBundle(content: String) {
        let fileManager = FileManager.default
        let bundleUrl = self.appSupportURL.appendingPathComponent(self.prefs.bundle).appendingPathExtension("js")
        
        // Check if Application Support Exists
        if !fileManager.fileExists(atPath: self.appSupportURL.path) {
            do {
                try fileManager.createDirectory(
                    at: self.appSupportURL,
                    withIntermediateDirectories: true,
                    attributes: nil
                )
            } catch {
                print("Could not create app support directory", error)
            }
        }
        
        // Fallback to bundle included at compile time
        if fileManager.fileExists(atPath: bundleUrl.path) {
            do {
                try fileManager.removeItem(at: bundleUrl)
            } catch {
                print("Could not remove existing bundle", error)
            }
        }
        
        // Update the bundle
        do {
            try content.write(to: self.appSupportURL, atomically: true, encoding: String.Encoding.utf8)
        } catch {
            print("Error updating bundle", error)
        }
    }
    
    func downloadBundle() {
        if self.prefs.url.isEmpty { return }
        
        if let url = URL(string: self.prefs.url + "/" + self.prefs.bundle) {
            let key = "last-bundle-update";
            
            // Check if the bundle has already been downloaded
            if let value = UserDefaults.standard.object(forKey: key) as? Date {
                if Calendar.current.daysSince(date: value) ?? -1 < self.prefs.cacheDays {
                    return
                }
            }
            
            // Try downloading a new bundle from the network
            let downloadTask = URLSession.shared.downloadTask(with: url) { (tempUrl, response, error) in
                if let tempFileUrl = tempUrl {
                    do {
                        let remoteBundle = try String(contentsOf: tempFileUrl)
                        self.updateBundle(content: remoteBundle)
                        UserDefaults.standard.set(Date(), forKey: key)
                    } catch {
                        print("Error downloading bundle", error)
                    }
                }
            }
            downloadTask.resume()
        }
    }
    
    func loadContent() {
        // self.loadRemote(webview, url: URL(string: self.config.url)!)
        self.loadLocal(webview)
    }
}


#endif

extension Calendar {
    public func daysSince(date: Date) -> Int? {
        return self.dateComponents([.day], from: date, to: Date()).day
    }
}
