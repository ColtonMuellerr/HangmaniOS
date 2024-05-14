//
//  ContentView.swift
//  hangman
//
//  Created by Colton Mueller on 4/29/24.
//

import SwiftUI

struct StartView: View {
    @EnvironmentObject var game: GameService
    @State private var gameType: GameType = .undetermined
    @State private var player1 = ""
    @State private var player2 = ""
    @State private var player3 = ""
    @State private var player4 = ""
    @State private var player5 = ""
    @State private var player6 = ""
    @FocusState private var focus: Bool
    @State private var startGame = false
    var body: some View {
        VStack {
            Picker("Select Game Mode", selection: $gameType) {
                Text("Select Game Type").tag(GameType.undetermined)
                Text("Computer Play").tag(GameType.bot)
                Text("2 Player Same Device").tag(GameType.local)
                Text("3-6 player").tag(GameType.party)
                Text("3-6 vs Computer").tag(GameType.partyAI)
            }
            .padding()
            .background(Rectangle()
                .fill(.white)
                .frame(width: 200))
            .background(Rectangle()
                .fill(.orange)
                .frame(width: 500, height: 60))
            Text(gameType.description)
                .padding()
            VStack {
                switch gameType {
                case .bot:
                    TextField("Your Name", text: $player1)
                case .local:
                    VStack {
                        TextField("Player 1", text: $player1)
                        TextField("Player 2", text: $player2)
                    }
                case .party:
                    VStack {
                        TextField("Player 1", text: $player1)
                        TextField("Player 2", text: $player2)
                        TextField("Player 3", text: $player3)
                        TextField("Player 4", text: $player4)
                        TextField("Player 5", text: $player5)
                        TextField("Player 6", text: $player6)
                    }
                case .undetermined:
                    EmptyView()
                case .partyAI:
                    EmptyView()
                }
            }
            .padding()
            .textFieldStyle(.roundedBorder)
            .focused($focus)
            .frame(width: 350)
            
            
            if gameType != .undetermined {
                Button("Start Game") {
                    game.setupGame(gameType: gameType, player1Name: player1, player2Name: player2, player3Name: player3, player4Name: player4, player5Name: player5,
                        player6Name: player6)
                    focus = false
                    startGame.toggle()
                }
                .buttonStyle(.borderedProminent)
                .disabled(
                    gameType == .undetermined ||
                    gameType == .bot && player1.isEmpty ||
                    gameType == .local && (player1.isEmpty || player2.isEmpty) ||
                    gameType == .party && (player1.isEmpty || player2.isEmpty || player3.isEmpty)
                )
            }
        }
        .padding()
        .navigationTitle("Hangman")
        .fullScreenCover(isPresented: $startGame){
            GameView()
        }
        .inNavigationstack()
    }
}

#Preview {
    StartView()
        .environmentObject(GameService())
}
