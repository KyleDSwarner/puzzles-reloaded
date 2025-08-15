//
//  GameList.swift
//  Puzzles
//
//  Created by Kyle Swarner on 2/23/24.
//  Copyright © 2024 Kyle Swarner. All rights reserved.
//

import SwiftUI
import SwiftData

@Observable 
class GameManager {
    private(set) var games: [GameConfig] // Configured games, from internal Tatham system
    private(set) var gameModel: [Game]
    private var dataIsLoaded: Bool
    
    init() {
        games = Puzzles.allPuzzlesSorted
        gameModel = []
        dataIsLoaded = false
    }
    
    func setupData(with context: ModelContext) {
        guard dataIsLoaded == false else {
            return
        }
        
        createGamesList(with: context)
        
        dataIsLoaded = true
    }
    
    func createGamesList(with context: ModelContext) {
        guard dataIsLoaded == false else {
            return
        }
        
        let gameSettings = collectGamePreferences(from: context)
        
        for game in games {
            let newGameModel = Game(game: game, settings: findPreferencesForGame(game, from: gameSettings, context: context))
            gameModel.append(newGameModel)
        }
        
        dataIsLoaded = true
    }
    
    func collectGamePreferences(from context: ModelContext) -> [GameUserSettings] {
        
        let gameSettings = FetchDescriptor<GameUserSettings>()
        let results = try! context.fetch(gameSettings)
        
        return results
    }
    
    
    func findPreferencesForGame(_ game: GameConfig, from preferences: [GameUserSettings], context: ModelContext) -> GameUserSettings {
        if let preferences = findExistingPreferences(game, from: preferences) {
            return preferences
        }
        
        let newPreferences = GameUserSettings(identifier: game.identifier)
        context.insert(newPreferences)

        return newPreferences
    }
    
    func findExistingPreferences(_ game: GameConfig, from preferences: [GameUserSettings]) -> GameUserSettings? {
        return preferences.first(where: { $0.gameName == game.identifier})
    }
    
    func findGameBySaveName(name: String) -> Game? {
        gameModel.first(where: { game in
            return game.gameConfig.savegameIdentifier.caseInsensitiveCompare(name) == .orderedSame
        })
    }
    
   
    

}

// MARK: Game Manager Filters
extension GameManager {
    func filterGameList(category: GameCategory, showExperimentalGames: Bool = false) -> [Game] {
        gameModel.filter { game in
            game.settings.category == category && (showExperimentalGames || !game.gameConfig.isExperimental)
        }
    }
    
    func getGameList(showHiddenGames: Bool, showExperimentalGames: Bool = false) -> [Game] {
        gameModel.filter { game in
            (showHiddenGames == true || game.settings.category != .hidden)
                && (showExperimentalGames || !game.gameConfig.isExperimental)
        }
    }
    
    func getNonHiddenGames(showExperimentalGames: Bool = false) -> [Game] {
        gameModel.filter { game in
            game.settings.category != .hidden && (showExperimentalGames || !game.gameConfig.isExperimental)
        }
    }
    
    
    var favoriteGames: [Game] {
        gameModel.filter { game in
            game.settings.category == .favorite
        }
    }
    
    var allGames: [Game] {
        gameModel.filter { game in
            game.settings.category == .none
        }
    }
    
    var hiddenGames: [Game] {
        gameModel.filter { game in
            game.settings.category == .hidden
        }
    }
}

