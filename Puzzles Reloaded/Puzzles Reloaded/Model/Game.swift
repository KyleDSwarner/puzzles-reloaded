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

/**
 This object is used to merge together the internal game config alongside the user's settings (which are stored in SwiftData). The game menus are given an array of these objects to form the complete game list.
 */
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
    
    nonisolated(unsafe) static let exampleGameModel = Game(game: GameConfig.exampleGame, settings: GameUserSettings(identifier: "abcd"))
    
}
