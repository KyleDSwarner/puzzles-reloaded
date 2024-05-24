//
//  Undead.swift
//  Puzzles
//
//  Created by Kyle Swarner on 4/26/24.
//  Copyright © 2024 Kyle Swarner. All rights reserved.
//


extension Puzzles {
    static let puzzle_undead = GameConfig(
        name: "undead",
        descritpion: "spooky!",
        game: undead,
        isExperimental: false,
        displayClearButtonInToolbar: true,

        buttonControls: [
            ControlConfig(label: "Ghost", command: ButtonPress(for: "G"), imageName: "ghost", isSystemImage: false, displayTextWithIcon: false),
            ControlConfig(label: "Vampire", command: ButtonPress(for: "V"), imageName: "vampire", isSystemImage: false, displayTextWithIcon: false),
            ControlConfig(label: "Zombie", command: ButtonPress(for: "Z"), imageName: "zombie", isSystemImage: false, displayTextWithIcon: false),
             //ControlConfig(label: "Erase Square", command: PuzzleKeycodes.ClearButton, imageName: "square.slash"),
        ]
    )
}

extension ControlOptionsS {
    static let undead_ghost = ControlOptionsS(rawValue: "undead_ghost")
    static let undead_vampire = ControlOptionsS(rawValue: "undead_vampire")
    static let undead_zombie = ControlOptionsS(rawValue: "undead_zombie")
}
