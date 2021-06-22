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
        if (components.count == 1 && title.count > 0) {
            let item = components[0]
            if (horizontalSizeClass == .compact) {
                NavigationView {
                    RenderComponent(component: item)
                }.navigationTitle(title)
            } else {
                RenderComponent(component: item)
            }
        } else {
            NavigationView {
                List(components) { item in
                    NavigationLink(destination: RenderComponent(component: item)
                    ) {
                        Text(item.name)
                    }
                }.navigationTitle(title)
            }
        }
    }
}

struct RenderComponent: View {
    let component: Component
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                WebView(
                    tag: component.tag,
                    size: geometry.size
                )
            }}
            .navigationBarTitle( component.name, displayMode: .automatic)
    }
}

struct Component: Codable, Identifiable {
    var id = UUID()
    let tag: String
    let name: String
    var icon: String = "phone.fill"
    var bundle: String = "bundle.es"
}
