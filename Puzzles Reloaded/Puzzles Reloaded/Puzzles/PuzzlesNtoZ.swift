//
//  PuzzlesNtoZ.swift
//  Puzzles Reloaded
//
//  Created by Kyle Swarner on 5/24/24.
//  Copyright © 2024 Kyle Swarner. All rights reserved.
//

import Foundation

extension Puzzles {
    
    // MARK: Netslide
    static let puzzle_netslide = GameConfig(
        name: "Netslide",
        descritpion: "Net, but more",
        imageName: "netslide",
        game: netslide
    )
    
    // MARK: Pattern
    static let puzzle_pattern = GameConfig(
        name: "Pattern",
        descritpion: "A pretty one!",
        imageName: "pattern",
        game: pattern,
        touchControls: [ // TODO: We'll need special handling for these controls in Net.
            ControlConfig(label: "Black Boxes", shortPress: PuzzleKeycodes.leftKeypress, longPress: PuzzleKeycodes.rightKeypress, imageName: "square.fill", imageColor: .black),
            ControlConfig(label: "White Boxes", shortPress: PuzzleKeycodes.rightKeypress, longPress: PuzzleKeycodes.leftKeypress, imageName: "square.fill", imageColor: .white),
            ControlConfig(label: "Clear", shortPress: PuzzleKeycodes.middleKeypress, longPress: .none, imageName: "square.slash"),
        ]
    )
    
    // MARK: Pearl
    static let puzzle_pearl = GameConfig(
        name: "Pearl",
        descritpion: "Like from a clam",
        imageName: "pearl",
        game: pearl,
        allowSingleFingerPanning: false
    )
    
    // MARK: Pegs
    static let puzzle_pegs = GameConfig(
        name: "Pegs",
        descritpion: "I played this a lot at cracker barrel",
        imageName: "pegs",
        game: pegs,
        allowSingleFingerPanning: false
    )
    
    // MARK: Range
    static let puzzle_range = GameConfig(
        name: "Range",
        descritpion: "down on the this",
        imageName: "range",
        game: range
    )
    
    // MARK: Rectangles
    static let puzzle_rectangles = GameConfig(
        name: "Rectangles",
        descritpion: "These angles are so Rect",
        imageName: "rect",
        game: rect
    )
    
    // MARK: Singles
    static let puzzle_singles = GameConfig(
        name: "Singles",
        descritpion: "Black out the right set of duplicate numbers",
        imageName: "singles",
        game: singles
    )
    
    // MARK: Sixteen
    static let puzzle_sixteen = GameConfig(
        name: "Sixteen",
        descritpion: "Slide the grid squares around so that the numbers end up in consecutive order from the top left corner",
        imageName: "sixteen",
        game: sixteen
    )
    
    // MARK: Slant
    static let puzzle_slant = GameConfig(
        name: "Slant",
        descritpion: "--slant--",
        imageName: "slant",
        game: slant
    )
    
    // MARK: Solo
    static let puzzle_solo = GameConfig(
        name: "Solo",
        descritpion: "--solo--",
        imageName: "solo",
        game: solo,
        displayClearButtonInToolbar: true,
        buttonControls: [
            // ControlConfig(label: "Clear", command: PuzzleKeycodes.ClearButton, imageName: "square.slash"),
        ]
    ).numericButtonsBuilder({ gameId in
        //print("Solo: \(gameId)")
        /*
         We have several game IDs we need to look for here:
            Standard grid: 3x3:b4_5e3_6a1e5b3_2a9a4a2a8a5_4_7k7_8_9a1a2a7a6a1_8b9e2a8_6e9_5b
            Jigsaw grid: 12j:.... (we just extract the number before the j)
            Jigsaw gris with x: 9jx:.... (We still need the first number, but taking extra care of the additional x in our regex)
         
            To process these values, we extract all numbers preceeding the colon & multiply them together.
         */
        guard gameId.contains(":") else {
            return []
        }
        
        let digitRegex = /\d+/
            
        let gameInfo = gameId.split(separator: ":")[0]
        
        let matches = gameInfo.matches(of: digitRegex)
        
        let numButtons = matches.reduce(1) { result, match in
            return result * (Int(match.output) ?? 1)
        }
        
        return Puzzles.createButtonControls(numButtons, keycodes: Puzzles.HexidecimalButtons)
            
    })
    

    
    // MARK: Tracks
    static let puzzle_tracks = GameConfig(
        name: "Tracks",
        descritpion: "--tracks--",
        imageName: "tracks",
        game: tracks
    )
    
    // MARK: Twiddle
    static let puzzle_twiddle = GameConfig(
        name: "Twiddle",
        descritpion: "--twiddle--",
        imageName: "twiddle",
        game: twiddle
    )
}
