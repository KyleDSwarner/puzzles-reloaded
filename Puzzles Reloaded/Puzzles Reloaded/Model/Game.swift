//
//  GameModel.swift
//  Puzzles
//
//  Created by Kyle Swarner on 2/24/24.
//  Copyright © 2024 Kyle Swarner. All rights reserved.
//

import Foundation
import SwiftUI
import SwiftData

@Observable class Game: Identifiable, Hashable {
    
    static func == (lhs: Game, rhs: Game) -> Bool {
        lhs.id == rhs.id
    }
    
    internal let id = UUID()
    let gameConfig: GameConfig
    let settings: GameUserSettings
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(gameConfig)
        hasher.combine(settings)
    }
    
    init(game: GameConfig, settings: GameUserSettings) {
        self.gameConfig = game
        self.settings = settings
    }
    
    var isFavorite: Bool {
        self.settings.isFavorite
    }
    
    var isHidden: Bool {
        self.settings.isHidden
    }
    
    var isExperimental: Bool {
        self.gameConfig.isExperimental
    }
    
    static var exampleGameModel = Game(game: GameConfig.exampleGame, settings: GameUserSettings(gameName: "abcd"))
    
}
