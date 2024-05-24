//
//  PuzzlesAtoM.swift
//  Puzzles
//
//  Created by Kyle Swarner on 5/23/24.
//  Copyright © 2024 Kyle Swarner. All rights reserved.
//

import Foundation

extension Puzzles {
    static var puzzlesAtoM: [GameConfig] {[
        puzzle_abcd,
        puzzle_ascent,
    ]}
}

extension Puzzles {
    

    
    // MARK: Ascent
    static let puzzle_ascent = GameConfig(
        name: "Ascent",
        descritpion: "captain kirk is climbing a mountain, why is he climbing that mountain?",
        imageName: "ascent",
        game: ascent
    )
    
    // MARK: Flood
    static let puzzle_flood = GameConfig(
        name: "flood",
        descritpion: "oh no a flood",
        game: flood
    )
    
    // MARK: Inertia
    static let puzzle_intertia = GameConfig(
        name: "Intertia",
        descritpion: "get your mass in gear",
        imageName: "intertia",
        game: inertia,
        allowSingleFingerPanning: false
    )
    
    // MARK: Keen
    static let puzzle_keen = GameConfig(
        name: "Keen",
        descritpion: "Goodbye Galaxy",
        imageName: "keen",
        game: keen,
        allowSingleFingerPanning: false,
        displayClearButtonInToolbar: true
    ).numericButtonsBuilder({gameId in
            // 6:_a3_a_a3_aa_a3ba_7aa_10a3,m100d3s3a5a9d2a10m6m4s2s2d3m8m60a5s2
        
            guard !gameId.isEmpty else {
                return []
            }
            
            let numButtons = Int(gameId.split(separator: ":")[0])
            return Puzzles.createButtonControls(numButtons ?? 0)
    })
    
    // MARK: Light Up
    static let puzzle_lightup = GameConfig(
        name: "Light Up",
        descritpion: "like a flashlight",
        imageName: "lightup",
        game: lightup
    )
    
    // MARK: Magnets
    static let puzzle_magnets = GameConfig(
        name: "Magnets",
        descritpion: "my kind of personality",
        imageName: "magnets",
        game: magnets
    )
    
    // MARK: MAP
    static let puzzle_map = GameConfig(
        name: "Map",
        descritpion: "East? I thought you said 'Weast'",
        imageName: "map",
        game: map,
        allowSingleFingerPanning: false,
        overflowMenuControls: [
            ControlConfig(label: "Add Labels", command: ButtonPress(for: "L"))
        ]
    )
    
    // MARK: Mines
    static let puzzle_mines = GameConfig(
        name: "Mines",
        descritpion: "kaboom",
        imageName: "mines",
        game: mines,
        allowSingleFingerPanning: true
    )
    
}
