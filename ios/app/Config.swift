//
//  Config.swift
//  app
//
//  Created by Rody Davis on 6/16/21.
//

import Foundation
import SwiftUI

class WebConfig: ObservableObject {
    @Published var title = "My App"
    @Published var url = "https://google.com"
    @Published var bundle = "my-app.es"
    @Published var hideStatusBar = false
    @Published var hideNavigationBar = false
    @Published var cacheDays = 1
}
