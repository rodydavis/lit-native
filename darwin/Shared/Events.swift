//
//  Events.swift
//  app
//
//  Created by Rody Davis on 6/19/21.
//

import Foundation
import WebKit

class Events {
    let types = ["native-alert"]
    
    func handler(_ webview: WKWebView, message: WKScriptMessage) {
        let body = (message.body as! String).data(using: .utf8)!
        do {
            let event = try JSONDecoder().decode(Event.self,from: body)
            switch event.event {
            case "native-alert":
                struct CustomEvent: Codable {
                    var event: String
                    var message: Message
                }
                struct Message: Codable {
                    var title: String
                    var message: String
                }
                let ev = try JSONDecoder().decode(CustomEvent.self,from: body)
                sendEvent(webview, event: "response", detail: "")
//                showAlert(title: e.message.title, message: e.message.message)
                break
            default:
                print("event", event)
            }
        } catch {
            print("could not parse event", error)
        }
    }
    
    func script() -> String {
        var output = ""
        for type in types {
            output += """
            document.addEventListener('\(type)', (e) => {
                window.webkit.messageHandlers.handler.postMessage(JSON.stringify({
                    event: '\(type)',
                    message: e.detail,
                }));
            }, false);
            """
        }
        return output
    }
}

func sendEvent(_ webview: WKWebView, event: String, detail: Any) -> Void {
//    let message = Event(event: event)
    let script = """
    const elem = document.querySelector('my-element')
    elem.dispatchEvent(new Event('response'))
    """
    webview.evaluateJavaScript(script)
//    if  let json = try? JSONEncoder().encode(message) {
//
//    }
    
}

func showAlert(title: String, message: String) -> Void {
    let alert = UIAlertController(title:title,
                                  message: message,
                                  preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "Ok", style: .default))
    let vc = UIApplication.shared.windows.first?.rootViewController
    vc?.present(alert, animated: true, completion: nil)
}

struct Event: Codable {
    var event: String
}
