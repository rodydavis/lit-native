//
//  ContentView.swift
//  ios
//
//  Created by Rody Davis on 6/19/21.
//

import SwiftUI

struct Screen: View {
    @StateObject var state = AppState()
    @State var title: String
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    let components: [Component]
    
    var body: some View {
        NavigationView {
            List(components) { item in
                NavigationLink(destination: item) {
                    Text(item.name)
                }
            }.navigationTitle(title)
        }
       
    }
}


struct Component: View, Identifiable {
    let id = UUID()
    let tag: String
    let name: String
    let icon: String = "phone.fill"
    let bundle: String
    
    var body: some View {
        let state = AppState()
        Webview(state: state, tag:tag).ignoresSafeArea(edges: .bottom)
            .statusBar(hidden: state.hideStatusBar)
            .navigationBarTitle(name, displayMode: .inline)
            .navigationBarHidden(state.hideNavigationBar)
    }
}

//struct Component_Previews: PreviewProvider {
//    static var previews: some View {
//        Component(component: "my-element")
//    }
//}
