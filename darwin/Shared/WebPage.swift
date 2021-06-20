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
        let webview = Webview(state: state)
        #if os(iOS)
        NavigationView{
            webview
                       .ignoresSafeArea(edges: .bottom)
                       .statusBar(hidden: state.hideStatusBar)
                       .navigationBarTitle(state.title, displayMode: .inline)
                       .navigationBarHidden(state.hideNavigationBar)
                   
               }
        #elseif os(macOS)
        webview
            .ignoresSafeArea(edges: .bottom)
            .navigationTitle(state.title)
        #endif
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        WebPage(state: AppState())
            .previewDisplayName("Web App")
    }
}


