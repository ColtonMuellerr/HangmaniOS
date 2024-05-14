//
//  GameService.swift
//  hangman
//
//  Created by Colton Mueller on 5/2/24.
//

import SwiftUI

@MainActor

class GameService: ObservableObject {
    @Published var player1 = Player(name: "Player 1", score: 0)
    @Published var player2 = Player(name: "Player 2", score: 0)
    @Published var player3 = Player(name: "Player 3", score: 0)
    @Published var player4 = Player(name: "Player 4", score: 0)
    @Published var player5 = Player(name: "Player 5", score: 0)
    @Published var player6 = Player(name: "Player 6", score: 0)
    
    //@Published var players: [String] = ["Player 1", "Player 2"]
    //@Published var currentPlayerIndex = 0
    
    var gameType = GameType.local
    
    var currentPlayer: Player {
        if player1.isCurrent {
            return player1
        } else {
            return player2
        }
    }
    
    func setupGame(gameType: GameType, player1Name: String, player2Name: String, player3Name: String, player4Name: String, player5Name: String,
                   player6Name: String) {
        switch gameType {
        case .local:
            self.gameType = .local
            player2.name = player2Name
        case .bot:
            self.gameType = .bot
            player2.name = "HangMan"
        case .party:
            self.gameType = .party
            player2.name = player2Name
            player3.name = player3Name
            player4.name = player4Name
            player5.name = player5Name
            player6.name = player6Name
        case .undetermined:
            self.gameType = .undetermined
        case .partyAI:
            break
        }
        player1.name = player1Name
    }
    
    var gameStarted: Bool {
        player1.isCurrent || player2.isCurrent
    }
}
