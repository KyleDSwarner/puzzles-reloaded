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
        puzzle_spokes,
        puzzle_sticks
    ]}
    
    // MARK: ABCD
    static let puzzle_abcd = GameConfig(
        name: "abcd",
        descritpion: "efg",
        imageName: "abcd",
        helpPage: HelpModel(gameDescription: """
            Hello, I am a multiline file.
        
            **This Works** Cool.
        """, gameControls: "Goodbye"),
        game: abcd
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
    
    // MARK: Spokes
    static let puzzle_spokes = GameConfig(
        name: "Spokes",
        descritpion: "Connect all hubs using horizontal, vertical and diagonal lines.",
        imageName: "spokes",
        game: spokes
    )
    
    // MARK: Sticks
    static let puzzle_sticks = GameConfig(
        name: "Sticks",
        descritpion: "Fill in the grid with horizontal and vertical line segments",
        imageName: "sticks",
        game: sticks
    )
}
