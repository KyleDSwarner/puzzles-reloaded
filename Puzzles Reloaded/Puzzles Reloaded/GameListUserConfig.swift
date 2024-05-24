//
//  GameListConfig.swift
//  Puzzles
//
//  Created by Kyle Swarner on 2/23/24.
//  Copyright © 2024 Kyle Swarner. All rights reserved.
//

import SwiftData

enum GameCategory: Codable {
    case none, favorite, hidden
}

struct GameStats: Codable {
    var gamesPlayed = 0
    var gamesWon = 0
    
    var winPercentage: Double {
        guard gamesPlayed > 0 else {
            return 0
        }
        
        return Double(gamesWon / gamesPlayed)
    }
}


@Model
class GameListConfig {
    var gameName: String
    var category: GameCategory = GameCategory.none
    var stats: GameStats
    
    init(gameName: String) {
        self.gameName = gameName
        self.category = .none
        self.stats = GameStats()
    }
    
    func updateGameCategory(_ category: GameCategory) {
        if self.category == category {
            self.category = .none
        } else {
            self.category = category
        }
    }
    
    var isFavorite: Bool {
        self.category == .favorite
    }
    
    var isHidden: Bool {
        self.category == .hidden
    }
    

}
