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
        #if os(iOS)
        NavigationView{
                   Webview(prefs: prefs)
                       .ignoresSafeArea(edges: .bottom)
                       .statusBar(hidden: prefs.hideStatusBar)
                       .navigationBarTitle(prefs.title, displayMode: .inline)
                       .navigationBarHidden(prefs.hideNavigationBar)
                   
               }
        #elseif os(macOS)
        Webview(prefs: self.prefs)
            .ignoresSafeArea(edges: .bottom)
            .navigationTitle(prefs.title)
        #endif
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        WebPage(prefs: WebConfig())
            .previewDisplayName("Web App")
    }
}


