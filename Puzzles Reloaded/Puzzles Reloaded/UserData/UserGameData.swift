//
//  GameSettings.swift
//  Puzzles Reloaded
//
//  Created by Kyle Swarner on 2/2/26.
//  Copyright © 2026 Kyle Swarner. All rights reserved.
//

import Foundation

struct UserGameData: Codable, Hashable {
    
    var gameName: String = ""
    var category: GameCategory = GameCategory.none
    
    var stats: GameplayStats = GameplayStats()
    var gameplayHistory: [GameplayHistory] = []
    
    var singleFingerPanningEnabled: Bool = false
    
    // Savegames & preferences stored from puzzles app (strings deserialized to objects)
    private var saveGame: String? // Saved game, piped from the internal puzzle app
    var userPrefs: String? // String from the puzzle code to store internal user preferences
    
    // Selected game presets and/or custom game config
    var selectedDefaultPreset: Int?
    var customDefaultPreset: [CustomMenuItem] = [] // This is populated from the game's custom menu settings view
    // var customPuzzlePresets: [CustomGamePreset] = []
    
    
    
    init(gameName: String) {
        self.gameName = gameName
        self.category = .none
        self.stats = GameplayStats()
        self.gameplayHistory = []
        self.saveGame = nil
        self.userPrefs = nil
        self.selectedDefaultPreset = nil
    }
    
    // Converstion Initializer
    init(gameName: String, category: GameCategory, stats: GameplayStats, history: [GameplayHistory], saveGame: String?, userPrefs: String?, selectedDefaultPreset: Int?, customDefaultPreset: [CustomMenuItem]) {
        self.gameName = gameName
        self.category = category
        self.stats = stats
        self.gameplayHistory = history
        self.saveGame = saveGame
        self.userPrefs = userPrefs
        self.selectedDefaultPreset = selectedDefaultPreset
        self.customDefaultPreset = customDefaultPreset
    }
    
    mutating func updateGameCategory(_ category: GameCategory) {
        if self.category == category {
            self.category = .none
        } else {
            self.category = category
        }
    }
    
    mutating func updateDefaultGamePreset(withId presetId: Int) {
        self.selectedDefaultPreset = presetId
        self.customDefaultPreset = []
    }
    
    mutating func updateDefaultGamePreset(withPresetConfig presetConfig: [CustomMenuItem]) {
        self.customDefaultPreset = presetConfig
        self.selectedDefaultPreset = nil
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
    
    mutating func abandonSave() {
        self.saveGame = nil
    }
    
    /** Retrieve savegame from storage, if available.
         Additionally removes the existing game from storage; This is to prevent any saves in a bad state from affecting the app more than once if it fails to deserialize.
     */
    mutating func retrieveSave() -> String? {
        let save = self.saveGame
        abandonSave()
        return save
    }
    
    mutating func persistSavegame(_ save: String?) {
        self.saveGame = save
    }
    
    /**
     When a new game is started and at least one move is taken, this function increments the play counter & logs the game information to the history log.
     */
    mutating func updateStatsForNewGame(gameId: String, gameDescription: String) {
        stats.updateStats_NewGame()
        
        let newHistory = GameplayHistory(gameId: gameId, description: gameDescription)
        gameplayHistory.append(newHistory)
        
        // Only log the last 20 games, trim excess
        self.gameplayHistory = self.gameplayHistory.suffix(20)
    }
    
    /**
     Update the history element for the game currently played as won
     */
    mutating func updateStatsForWonGame(gameId: String) {
        stats.gameWon(gameId: gameId)
        
        let gameIndex = gameplayHistory.firstIndex(where: { $0.gameId == gameId })
        
        
        if let gameIndex = gameIndex {
            print("Found Game History, marking as Won")
            // Mutating a struct must be done in place within the array- so temporary variables!
            gameplayHistory[gameIndex].markGameWon()
        }
    }
    
    /**
    Reset the player statistics log. This resets all counters and removed previous game history from the queue.
     */
    mutating func resetStatistics() {
        stats.resetStats()
        self.gameplayHistory = []
    }
    
}

extension UserGameData {
    init() {
        // Take Default Values
    }
    
    enum CodingsKeys: String, CodingKey {
        case gameName, category, stats, singleFingerPanningEnabled, saveGame, userPrefs, selectedDefaultPreset, customDefaultPreset, customPuzzlePresets, gameplayHistory
    }
    
    /**
        Custom decoder method allows for smooth migrations when we add or remove fields, otherwise data will be lost when the decoder can't create the new model.
     */
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        gameName = try values.decodeIfPresent(String.self, forKey: .gameName) ?? ""
        category = try values.decodeIfPresent(GameCategory.self, forKey: .category) ?? GameCategory.none
        stats = try values.decodeIfPresent(GameplayStats.self, forKey: .stats) ?? GameplayStats()
        singleFingerPanningEnabled = try values.decodeIfPresent(Bool.self, forKey: .singleFingerPanningEnabled) ?? false
        saveGame = try values.decodeIfPresent(String?.self, forKey: .saveGame) ?? nil
        userPrefs = try values.decodeIfPresent(String?.self, forKey: .userPrefs) ?? nil
        selectedDefaultPreset = try values.decodeIfPresent(Int?.self, forKey: .selectedDefaultPreset) ?? nil
        customDefaultPreset = try values.decodeIfPresent([CustomMenuItem].self, forKey: .customDefaultPreset) ?? []
        gameplayHistory = try values.decodeIfPresent([GameplayHistory].self, forKey: .gameplayHistory) ?? []
        
        /*
         var gameName: String = ""
         var category: GameCategory = GameCategory.none
         var stats: GameplayStats = GameplayStats()
         var singleFingerPanningEnabled: Bool = false
         private var saveGame: String? // Saved game, piped from the internal puzzle app
         var userPrefs: String? // String from the puzzle code to store internal user preferences
         var selectedDefaultPreset: Int?
         var customDefaultPreset: [CustomMenuItem] = [] // This is populated from the game's custom menu settings view
         // var customPuzzlePresets: [CustomGamePreset] = []
         
         var playHistory: [GameplayHistory] = []
         */
        
    }
}

extension UserGameData {
    static func initialStorage() -> CodableWrapper<UserGameData> {
        CodableWrapper.init(value: UserGameData())
    }
}
