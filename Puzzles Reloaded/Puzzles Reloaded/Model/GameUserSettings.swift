//
//  GameListConfig.swift
//  Puzzles
//
//  Created by Kyle Swarner on 2/23/24.
//  Copyright © 2024 Kyle Swarner. All rights reserved.
//

import Foundation
import SwiftData

@Model
class GameUserSettings {
    var gameName: String = ""
    var category: GameCategory = GameCategory.none
    var stats: GameStats = GameStats()
    var saveGame: String? // Saved game, piped from the internal puzzle app
    var userPrefs: String? // String from the puzzle code to store internal user preferences
    var selectedDefaultPreset: Int?
    var customDefaultPreset: [CustomMenuItem] = [] // This is populated from the game's custom menu settings view
    var customPuzzlePresets: [CustomGamePreset] = []
    
    init(gameName: String) {
        self.gameName = gameName
        self.category = .none
        self.stats = GameStats()
        self.saveGame = nil
        self.userPrefs = nil
        self.selectedDefaultPreset = nil
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
    
    var hasSavedGame: Bool {
        return saveGame != nil && saveGame?.isEmpty == false
    }
}

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

struct CustomGamePreset: Codable, Identifiable {
    var id = UUID()
    var sortOrder: Int = 0
    var name: String = ""
    var puzzleConfig: CustomConfigMenu
    
    init(sortOrder: Int, name: String, puzzleConfig: CustomConfigMenu) {
        
        self.sortOrder = sortOrder
        self.name = name
        self.puzzleConfig = puzzleConfig
    }
    
    mutating func updateName(newName: String) {
        self.name = newName
    }
    
    mutating func updateSortOrder(sortOrder: Int) {
        self.sortOrder = sortOrder
    }
    
    mutating func updatePuzzleConfig(puzzleConfig: CustomConfigMenu) {
        self.puzzleConfig = puzzleConfig
    }
}
