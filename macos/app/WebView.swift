//
//  WebView.swift
//  app
//
//  Created by Rody Davis on 6/16/21.
//

import Foundation
import SwiftUI
import Cocoa
import WebKit
import AppKit

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



extension Calendar {
    public func daysSince(date: Date) -> Int? {
        return self.dateComponents([.day], from: date, to: Date()).day
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
