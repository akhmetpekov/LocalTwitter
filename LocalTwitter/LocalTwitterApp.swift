//
//  LocalTwitterApp.swift
//  LocalTwitter
//
//  Created by Erik on 29.12.2022.
//

import SwiftUI
import Firebase

@main
struct LocalTwitterApp: App {
    init(){
        FirebaseApp.configure()
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
