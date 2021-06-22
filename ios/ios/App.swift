//
//  iosApp.swift
//  ios
//
//  Created by Rody Davis on 6/19/21.
//

import SwiftUI

@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            Screen(
               title: "My App",
               components: [
                Component(
                    tag:  "my-element",
                    name: "Element 1"
                ),
               ]
           )
        }.commands {
//            CommandMenu("Custom Menu") {
//                Button("Action 1") {
//                    print("pressed menu item")
//                }
//            }
        }
    }
}
