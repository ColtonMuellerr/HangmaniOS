//
//  GameModels.swift
//  hangman
//
//  Created by Colton Mueller on 4/29/24.
//

import SwiftUI

//single is against computer, local is playing with 2 people on same phone, party is where you pass phone around and if someone misses a letter they
//get a strike, 2 strikes you are out.

enum GameType {
    case bot, local, party, undetermined, partyAI
    
    var description: String {
        switch self {
        case .bot:
            return "Play against the computer"
        case .local:
            return "play against a local friend on the same phone"
        case .party:
            return "play with 3 people or more against a friend."
        case .undetermined:
            return ""
        case .partyAI:
            return "Play with 3 or more against the computer"
        }
    }
}

struct Player {
    var name: String
    var score: Int
    var isCurrent = false
    
}
