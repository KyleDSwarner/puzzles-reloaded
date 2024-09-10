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
        puzzle_blackbox,
        puzzle_bridges,
        puzzle_cube,
        puzzle_dominosa,
        puzzle_fifteen,
        puzzle_filling,
        puzzle_flip,
        puzzle_flood,
        puzzle_galaxies,
        puzzle_guess,
        puzzle_intertia,
        puzzle_keen,
        puzzle_lightup,
        puzzle_loopy,
        puzzle_magnets,
        puzzle_map,
        puzzle_mines,
        puzzle_mosaic
    ]}
}

extension Puzzles {
    
    // MARK: Blackbox
    static let puzzle_blackbox = GameConfig(
        identifier: "blackbox",
        internalGame: blackbox
    )
    
    // MARK: Bridges
    static let puzzle_bridges = GameConfig(
        identifier: "bridges",
        internalGame: bridges,
        overflowMenuControls: [
            ControlConfig(label: "Mark Neighbors", command: ButtonPress(for: "G"))
        ]
    )
    
    // MARK: Cube
    static let puzzle_cube = GameConfig(
        identifier: "cube",
        internalGame: cube)
    
    // MARK: Dominosa
    static let puzzle_dominosa = GameConfig(
        identifier: "dominosa",
        internalGame: dominosa
    )
    
    // MARK: Fifteen
    static let puzzle_fifteen = GameConfig(
        identifier: "fifteen",
        internalGame: fifteen
    )
    
    // MARK: Filling
    static let puzzle_filling = GameConfig(
        identifier: "filling",
        internalGame: filling,
        displayClearButtonInToolbar: true
    ).numericButtonsBuilder({ gameId in
        // Filling always displays all 10 number buttons as any number can be used at any size.
        // The game ID doesn't provide any additional information -> 13x9:5a6b777a4b455b7a7765e5b8c4a3a4a9c8a6b3a8a9a5d2724b9d63e8d3b3a7b433a82b2e3b9c53b
        return Puzzles.createButtonControls(10)
    })
    
    // MARK: Flip
    static let puzzle_flip = GameConfig(
        identifier: "flip",
        internalGame: flip
    )
    
    // MARK: Flood
    static let puzzle_flood = GameConfig(
        identifier: "flood",
        internalGame: flood,
        touchControls: [ControlConfig(label: "", shortPress: PuzzleKeycodes.leftKeypress, longPress: .none)] // Left click only, disables long presses
    )
    
    // MARK: Galaxies
    static let puzzle_galaxies = GameConfig(
        identifier: "galaxies",
        internalGame: galaxies,
        allowSingleFingerPanning: false
    )
    
    // MARK: Guess
    static let puzzle_guess = GameConfig(
        identifier: "guess",
        internalGame: guess,
        allowSingleFingerPanning: false
    )
    
    // MARK: Inertia
    static let puzzle_intertia = GameConfig(
        identifier: "inertia",
        internalGame: inertia,
        allowSingleFingerPanning: false
    )
    
    // MARK: Keen
    static let puzzle_keen = GameConfig(
        identifier: "keen",
        internalGame: keen,
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
        identifier: "lightup",
        internalGame: lightup
    )
    
    // MARK: Loopy
    static let puzzle_loopy = GameConfig(
        identifier: "loopy",
        internalGame: loopy,
        allowSingleFingerPanning: true
    )
    
    // MARK: Magnets
    static let puzzle_magnets = GameConfig(
        identifier: "magnets",
        internalGame: magnets
    )
    
    // MARK: Map
    static let puzzle_map = GameConfig(
        identifier: "map",
        internalGame: map,
        allowSingleFingerPanning: false,
        overflowMenuControls: [
            ControlConfig(label: "Add Labels", command: ButtonPress(for: "L"))
        ]
    )
    
    // MARK: Mines
    static let puzzle_mines = GameConfig(
        identifier: "mines",
        internalGame: mines,
        allowSingleFingerPanning: true
    )
    
    // MARK: Mosaic
    static let puzzle_mosaic = GameConfig(
        identifier: "mosaic",
        internalGame: mosaic
    )
    
}
