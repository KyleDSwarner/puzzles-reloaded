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
    let game: GameConfig
    let settings: GameListConfig
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(game)
        hasher.combine(settings)
    }
    
    init(game: GameConfig, settings: GameListConfig) {
        self.game = game
        self.settings = settings
    }
    
    var isFavorite: Bool {
        self.settings.isFavorite
    }
    
    var isHidden: Bool {
        self.settings.isHidden
    }
    
    var isExperimental: Bool {
        self.game.isExperimental
    }
    
    static var exampleGameModel = Game(game: GameConfig.exampleGame, settings: GameListConfig(gameName: "abcd"))
    
}
