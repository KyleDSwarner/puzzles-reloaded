//
//  GameplayStats.swift
//  Puzzles Reloaded
//
//  Created by Kyle Swarner on 3/10/26.
//  Copyright © 2026 Kyle Swarner. All rights reserved.
//

import Foundation

struct GameplayStats: Codable, Hashable {
    var gamesPlayed = 0
    var gamesWon = 0
    var lastPlayed: Date?
    
    var winPercentage: Double {
        guard gamesPlayed > 0 else {
            return 0
        }
        
        return Double(gamesWon) / Double(gamesPlayed)
    }
    
    init() {
        gamesPlayed = 0
        gamesWon = 0
    }
    
    // Conversion Initializer
    init(gamesPlayed: Int, gamesWon: Int, lastPlayed: Date?) {
        self.gamesPlayed = gamesPlayed
        self.gamesWon = gamesWon
        self.lastPlayed = lastPlayed
    }
    
    mutating func updateStats_NewGame() {
        // print("New Game Started! id: \(gameId) description: \(gameDescription)") // Note: These values aren't quite ready when the app is starting up, we'll need to refactor this.
        gamesPlayed += 1
        lastPlayed = Date.now
    }
    
    mutating func gameWon(gameId: String) {
        // check if games played is greater than zero to cause a side effect where an in-progress game could be completed after clearing stats.
        // Also runs a sanity check to ensure the number of games won can never exceed the number of games played.
        if gamesPlayed > 0 && gamesWon < gamesPlayed {
            gamesWon += 1
        }
    }
    
    mutating func resetStats() {
        self.gamesPlayed = 0
        self.gamesWon = 0
        self.lastPlayed = nil
    }
}
