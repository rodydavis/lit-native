//
//  ContentView.swift
//  app
//
//  Created by Rody Davis on 6/16/21.
//

import SwiftUI

struct WebPage: View {
    @StateObject var prefs = WebConfig()
    
    var body: some View {
        Webview(prefs: self.prefs)
            .ignoresSafeArea(edges: .bottom).navigationTitle(self.prefs.title)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        WebPage(prefs: WebConfig())
            .previewDisplayName("Web App")
    }
}


