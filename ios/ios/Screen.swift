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
                NavigationLink(destination: GeometryReader { geometry in
                            ZStack {
                                WebView(
                                    tag: item.tag,
                                    size: geometry.size
                                )
                            }}.navigationBarTitle( item.name, displayMode: .automatic)
                ) {
                    Text(item.name)
                }
            }.navigationTitle(title)
        }

//                .ignoresSafeArea(edges: .bottom)
//                    .statusBar(hidden: state.hideStatusBar)
//                .navigationBarTitle( components[0].name, displayMode: .inline)
//                    .navigationBarHidden(state.hideNavigationBar)
//            }
//        }
       
    }
}


struct Component: Codable, Identifiable {
    var id = UUID()
    let tag: String
    let name: String
    var icon: String = "phone.fill"
    var bundle: String = "bundle.es"
}

//struct Component_Previews: PreviewProvider {
//    static var previews: some View {
//        Component(component: "my-element")
//    }
//}
