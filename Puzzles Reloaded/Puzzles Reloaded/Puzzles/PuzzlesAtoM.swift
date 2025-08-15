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
    .setSaveIdentifier("Black Box")
    .setDarkModeColors([
        3: (Theming.white, "Text"),
        2: (Theming.white, "Text"),
    ])
    
    
    // MARK: Bridges
    static let puzzle_bridges = GameConfig(
        identifier: "bridges",
        internalGame: bridges,
        overflowMenuControls: [
            ControlConfig(label: "Mark Neighbors", command: ButtonPress(for: "G"))
        ]
    )
    .setDarkModeColors([
        //1: (Theming.white, "Grid"),
        1: (Theming.text, "Primary Grid Color"),
        2: (Theming.veryDarkGray, "Highlight - Finished Puzzle"),
        //4: (Theming.turboBlue, "Selected Box"),
        5: (Theming.darkGray, "Marked and Locked Islands"),
        6: (Theming.veryDarkGray, "Hint"), // Mark Neighbors
        7: (Theming.white, "Grid"),
        //8: (Theming.warningRed, "Warning Color")
    ])
    
    // MARK: Cube
    static let puzzle_cube = GameConfig(
        identifier: "cube",
        internalGame: cube)
    .setDarkModeColors([
        //1: (Theming.white, "Grid"),
        1: (Theming.white, "Border"),
        // 2: (Theming.lightGray, "Blue Color"),
        //8: (Theming.warningRed, "Warning Color")
    ])
    
    // MARK: Dominosa
    static let puzzle_dominosa = GameConfig(
        identifier: "dominosa",
        internalGame: dominosa
    )
    .setDarkModeColors([
        //1: (Theming.white, "Grid"),
        1: (Theming.text, "Text"),
        2: (Theming.darkGray, "Domino"),
        4: (Theming.text, "Domino Text"),
    ])
    
    // MARK: Fifteen
    static let puzzle_fifteen = GameConfig(
        identifier: "fifteen",
        internalGame: fifteen,
        // overflowMenuControls: [ControlConfig.HintControl] Disabled because it's very unweidly!
    )
    .setDarkModeColors([
        //1: (Theming.white, "Grid"),
        1: (Theming.text, "Text"),
        2: (Theming.lightGray, "Highlight"),
        4: (Theming.darkGray, "Lowlight")
    ])
    
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
        .setDarkModeColors([
            //1: (Theming.white, "Grid"),
            1: (Theming.white, "Grid"),
            2: (Theming.darkGray, "Highlight Selection"),
            3: (Theming.veryDarkGray, "Locked Box Highlight"),
            4: (Theming.warningRed, "Error Box"),
            5: (Theming.enteredTextGreen, "Player Guess")
            //3: (Theming.warningRed, "Lowlight")
        ])
    
    // MARK: Flip
    static let puzzle_flip = GameConfig(
        identifier: "flip",
        internalGame: flip
    )
    .setDarkModeColors([
        //1: (Theming.white, "Grid"),
        1: (Theming.veryDarkGray, "Wrong"),
        2: (Theming.lightGray, "Right"),
        //3: (Theming.veryDarkGray, "Locked Box Highlight"),
        //4: (Theming.warningRed, "Error Box"),
        //5: (Theming.enteredTextGreen, "Player Guess")
        //3: (Theming.warningRed, "Lowlight")
    ])
    
    /*
    enum {
        COL_BACKGROUND,
        COL_WRONG,
        COL_RIGHT,
        COL_GRID,
        COL_DIAG,
        COL_HINT,
        COL_CURSOR,
        NCOLOURS
    };
     */
    
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
    .addSearchTerms(["Tentai", "Spiral"])
    .setDarkModeColors([
        //1: (Theming.white, "Grid"),
        1: (Theming.darkGray, "Background for Completed Squares"),
        3: (Theming.midGray, "Dots"),
        5: (Theming.white, "Grid"),
        6: (Theming.midGray, "Game Border")
    ])
    
    // MARK: Guess
    static let puzzle_guess = GameConfig(
        identifier: "guess",
        internalGame: guess,
        allowSingleFingerPanning: false
    )
        .addSearchTerms(["Mastermind"])
        .setDarkModeColors([
            1: (Theming.darkGray, "Grid"),
            //1: (Theming.darkGray, "Background for Completed Squares"),
            //3: (Theming.midGray, "Dots"),
            5: (Theming.darkGray, "Empty Field"),
            16: (Theming.enteredTextGreen, "Correct Guess"),
            //6: (Theming.midGray, "Game Border")
        ])
    
    // MARK: Inertia
    static let puzzle_intertia = GameConfig(
        identifier: "inertia",
        internalGame: inertia,
        allowSingleFingerPanning: false
    )
    .setDarkModeColors([
        1: (Theming.lightGray, "Outline"),
        2: (Theming.lightGray, "Highlight"),
        3: (Theming.darkGray, "Lowlight"),
        6: (Theming.darkGray, "Mines"),
        8: (Theming.midGray, "Walls"),
        //1: (Theming.darkGray, "Background for Completed Squares"),
        //3: (Theming.midGray, "Dots"),
        //5: (Theming.darkGray, "Empty Field"),
        //16: (Theming.enteredTextGreen, "Correct Guess"),
        //6: (Theming.midGray, "Game Border")
    ])

    
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
        .addSearchTerms(["KenKen", "Ken Ken"])
    .setDarkModeColors([
        1: (Theming.text, "Grid"),
        2: (Theming.text, "User Entry"),
        3: (Theming.darkGray, "Highlight"),
    ])
    
    
    // MARK: Light Up
    static let puzzle_lightup = GameConfig(
        identifier: "lightup",
        internalGame: lightup,
        allowSingleFingerPanning: true
    ).setSaveIdentifier("Light Up")
    .setDarkModeColors([
        1: (Theming.midGray, "Grid"),
    ])
    
    /*
     enum {
         COL_BACKGROUND,
         COL_GRID,
         COL_BLACK,                   /* black */
         COL_LIGHT,                   /* white */
         COL_LIT,                   /* yellow */
         COL_ERROR,                   /* red */
         COL_CURSOR,
         NCOLOURS
     };
     
     <color name="lightup_night_colour_black">#666666</color>
     */
    
    // MARK: Loopy
    static let puzzle_loopy = GameConfig(
        identifier: "loopy",
        internalGame: loopy,
        allowSingleFingerPanning: true
    )
    .addSearchTerms(["Slitherlink", "Loop"])
    .setDarkModeColors([
        1: (Theming.white, "Foreground"),
        2: (Theming.darkGray, "Line Unknown"), // The highlighter Yellow Monstrosity
        5: (Theming.white, "Satisfied Number"),
        6: (Theming.veryDarkGray, "Faint Line")
        
    ])
    
    // MARK: Magnets
    static let puzzle_magnets = GameConfig(
        identifier: "magnets",
        internalGame: magnets
    )
    .setDarkModeColors([
        1: (Theming.white, "Highlight"),
        2: (Theming.midGray, "Lowlight"),
        3: (Theming.text, "Text"),
        6: (Theming.darkGray, "Deemphasied Text"),
        11: (Theming.text, "Magnet Symbols")
        // TODO: Symbols inside magnets use background color; Add new color to adapt?
        //10: (Theming.turboBlue, "Not")
        //9: (Theming.warningRed, "Positive Pole")
        
    ])
    /*
     
     enum {
         COL_BACKGROUND, COL_HIGHLIGHT, COL_LOWLIGHT,
         COL_TEXT, COL_ERROR, COL_CURSOR, COL_DONE,
         COL_NEUTRAL, COL_NEGATIVE, COL_POSITIVE, COL_NOT, /* COL_SYMBOL */
         NCOLOURS
     };
     <color name="magnets_night_colour_highlight">#888888</color>
         <color name="magnets_night_colour_text">#ffffff</color>
     */
    
    // MARK: Map
    static let puzzle_map = GameConfig(
        identifier: "map",
        internalGame: map,
        allowSingleFingerPanning: false,
        overflowMenuControls: [
            ControlConfig(label: "Add Labels", command: ButtonPress(for: "L"))
        ]
    )
    .setDarkModeColors([
        1: (Theming.lightGray, "Grid"),
        7: (Theming.white, "Error Text")
    ])
    
    // MARK: Mines
    static let puzzle_mines = GameConfig(
        identifier: "mines",
        internalGame: mines,
        allowSingleFingerPanning: true
    )
    .setDarkModeColors([
        // 1: (Theming.darkGray, "Background 2"),
        14: (Theming.white, "Flagbase"),
        15: (Theming.text, "Query"),
        16: (Theming.darkGray, "Highlight"),
        17: (Theming.veryDarkGray, "Lowlight")
    ])
    .addSearchTerms(["Minesweeper"])

    // MARK: Mosaic
    static let puzzle_mosaic = GameConfig(
        identifier: "mosaic",
        internalGame: mosaic
    )
        .addSearchTerms(["Magipic", "Count and Darken"])
    
}
