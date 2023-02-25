//
//  MainView.swift
//  LocalTwitter
//
//  Created by Erik on 22.01.2023.
//

import SwiftUI

struct MainView: View {
    var body: some View {
        //MARK: - TabView With Recent Post's And Profile Tabs
        TabView {
            PostsView()
                .tabItem {
                    Image(systemName: "rectangle.portrait.on.rectangle.portrait.angled")
                    Text("Post's")
                }
            
            ProfileView()
                .tabItem {
                    Image(systemName: "gear")
                    Text("Profile")
                }
        }
        .tint(.black)
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
