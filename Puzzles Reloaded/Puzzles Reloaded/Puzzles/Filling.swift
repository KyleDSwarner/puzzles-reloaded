//
//  Filling.swift
//  Puzzles
//
//  Created by Kyle Swarner on 5/1/24.
//  Copyright © 2024 Kyle Swarner. All rights reserved.
//

extension Puzzles {
    static let puzzle_filling = GameConfig(
        name: "Filling",
        descritpion: "Mark every square with the area of its containing region",
        imageName: "filling",
        game: filling,
        displayClearButtonInToolbar: true,
        buttonControls: [
            // ControlConfig(label: "Clear", shortPress: PuzzleKeycodes.middleKeypress, longPress: .none, imageName: "square.slash")
        ]
    ).numericButtonsBuilder({ gameId in
        // Filling always displays all 10 number buttons as any number can be used at any size.
        // The game ID doesn't provide any additional information -> 13x9:5a6b777a4b455b7a7765e5b8c4a3a4a9c8a6b3a8a9a5d2724b9d63e8d3b3a7b433a82b2e3b9c53b
        return Puzzles.createButtonControls(10)
    })
}
