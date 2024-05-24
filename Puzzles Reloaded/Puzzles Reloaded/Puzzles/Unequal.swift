//
//  Unequal.swift
//  Puzzles
//
//  Created by Kyle Swarner on 4/30/24.
//  Copyright © 2024 Kyle Swarner. All rights reserved.
//

extension Puzzles {
    static let puzzle_unequal = GameConfig(
        name: "unequal",
        descritpion: "equality",
        game: unequal,
        
        overflowMenuControls: [
            ControlConfig(label: "Marks", command: PuzzleKeycodes.MarksButton, imageName: "square.and.pencil"),
            ControlConfig(label: "Hints", command: ButtonPress(for: "H"), imageName: "plus.square")
        ]
    ).numericButtonsBuilder({gameId in
        // Game ID: 4:0,0,0,0D,0,0,0,0,2D,0D,0,0,0,0,0,3U,
        
        guard !gameId.isEmpty else {
            return []
        }
        
        let numButtons = Int(gameId.split(separator: ":")[0])
        return Puzzles.createButtonControls(numButtons ?? 0)
    })
}
