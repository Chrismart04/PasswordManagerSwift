//
//  PasswordManagerApp.swift
//  PasswordManager
//
//  Created by Christopher Martínez on 28/6/25.
//

import SwiftUI

@main
struct PasswordManagerApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .windowResizability(.contentSize)
        .defaultSize(width: 480, height: 680)
        .windowToolbarStyle(.unified(showsTitle: false))
    }
}
