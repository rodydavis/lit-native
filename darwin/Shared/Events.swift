//
//  Events.swift
//  app
//
//  Created by Rody Davis on 6/19/21.
//

import Foundation
import WebKit

class Events {
    
    func handler(_ webview: WKWebView, message: WKScriptMessage) {
        guard let dict = message.body as? [String : AnyObject] else {
            return
        }
        if let type = dict["type"] as? String {
            switch type {
            case "dialog":
                let title = dict["title"] as! String
                let message = dict["message"] as! String
                showAlert(title: title, message: message) {
                    sendEvent(webview, event: "response", detail: "WebKit")
                }
                break
            default:
                print("event", dict)
            }
        }
    }
    
    func script() -> String {
        return """
        document.addEventListener('native', (e) => {
            window.webkit.messageHandlers.handler.postMessage(e.detail);
        }, false);
        """
    }
}

func sendEvent(_ webview: WKWebView, event: String, detail: String) -> Void {
    let encoder = JSONEncoder()
    encoder.outputFormatting = .prettyPrinted
    let data = try! encoder.encode(["event": event, "detail": detail])
    let jsonString = String(data: data, encoding: .utf8)!
    let script = """
    const elem = document.querySelector('my-element')
    elem.dispatchEvent(new CustomEvent('response', { detail: \(jsonString) }))
    """
    webview.evaluateJavaScript(script)
    
}

func showAlert(title: String, message: String, callback: @escaping () -> Void) -> Void {
    let alert = UIAlertController(title:title,
                                  message: message,
                                  preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "Ok", style: .default){ action -> Void in
        callback()
    })
    let vc = UIApplication.shared.windows.first?.rootViewController
    vc?.present(alert, animated: true, completion: nil)
}
