//
//  UserSettingsV1.swift
//  Puzzles Reloaded
//
//  Created by Kyle Swarner on 9/16/24.
//  Copyright © 2024 Kyle Swarner. All rights reserved.
//

import Foundation
@preconcurrency import SwiftData

// Intermittent model on the way to migrate to v2: Introduces new fields, but does not yet delete the old ones.
// V2 will delete the old versions to complete the migration

// This is paused for the time being, as CloudKit is not playing nice with migrations & causing crashes & errors. For now, I'll just store the history object on `GameUserSettings` and we can migrate later if I figure this out.

enum UserSettingsSchemaV1_1: VersionedSchema {
    static let versionIdentifier = Schema.Version(1, 1, 0)

    static var models: [any PersistentModel.Type] {
        [GameUserSettings.self, GameStatistics.self, GameplayHistory.self]
    }

    @Model
    class GameUserSettings {
        var gameName: String = ""
        var category: GameCategory = GameCategory.none
        var stats: GameStats = GameStats()
        var singleFingerPanningEnabled: Bool = false
        var saveGame: String? // Saved game, piped from the internal puzzle app
        var userPrefs: String? // String from the puzzle code to store internal user preferences
        var selectedDefaultPreset: Int?
        var customDefaultPreset: [CustomMenuItem] = [] // This is populated from the game's custom menu settings view
        var customPuzzlePresets: [CustomGamePreset] = []
        
        @Relationship(deleteRule: .cascade, inverse: \GameStatistics.parent) var gameStatistics: GameStatistics?
        
        init(identifier: String) {
            self.gameName = identifier
            self.category = .none
            self.stats = GameStats()
            self.saveGame = nil
            self.userPrefs = nil
            self.selectedDefaultPreset = nil
            self.gameStatistics = GameStatistics(gameName: identifier)
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
    
    @Model
    class GameStatistics {
        private(set) var parent: GameUserSettings?
        private(set) var gameName: String = ""
        private(set) var gamesPlayed = 0
        private(set) var gamesWon = 0
        private(set) var lastPlayed: Date?
        
        @Relationship(deleteRule: .cascade, inverse: \GameplayHistory.parent) private(set) var history: [GameplayHistory]? = []
        
        init(gameName: String, gamesPlayed: Int = 0, gamesWon: Int = 0) {
            self.gameName = gameName
            self.gamesPlayed = gamesPlayed
            self.gamesWon = gamesWon
            self.lastPlayed = Date.now
            self.history = []
        }
        
        var winPercentage: Double {
            guard gamesPlayed > 0 else {
                return 0
            }
            
            return Double(gamesWon) / Double(gamesPlayed)
        }
    }
    
    @Model class GameplayHistory {
        var parent: GameStatistics?
        var gameId: String = ""
        var gameDescription: String = ""
        var datePlayed: Date = Date.now
        var gameWon: Bool = false
        
        init(gameId: String, description: String) {
            self.gameId = gameId
            self.gameDescription = description
            self.datePlayed = Date.now
            self.gameWon = false
        }
        
        func markGameWon() {
            self.gameWon = true
        }
    }
    
    struct GameStats: Codable {
        var gamesPlayed = 0
        var gamesWon = 0
        var lastPlayed: Date?
        
        var winPercentage: Double {
            guard gamesPlayed > 0 else {
                return 0
            }
            
            return Double(gamesWon) / Double(gamesPlayed)
        }
        
        mutating func updateStats_NewGame(gameId: String = "", gameDescription: String = "") {
            // print("New Game Started! id: \(gameId) description: \(gameDescription)") // Note: These values aren't quite ready when the app is starting up, we'll need to refactor this.
            gamesPlayed += 1
            lastPlayed = Date.now
            
            //let newHistory = GameHistory(gameId: "test123", description: "Describing")
            //self.history.append(newHistory)
            
            // Limit the size of the history to the last 20 items
            //self.history = self.history.suffix(20)
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
    
    struct GameHistory: Codable, Identifiable {
        var id = UUID()
        var gameId: String = ""
        var description: String = ""
        var datePlayed: Date = Date.now
        var gameWon: Bool = false
        
        init(gameId: String, description: String) {
            self.gameId = gameId
            self.description = description
            self.datePlayed = Date.now
            self.gameWon = false
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
}

