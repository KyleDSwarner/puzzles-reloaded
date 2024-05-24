//
//  Unruly.swift
//  Puzzles
//
//  Created by Kyle Swarner on 4/19/24.
//  Copyright © 2024 Kyle Swarner. All rights reserved.
//

import Foundation

extension Puzzles {
    static let puzzle_unruly = GameConfig(
        name: "unruly",
        descritpion: "aint no rules",
        game: unruly, 
        isExperimental: false,
        touchControls: [
            //ControlConfig(label: "Black Blocks First", shortPress: .leftClick, longPress: .rightClick, imageName: "square.fill.black", isSystemImage: false),
            //ControlConfig(label: "White Blocks First", shortPress: .rightClick, longPress: .leftClick, imageName: "square.fill.white", isSystemImage: false),
            ControlConfig(label: "Fill Blocks", shortPress: PuzzleKeycodes.leftKeypress, longPress: PuzzleKeycodes.rightKeypress, imageName: "square.fill"),
            ControlConfig(label: "Clear", shortPress: PuzzleKeycodes.middleKeypress, longPress: PuzzleKeycodes.leftKeypress, imageName: "square.slash")
        ]
    )
}
