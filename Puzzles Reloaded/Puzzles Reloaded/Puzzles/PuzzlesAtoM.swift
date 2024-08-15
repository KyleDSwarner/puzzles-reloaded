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
        name: String(localized: "blackbox_name", table: "Puzzles"),
        description: String(localized: "blackbox_description", table: "Puzzles"),
        instructions: String(localized: "blackbox_instructions", table: "Puzzles"),
        controlInfo: String(localized: "blackbox_controls", table: "Puzzles"),
        imageName: "blackbox",
        internalGame: blackbox
    )
    
    // MARK: Bridges
    static let puzzle_bridges = GameConfig(
        name: String(localized: "bridges_name", table: "Puzzles"),
        description: String(localized: "bridges_description", table: "Puzzles"),
        instructions: String(localized: "bridges_instructions", table: "Puzzles"),
        controlInfo: String(localized: "bridges_controls", table: "Puzzles"),
        imageName: "bridges",
        internalGame: bridges,
        overflowMenuControls: [
            ControlConfig(label: "Mark Neighbors", command: ButtonPress(for: "G"))
        ]
    )
    
    // MARK: Cube
    static let puzzle_cube = GameConfig(
        name: String(localized: "cube_name", table: "Puzzles"),
        description: String(localized: "cube_description", table: "Puzzles"),
        instructions: String(localized: "cube_instructions", table: "Puzzles"),
        controlInfo: String(localized: "cube_controls", table: "Puzzles"),
        imageName: "cube",
        internalGame: cube)
    
    // MARK: Dominosa
    static let puzzle_dominosa = GameConfig(
        name: String(localized: "dominosa_name", table: "Puzzles"),
        description: String(localized: "dominosa_description", table: "Puzzles"),
        instructions: String(localized: "dominosa_instructions", table: "Puzzles"),
        controlInfo: String(localized: "dominosa_controls", table: "Puzzles"),
        imageName: "dominosa",
        internalGame: dominosa
    )
    
    // MARK: Fifteen
    static let puzzle_fifteen = GameConfig(
        name: String(localized: "fifteen_name", table: "Puzzles"),
        description: String(localized: "fifteen_description", table: "Puzzles"),
        instructions: String(localized: "fifteen_instructions", table: "Puzzles"),
        controlInfo: String(localized: "fifteen_controls", table: "Puzzles"),
        imageName: "fifteen",
        internalGame: fifteen
    )
    
    // MARK: Filling
    static let puzzle_filling = GameConfig(
        name: String(localized: "filling_name", table: "Puzzles", comment: "Display name for the game 'filling'"),
        description: String(localized: "filling_description", table: "Puzzles", comment: "Short description for the game 'filling'"),
        instructions: String(localized: "filling_instructions", table: "Puzzles"),
        controlInfo: String(localized: "filling_controls", table: "Puzzles"),
        imageName: "filling",
        internalGame: filling,
        displayClearButtonInToolbar: true
    ).numericButtonsBuilder({ gameId in
        // Filling always displays all 10 number buttons as any number can be used at any size.
        // The game ID doesn't provide any additional information -> 13x9:5a6b777a4b455b7a7765e5b8c4a3a4a9c8a6b3a8a9a5d2724b9d63e8d3b3a7b433a82b2e3b9c53b
        return Puzzles.createButtonControls(10)
    })
    
    // MARK: Flip
    static let puzzle_flip = GameConfig(
        name: String(localized: "flip_name", table: "Puzzles"),
        description: String(localized: "flip_description", table: "Puzzles"),
        instructions: String(localized: "flip_instructions", table: "Puzzles"),
        controlInfo: String(localized: "flip_controls", table: "Puzzles"),
        imageName: "flip",
        internalGame: flip
    )
    
    // MARK: Flood
    static let puzzle_flood = GameConfig(
        name: String(localized: "flood_name", table: "Puzzles"),
        description: String(localized: "flood_description", table: "Puzzles"),
        instructions: String(localized: "flood_instructions", table: "Puzzles"),
        controlInfo: String(localized: "flood_controls", table: "Puzzles"),
        imageName: "flood",
        internalGame: flood,
        touchControls: [ControlConfig(label: "", shortPress: PuzzleKeycodes.leftKeypress, longPress: .none)] // Left click only, disables long presses
    )
    
    // MARK: Galaxies
    static let puzzle_galaxies = GameConfig(
        name: String(localized: "galaxies_name", table: "Puzzles"),
        description: String(localized: "galaxies_description", table: "Puzzles"),
        instructions: String(localized: "galaxies_instructions", table: "Puzzles"),
        controlInfo: String(localized: "galaxies_controls", table: "Puzzles"),
        imageName: "galaxies",
        internalGame: galaxies,
        allowSingleFingerPanning: false
    )
    
    // MARK: Guess
    static let puzzle_guess = GameConfig(
        name: String(localized: "guess_name", table: "Puzzles"),
        description: String(localized: "guess_description", table: "Puzzles"),
        instructions: String(localized: "guess_instructions", table: "Puzzles"),
        controlInfo: String(localized: "guess_controls", table: "Puzzles"),
        imageName: "guess",
        internalGame: guess,
        allowSingleFingerPanning: false
    )
    
    // MARK: Inertia
    static let puzzle_intertia = GameConfig(
        name: String(localized: "intertia_name", table: "Puzzles"),
        description: String(localized: "intertia_description", table: "Puzzles"),
        instructions: String(localized: "intertia_instructions", table: "Puzzles"),
        controlInfo: String(localized: "intertia_controls", table: "Puzzles"),
        imageName: "inertia",
        internalGame: inertia,
        allowSingleFingerPanning: false
    )
    
    // MARK: Keen
    static let puzzle_keen = GameConfig(
        name: String(localized: "keen_name", table: "Puzzles"),
        description: String(localized: "keen_description", table: "Puzzles"),
        instructions: String(localized: "keen_instructions", table: "Puzzles"),
        controlInfo: String(localized: "keen_controls", table: "Puzzles"),
        imageName: "keen",
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
        name: String(localized: "lightup_name", table: "Puzzles"),
        description: String(localized: "lightup_description", table: "Puzzles"),
        instructions: String(localized: "lightup_instructions", table: "Puzzles"),
        controlInfo: String(localized: "lightup_controls", table: "Puzzles"),
        imageName: "lightup",
        internalGame: lightup
    )
    
    // MARK: Loopy
    static let puzzle_loopy = GameConfig(
        name: String(localized: "loopy_name", table: "Puzzles"),
        description: String(localized: "loopy_description", table: "Puzzles"),
        instructions: String(localized: "loopy_instructions", table: "Puzzles"),
        controlInfo: String(localized: "loopy_controls", table: "Puzzles"),
        imageName: "loopy",
        internalGame: loopy,
        allowSingleFingerPanning: true
    )
    
    // MARK: Magnets
    static let puzzle_magnets = GameConfig(
        name: String(localized: "magnets_name", table: "Puzzles"),
        description: String(localized: "magnets_description", table: "Puzzles"),
        instructions: String(localized: "magnets_instructions", table: "Puzzles"),
        controlInfo: String(localized: "magnets_controls", table: "Puzzles"),
        imageName: "magnets",
        internalGame: magnets
    )
    
    // MARK: MAP
    static let puzzle_map = GameConfig(
        name: String(localized: "map_name", table: "Puzzles"),
        description: String(localized: "map_description", table: "Puzzles"),
        instructions: String(localized: "map_instructions", table: "Puzzles"),
        controlInfo: String(localized: "map_controls", table: "Puzzles"),
        imageName: "map",
        internalGame: map,
        allowSingleFingerPanning: false,
        overflowMenuControls: [
            ControlConfig(label: "Add Labels", command: ButtonPress(for: "L"))
        ]
    )
    
    // MARK: Mines
    static let puzzle_mines = GameConfig(
        name: String(localized: "mines_name", table: "Puzzles"),
        description: String(localized: "mines_description", table: "Puzzles"),
        instructions: String(localized: "mines_instructions", table: "Puzzles"),
        controlInfo: String(localized: "mines_controls", table: "Puzzles"),
        imageName: "mines",
        internalGame: mines,
        allowSingleFingerPanning: true
    )
    
    // MARK: Mosaic
    static let puzzle_mosaic = GameConfig(
        name: String(localized: "mosaic_name", table: "Puzzles"),
        description: String(localized: "mosaic_description", table: "Puzzles"),
        instructions: String(localized: "mosaic_instructions", table: "Puzzles"),
        controlInfo: String(localized: "mosaic_controls", table: "Puzzles"),
        imageName: "mosaic",
        internalGame: mosaic
    )
    
}
