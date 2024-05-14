//
//  hangmanApp.swift
//  hangman
//
//  Created by Colton Mueller on 4/29/24.
//

import SwiftUI

@main
struct AppEntry: App {
    @StateObject var game = GameService()
    var body: some Scene {
        WindowGroup {
            StartView()
                .environmentObject(game)
        }
    }
}
