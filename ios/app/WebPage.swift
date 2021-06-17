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
        NavigationView{
            Webview(prefs: prefs)
                .ignoresSafeArea(edges: .bottom)
                .statusBar(hidden: prefs.hideStatusBar)
                .navigationBarTitle(prefs.title, displayMode: .inline)
                .navigationBarHidden(prefs.hideNavigationBar)
            
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        WebPage()
            .previewDisplayName("Web App")
    }
}


