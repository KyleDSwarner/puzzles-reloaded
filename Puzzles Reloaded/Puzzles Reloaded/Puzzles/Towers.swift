//
//  Net.swift
//  Puzzles
//
//  Created by Kyle Swarner on 4/19/24.
//  Copyright © 2024 Kyle Swarner. All rights reserved.
//

import Foundation


extension Puzzles {
    static let puzzle_towers = GameConfig(
        name: "Towers",
        descritpion: "Tall Towers",
        imageName: "towers",
        game: towers,
        isExperimental: false,
        displayClearButtonInToolbar: true,

        buttonControls: [
            // ControlConfig(label: "Clear", command: PuzzleKeycodes.ClearButton, imageName: "square.slash"),
        ],
        
        overflowMenuControls: [
            ControlConfig(label: "Marks", command: PuzzleKeycodes.MarksButton, imageName: "square.and.pencil")
        ]
    ).numericButtonsBuilder({ gameId in
        // Sample game ID: 5:2/1/2/3/3/2/2/3/1/2/2/2/5/1/3/3/2/1/3/2
        // We just need that first digits, which indicates the number of towers in each row/column.
        
        guard !gameId.isEmpty else {
            return []
        }
        
        let numButtons = Int(gameId.split(separator: ":")[0])
        return Puzzles.createButtonControls(numButtons ?? 0)
    })
        
}
