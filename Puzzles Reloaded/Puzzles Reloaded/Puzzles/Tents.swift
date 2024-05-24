//
//  Net.swift
//  Puzzles
//
//  Created by Kyle Swarner on 4/19/24.
//  Copyright © 2024 Kyle Swarner. All rights reserved.
//

extension Puzzles {
    static let puzzle_tents = GameConfig(
        name: "Tents",
        descritpion: "Let's Go Camping!",
        imageName: "tents",
        game: tents,

        touchControls: [
            ControlConfig(label: "Add and Remove Tents", shortPress: PuzzleKeycodes.leftKeypress, longPress: PuzzleKeycodes.rightKeypress, imageName: "square.fill.black", isSystemImage: false, imageColor: .black),
            ControlConfig(label: "Clear", shortPress: PuzzleKeycodes.middleKeypress, longPress: .none, imageName: "square.slash")
        ]
    )
}
