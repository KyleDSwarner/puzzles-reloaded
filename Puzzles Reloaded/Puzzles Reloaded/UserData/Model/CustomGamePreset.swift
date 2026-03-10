//
//  CustomGamePreset.swift
//  Puzzles Reloaded
//
//  Created by Kyle Swarner on 3/10/26.
//  Copyright © 2026 Kyle Swarner. All rights reserved.
//

import Foundation

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
