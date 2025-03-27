//
//  PhotoExifApp.swift
//  PhotoExif
//
//  Created by 金井菜津希 on 2025/03/27.
//

import SwiftUI

@main
struct PhotoExifApp: App {
    
    @State private var selectedTab = 0
    
    var body: some Scene {
        WindowGroup {
            TabView(selection: $selectedTab) {
                ContentView()
                    .tabItem {
                        Image(systemName: "photo")
                            .environment(\.symbolVariants, selectedTab == 0 ? .fill : .none)
                        Text("Home")
                    }
                    .tag(0)
                AlbumView()
                    .tabItem {
                        Image(systemName: "photo.on.rectangle.angled")
                            .environment(\.symbolVariants, selectedTab == 1 ? .fill : .none)
                        Text("Album")
                    }
                    .tag(1)
            }
        }
    }
}
