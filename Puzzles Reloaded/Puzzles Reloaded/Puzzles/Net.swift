//
//  Net.swift
//  Puzzles
//
//  Created by Kyle Swarner on 4/19/24.
//  Copyright © 2024 Kyle Swarner. All rights reserved.
//

import Foundation


extension Puzzles {
    static let puzzle_net = GameConfig(
        name: "net",
        descritpion: "Oh No, a spider!",
        game: net,
        touchControls: [ // TODO: We'll need special handling for these controls in Net.
            ControlConfig(label: "Clockwise", shortPress: PuzzleKeycodes.rightKeypress, longPress: PuzzleKeycodes.middleKeypress, imageName: "arrow.clockwise"), // Left/Right is reversed intentionally to make clockwise the 'default' option
            ControlConfig(label: "Counter-Clockwise", shortPress: PuzzleKeycodes.leftKeypress, longPress: PuzzleKeycodes.middleKeypress, imageName: "arrow.counterclockwise"),
            ControlConfig(label: "Lock", shortPress: PuzzleKeycodes.middleKeypress, longPress: .none, imageName: "lock"),
            ControlConfig(label: "Center", shortPress: PuzzleKeycodes.leftKeypress, longPress: .none),  // Move centre: Ctrl + arrow keys
            ControlConfig(label: "Shift", shortPress: PuzzleKeycodes.leftKeypress, displayCondition: { gameId in // Shift grid: Shift + arrow keys
                // Variaions of Net have a 'wrapping' mode, indicated by a leading "5x5w:" in the game ID. We're looking for the 'w:'
                return gameId.contains("w:")
            })
        ],
        buttonControls: [
            ControlConfig(label: "Jumble", command: ButtonPress(for: "j")),
        ]

    )
}
