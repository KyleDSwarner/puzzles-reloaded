//
//  PuzzlesXSheep.swift
//  Puzzles Reloaded
//
//  Created by Kyle Swarner on 5/24/24.
//  Copyright © 2024 Kyle Swarner. All rights reserved.
//

import Foundation

extension Puzzles {
    
    static var puzzlesXsheep: [GameConfig] {[
        puzzle_abcd,
        puzzle_ascent,
        puzzle_boats,
        puzzle_bricks,
        puzzle_clusters,
        puzzle_mathrax,
        puzzle_rome,
        puzzle_salad,
        puzzle_spokes,
        puzzle_sticks
    ]}
    
    // MARK: ABCD
    static let puzzle_abcd = GameConfig(
        name: String(localized: "abcd_name", table: "Puzzles"),
        description: String(localized: "abcd_description", table: "Puzzles"),
        instructions: String(localized: "abcd_instructions", table: "Puzzles"),
        controlInfo: String(localized: "abcd_controls", table: "Puzzles"),
        customParamInfo: String(localized: "abcd_params", table: "Puzzles"),
        imageName: "abcd",
        internalGame: abcd
    )
    .numericButtonsBuilder({ gameId in
        // Game ID looks like: 5x5n4:0,2,2,1,1,1,1,2,0,1,3,1,1,1,1,2,2,1,1,1,0,2,2,1,2,1,0,2,1,0,2,2,1,1,2,1,0,2,2,1,
        // {width}x{height}n{numLetters}:...
        
        let regex = gameId.firstMatch(of: /n(\d+):/)
        let numButtons = Int(regex?.1 ?? "0")
        //print("ABCD: NumButtons: \(numButtons!)")
        
        //let numButtons = Int(gameId.split(separator: ":")[0])
        return Puzzles.createButtonControls(numButtons ?? 0, keycodes: Puzzles.AlphaButtons)
    })
    
    // MARK: Ascent
    static let puzzle_ascent = GameConfig(
        name: String(localized: "ascent_name", table: "Puzzles"),
        description: String(localized: "ascent_description", table: "Puzzles"),
        instructions: String(localized: "ascent_instructions", table: "Puzzles"),
        controlInfo: String(localized: "ascent_controls", table: "Puzzles"),
        imageName: "ascent",
        internalGame: ascent
    )
    
    // MARK: Boats
    static let puzzle_boats = GameConfig(
        name: String(localized: "boats_name", table: "Puzzles"),
        description: String(localized: "boats_description", table: "Puzzles"),
        instructions: String(localized: "boats_instructions", table: "Puzzles"),
        controlInfo: String(localized: "boats_controls", table: "Puzzles"),
        customParamInfo: String(localized: "boats_params", table: "Puzzles"),
        imageName: "boats",
        internalGame: boats
    )
    
    // MARK: Bricks
    static let puzzle_bricks = GameConfig(
        name: String(localized: "bricks_name", table: "Puzzles"),
        description: String(localized: "bricks_description", table: "Puzzles"),
        instructions: String(localized: "bricks_instructions", table: "Puzzles"),
        controlInfo: String(localized: "bricks_controls", table: "Puzzles"),
        imageName: "bricks",
        internalGame: bricks
    )
    
    // MARK: Clusters
    static let puzzle_clusters = GameConfig(
        name: String(localized: "clusters_name", table: "Puzzles"),
        description: String(localized: "clusters_description", table: "Puzzles"),
        instructions: String(localized: "clusters_instructions", table: "Puzzles"),
        controlInfo: String(localized: "clusters_controls", table: "Puzzles"),
        imageName: "clusters",
        internalGame: clusters
    )
    
    // MARK: Mathrax
    static let puzzle_mathrax = GameConfig(
        name: String(localized: "mathrax_name", table: "Puzzles"),
        description: String(localized: "mathrax_description", table: "Puzzles"),
        instructions: String(localized: "mathrax_instructions", table: "Puzzles"),
        controlInfo: String(localized: "mathrax_controls", table: "Puzzles"),
        customParamInfo: String(localized: "mathrax_params", table: "Puzzles"),
        imageName: "mathrax",
        internalGame: mathrax
    )
    
    // MARK: Rome
    static let puzzle_rome = GameConfig(
        name: String(localized: "rome_name", table: "Puzzles"),
        description: String(localized: "rome_description", table: "Puzzles"),
        instructions: String(localized: "rome_instructions", table: "Puzzles"),
        controlInfo: String(localized: "rome_controls", table: "Puzzles"),
        imageName: "rome",
        internalGame: rome
    )
    
    // MARK: Salad
    static let puzzle_salad = GameConfig(
        name: String(localized: "salad_name", table: "Puzzles"),
        description: String(localized: "salad_description", table: "Puzzles"),
        instructions: String(localized: "salad_instructions", table: "Puzzles"),
        controlInfo: String(localized: "salad_controls", table: "Puzzles"),
        customParamInfo: String(localized: "salad_params", table: "Puzzles"),
        imageName: "salad",
        internalGame: salad
    )
    
    // MARK: Spokes
    static let puzzle_spokes = GameConfig(
        name: String(localized: "spokes_name", table: "Puzzles"),
        description: String(localized: "spokes_description", table: "Puzzles"),
        instructions: String(localized: "spokes_instructions", table: "Puzzles"),
        controlInfo: String(localized: "spokes_controls", table: "Puzzles"),
        imageName: "spokes",
        internalGame: spokes
    )
    
    // MARK: Sticks
    static let puzzle_sticks = GameConfig(
        name: String(localized: "sticks_name", table: "Puzzles"),
        description: String(localized: "sticks_description", table: "Puzzles"),
        instructions: String(localized: "sticks_instructions", table: "Puzzles"),
        controlInfo: String(localized: "sticks_controls", table: "Puzzles"),
        customParamInfo: String(localized: "sticks_params", table: "Puzzles"),
        imageName: "sticks",
        internalGame: sticks
    )
}
