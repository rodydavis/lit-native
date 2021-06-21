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
//        NavigationView {
//            List(components) { item in
//                NavigationLink(destination: item) {
//                    Text(item.name)
//                }
//            }.navigationTitle(title)
//        }
        let child = components[0]
        GeometryReader { geometry in
            ZStack {
                WebView(
                    state: state,
                    tag: child.tag,
                    size: geometry.size
                )
//                .ignoresSafeArea(edges: .bottom)
//                    .statusBar(hidden: state.hideStatusBar)
//                .navigationBarTitle( components[0].name, displayMode: .inline)
//                    .navigationBarHidden(state.hideNavigationBar)
            }
        }
       
    }
}


struct Component:  Identifiable {
    let id = UUID()
    let tag: String
    let name: String
    let icon: String = "phone.fill"
    let bundle: String
    let state = AppState()
   
}

//struct Component_Previews: PreviewProvider {
//    static var previews: some View {
//        Component(component: "my-element")
//    }
//}
