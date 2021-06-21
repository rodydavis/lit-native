//
//  Events.swift
//  app
//
//  Created by Rody Davis on 6/19/21.
//

import Foundation
import WebKit

func handleEvent(_ webview: WKWebView, message: WKScriptMessage) {
    guard let dict = message.body as? [String : AnyObject],
          let type = dict["type"] as? String else {
        return
    }
    switch type {
        case "dialog":
            let title = dict["title"] as! String
            let message = dict["message"] as! String
            showAlert(title: title, message: message) {
                webview.dispatchEvent(event: "response", detail: "WebKit")
            }
            break
        default:
            print("event", dict)
    }
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


