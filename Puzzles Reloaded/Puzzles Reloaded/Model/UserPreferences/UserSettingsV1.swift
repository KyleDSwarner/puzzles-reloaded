//
//  UserSettingsV1.swift
//  Puzzles Reloaded
//
//  Created by Kyle Swarner on 9/16/24.
//  Copyright © 2024 Kyle Swarner. All rights reserved.
//

import Foundation
@preconcurrency import SwiftData

enum UserSettingsSchemaV1: VersionedSchema {
    static let versionIdentifier = Schema.Version(1, 0, 0)

    static var models: [any PersistentModel.Type] {
        [GameUserSettings.self]
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
        
        init(identifier: String) {
            self.gameName = identifier
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
    
    struct GameStats: Codable {
        var gamesPlayed = 0
        var gamesWon = 0
        var lastPlayed: Date?
        //var history: [GameHistory] = [GameHistory]()
        
        var winPercentage: Double {
            guard gamesPlayed > 0 else {
                return 0
            }
            
            return Double(gamesWon / gamesPlayed)
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
            gamesWon += 1
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
