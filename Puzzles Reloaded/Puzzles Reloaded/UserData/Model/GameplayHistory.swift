//
//  GameHistory.swift
//  Puzzles Reloaded
//
//  Created by Kyle Swarner on 3/10/26.
//  Copyright © 2026 Kyle Swarner. All rights reserved.
//

import Foundation

struct GameplayHistory: Codable, Identifiable, Hashable {
    var id = UUID()
    var gameId: String = ""
    var description: String = ""
    var datePlayed: Date = Date.now
    // var timeTaken: TimeInterval = 0 // Currently Unused
    // var undoUsed: Bool = false // Currently Unused
    // var autosolverUsed: Bool = false // Currently Unused (We'll need this to prevent future cheating via Solve -> New Game -> Undo)
    var gameWon: Bool = false
    
    init(gameId: String, description: String) {
        self.gameId = gameId
        self.description = description
        self.datePlayed = Date.now
        // self.timeTaken = 0
        // self.undoUsed = false
        // (Above values trigger migration failures, we'll need to get migrations working to add them)
        self.gameWon = false
    }
    
    // Conversion Initializer
    init(gameId: String, description: String, datePlayed: Date, gameWon: Bool) {
        self.gameId = gameId
        self.description = description
        self.datePlayed = datePlayed
        self.gameWon = gameWon
    }
    
    mutating func markGameWon() {
        self.gameWon = true
    }
}
