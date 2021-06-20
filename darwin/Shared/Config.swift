//
//  Config.swift
//  app
//
//  Created by Rody Davis on 6/16/21.
//

import Foundation
import SwiftUI

class WebConfig: ObservableObject {
    @Published var title = Bundle.main.infoDictionary!["CFBundleName"] as! String
    @Published var url = Bundle.main.infoDictionary!["AppUrl"] as! String
    @Published var bundle = Bundle.main.infoDictionary!["AppBundleName"]  as! String
    @Published var hideStatusBar = false
    @Published var hideNavigationBar = false
    @Published var cacheDays = 1
    let events = Events()
}
