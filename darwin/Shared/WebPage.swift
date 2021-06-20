//
//  ContentView.swift
//  app
//
//  Created by Rody Davis on 6/16/21.
//

import SwiftUI

struct WebPage: View {
    @StateObject var state = AppState()
    
    var body: some View {
        #if os(iOS)
        NavigationView{
                   Webview(state: state)
                       .ignoresSafeArea(edges: .bottom)
                       .statusBar(hidden: state.hideStatusBar)
                       .navigationBarTitle(state.title, displayMode: .inline)
                       .navigationBarHidden(state.hideNavigationBar)
                   
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
        WebPage(state: AppState())
            .previewDisplayName("Web App")
    }
}


