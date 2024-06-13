//
//  Game-UserSettings.swift
//  Puzzles
//
//  Created by Kyle Swarner on 2/24/24.
//  Copyright © 2024 Kyle Swarner. All rights reserved.
//

import Foundation

extension GameConfig {
    
    func isFavorite(from gameSettings: GameUserSettings?) -> Bool {
        if let settings = gameSettings {
            return settings.category == .favorite
        }
        else {
            return false
        }
    }
    
    func isHidden(from gameSettings: GameUserSettings?) -> Bool {
        if let settings = gameSettings {
            return settings.category == .hidden
        }
        else {
            return false
        }
    }
    
}
