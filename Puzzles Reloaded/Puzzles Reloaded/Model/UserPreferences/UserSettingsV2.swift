//
//  UserSettingsV1.swift
//  Puzzles Reloaded
//
//  Created by Kyle Swarner on 9/16/24.
//  Copyright © 2024 Kyle Swarner. All rights reserved.
//

import Foundation
@preconcurrency import SwiftData

enum UserSettingsSchemaV2: VersionedSchema {
    static let versionIdentifier = Schema.Version(2, 0, 0)

    static var models: [any PersistentModel.Type] {
        [GameUserSettings.self, GameStatistics.self, GameplayHistory.self]
    }

    @Model
    class GameUserSettings {
        var gameName: String = ""
        var category: GameCategory = GameCategory.none
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
            self.saveGame = nil
            self.userPrefs = nil
            self.selectedDefaultPreset = nil
            self.gameStatistics = GameStatistics()
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
        private(set) var gamesPlayed = 0
        private(set) var gamesWon = 0
        private(set) var lastPlayed: Date?
        
        @Relationship(deleteRule: .cascade, inverse: \GameplayHistory.parent) private(set) var history: [GameplayHistory]? = []
        
        init() {
            self.gamesPlayed = 0
            self.gamesWon = 0
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
