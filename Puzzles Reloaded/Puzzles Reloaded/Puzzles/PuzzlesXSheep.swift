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
    
    // MARK: Ascent
    static let puzzle_ascent = GameConfig(
        name: "Ascent",
        descritpion: "captain kirk is climbing a mountain, why is he climbing that mountain?",
        imageName: "ascent",
        game: ascent
    )
    
    // MARK: Boats
    static let puzzle_boats = GameConfig(
        name: "Boats",
        descritpion: "row row row your this",
        imageName: "boats",
        game: boats
    )
    
    // MARK: Bricks
    static let puzzle_bricks = GameConfig(
        name: "Bricks",
        descritpion: "build a building",
        imageName: "bricks",
        game: bricks
    )
    
    // MARK: Clusters
    static let puzzle_clusters = GameConfig(
        name: "Clusters",
        descritpion: "clustered!",
        imageName: "clusters",
        game: clusters
    )
    
    // MARK: Mathrax
    static let puzzle_mathrax = GameConfig(
        name: "Mathrax",
        descritpion: "Place each number according to the arithmetic clues",
        imageName: "mathrax",
        game: mathrax
    )
    
    // MARK: Rome
    static let puzzle_rome = GameConfig(
        name: "Rome",
        descritpion: "Fill the grid with arrows leadning to a goal",
        imageName: "rome",
        game: rome
    )
    
    // MARK: Salad
    static let puzzle_salad = GameConfig(
        name: "Salad",
        descritpion: "Place each character once in every row and column. Some squares remain empty",
        imageName: "salad",
        game: salad
    )
    
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
