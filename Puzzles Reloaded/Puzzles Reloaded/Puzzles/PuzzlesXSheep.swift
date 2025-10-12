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
        puzzle_sticks,
        puzzle_subsets
    ]}
    
    // MARK: ABCD
    static let puzzle_abcd = GameConfig(
        identifier: "abcd",
        customParamInfo: String(localized: "abcd_params", table: "Puzzles"),
        internalGame: abcd,
        overflowMenuControls: [
            ControlConfig.MarksControl
        ]
    )
    .numericButtonsBuilder({ gameId in
        // Game ID looks like: 5x5n4:0,2,2,1,1,1,1,2,0,1,3,1,1,1,1,2,2,1,1,1,0,2,2,1,2,1,0,2,1,0,2,2,1,1,2,1,0,2,2,1,
        // {width}x{height}n{numLetters}{D for disable diagonals}:...
        
        let regex = gameId.firstMatch(of: /n(\d+)[D]?:/)
        let numButtons = Int(regex?.1 ?? "0")
        //print("ABCD: NumButtons: \(numButtons!)")
        
        //let numButtons = Int(gameId.split(separator: ":")[0])
        return Puzzles.createButtonControls(numButtons ?? 0, keycodes: Puzzles.AlphaButtons)
    })
    .addSearchTerms(["Kombi"])
    .setDarkModeColors([
        1: (Theming.background, "Innter Background"),
        2: (Theming.white, "Grid"),
        3: (Theming.midGray, "Border Letter"),
        4: (Theming.text, "Text"),
        8: (Theming.veryDarkGray, "Highlight")
    ])
    
    
    // MARK: Ascent
    static let puzzle_ascent = GameConfig(
        identifier: "ascent",
        internalGame: ascent
    )
        .addSearchTerms(["Hidato"])
    .setDarkModeColors([
        1: (Theming.veryDarkGray, "Lowlight - Selected Field"),
        2: (Theming.darkGray, "Highlight - Line & Endpoints"),
        3: (Theming.white, "Border and Entered Clues"),
        //4: (Theming.turboBlue, "Line"),
        5: (Theming.enteredTextBlue, "Immutable Text"),
        //6: (Theming.veryDarkGray, "Error")
    ])
    
    // MARK: Boats
    static let puzzle_boats = GameConfig(
        identifier: "boats",
        customParamInfo: String(localized: "boats_params", table: "Puzzles"),
        internalGame: boats
    )
    .setDarkModeColors([
        1: (Theming.midGray, "Grid"),
        4: (Theming.darkGray, "Water"),
        //3: (Theming.text, "Border and Entered Clues"),
        //4: (Theming.turboBlue, "Line"),
        5: (Theming.black, "Unchangable Ship Clue"),
        6: (Theming.enteredTextBlue, "Ship Guess"),
        11: (Theming.text, "Numbers")
        //6: (Theming.veryDarkGray, "Error")
    ])
    .addSearchTerms(["Battleships"])
    
    // MARK: Bricks
    static let puzzle_bricks = GameConfig(
        identifier: "bricks",
        internalGame: bricks
    )
    .setDarkModeColors([
        1: (Theming.darkGray, "Lowlight"),
        2: (Theming.darkGray, "Starting Clues and Deselected"),
        3: (Theming.text, "Border"),
        4: (Theming.enteredTextBlue, "Shaded Boxes")
        
    ])
    .addSearchTerms(["Tawamurenga"])

    
    // MARK: Clusters
    static let puzzle_clusters = GameConfig(
        identifier: "clusters",
        internalGame: clusters
    )
    .setDarkModeColors([
        1: (Theming.text, "Grid"),
    ])
    .addSearchTerms(["Kurasuta"])
    
    // MARK: Mathrax
    static let puzzle_mathrax = GameConfig(
        identifier: "mathrax",
        customParamInfo: String(localized: "mathrax_params", table: "Puzzles"),
        internalGame: mathrax
    )
    .numericButtonsBuilder({ gameId in
        // Game ID: 5:r4f,eM4dA6aS1A6A5a
        // We need that first number
        
        guard !gameId.isEmpty else {
            return []
        }
        
        let numButtons = Int(gameId.split(separator: ":")[0])
        return Puzzles.createButtonControls(numButtons ?? 0)
    })
    .setDarkModeColors([
        1: (Theming.darkGray, "Highlight - Clue Circles"),
        2: (Theming.veryDarkGray, "Lowlight - Selected Fields"),
        3: (Theming.white, "Border"),
        4: (Theming.enteredTextBlue, "Guess"),
        7: (Theming.warningRed, "Error Background")
    ])
    
    // MARK: Rome
    static let puzzle_rome = GameConfig(
        identifier: "rome",
        internalGame: rome
    )
    .setDarkModeColors([
        1: (Theming.darkGray, "Highlight"),
        2: (Theming.veryDarkGray, "Lowlight"),
        3: (Theming.white, "Border"),
        4: (Theming.white, "Fixed Arrow"),
        5: (Theming.enteredTextGreen, "Guessed Arrow"),
        8: (Theming.enteredTextBlue, "Arrow Entry"),
        9: (Theming.warningRed, "Error Background"),
        10: (Theming.darkGray, "Goal Background"),
        //11: (Theming.warningRed, "Goal")
    ])
    .addSearchTerms(["Roma", "Arrows"])
    
    // MARK: Salad
    static let puzzle_salad = GameConfig(
        identifier: "salad",
        customParamInfo: String(localized: "salad_params", table: "Puzzles"),
        internalGame: salad
    )    
    .numericButtonsBuilder({ gameId in
        // Game ID:
        // 4:4 a-c: 4n3L:aCACcCeCAa,p
        // 5x5 a-c: 5n3L:aAaAaCbBaBCaCCe,y
        // 6x6 1-3: 6n3B:Xa1cX3aXb2dOgXXXe1X3
        // 6x6 a-d: 6n4L:CaDCeACAaBCbAeC,zj
        // 6x6 1-4: 6n4B:aX1Xb4gXeX1aXaXa42b2c1
        // {gridSize}n{numCount}{InputType}:...
        
        guard !gameId.isEmpty else {
            return []
        }
        
        let regex = /[^n]+$/ // Matches everything after the 'n' in the substring
        let numberRegex = /\d/ // In case numbers get larger than 9, let's use a regex to ensure that we pull all values out correctly.
        let inputTypeRegex = /L|B/
        
        let gameIdPrefix = gameId.split(separator: ":")[0] // "4n3L"
        let gameDetails = gameIdPrefix.firstMatch(of: regex) // "3L"
        let numButtons = gameDetails?.output.firstMatch(of: numberRegex) // "3"
        let inputType =  gameDetails?.output.last // "L"
        
        
        // Pass in the correct array based on the gameId: "L" indicates letters, while "B" is numbers.
        let puzzleInputArray = inputType == "L" ? Puzzles.AlphaButtons : Puzzles.NumericButtons
        let numButtonsForReal = Int(numButtons?.output ?? "3")
        
        var buttonControls = Puzzles.createButtonControls(numButtonsForReal ?? 3, keycodes: puzzleInputArray)
        
        // Add the custom X and O Buttons for Salad controls
        buttonControls.append(ControlConfig(label: "X", command: ButtonPress(for: "X")))
        buttonControls.append(ControlConfig(label: "O", command: ButtonPress(for: "O")))
        
        //return Puzzles.createButtonControls(numButtons ?? 0)
        return buttonControls
    })
    .setDarkModeColors([
        1: (Theming.midGray, "Highlight"),
        2: (Theming.darkGray, "Lowlight"),
        3: (Theming.midGray, "Border"),
        4: (Theming.text, "Border Clue"),
        6: (Theming.text, "Immutable - Number"),
        7: (Theming.lightGray, "Immutable - Ball"),
        8: (Theming.darkGray, "Immutable - Ball Background"),
        9: (Theming.text, "Immutable - Hole"),
        10: (Theming.enteredTextBlue, "Guess - Number"),
        11: (Theming.enteredTextBlue, "Guess - Ball Outline"),
        12: (Theming.darkGray, "Guess - Ball Background"),
        13: (Theming.enteredTextBlue, "Guess - Hole")
    ])
    
    // MARK: Spokes
    static let puzzle_spokes = GameConfig(
        identifier: "spokes",
        internalGame: spokes
    )
    .setDarkModeColors([
        1: (Theming.darkGray, "Border"),
        2: (Theming.enteredTextGreen, "Holding"),
        3: (Theming.white, "Line & Text"),
        4: (Theming.enteredTextBlue, "Mark"),
        5: (Theming.veryDarkGray, "Done")
    ])

    
    // MARK: Sticks
    static let puzzle_sticks = GameConfig(
        identifier: "sticks",
        customParamInfo: String(localized: "sticks_params", table: "Puzzles"),
        internalGame: sticks
    )
    .setDarkModeColors([
        1: (Theming.lightGray, "Grid"),
        2: (Theming.turboBlue, "Line"),
        3: (Theming.black, "Number"),
    ])
    .addSearchTerms(["Tatebo Yokobo"])
    
    static let puzzle_subsets = GameConfig(
        identifier: "subsets",
        customParamInfo: String(localized: "subsets_params", table: "Puzzles"),
        internalGame: subsets
    )
    .setDarkModeColors([
        1: (Theming.midGray, "Inner Background - Guessing Squares"),
        2: (Theming.white, "Grid"),
        3: (Theming.veryDarkGray, "Highlight - Selected Squares"),
        4: (Theming.darkGray, "Lowlight"),
        5: (Theming.text, "Fixed Clue"),
        6: (Theming.enteredTextBlue, "Guess")
    ])
}
