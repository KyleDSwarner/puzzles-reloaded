//
//  PuzzlesNtoZ.swift
//  Puzzles Reloaded
//
//  Created by Kyle Swarner on 5/24/24.
//  Copyright © 2024 Kyle Swarner. All rights reserved.
//

import Foundation

extension Puzzles {
    static var puzzlesNtoZ: [GameConfig] {[
        puzzle_net,
        puzzle_netslide,
        puzzle_palisade,
        puzzle_pattern,
        puzzle_pearl,
        puzzle_pegs,
        puzzle_range,
        puzzle_rectangles,
        puzzle_samegame,
        puzzle_signpost,
        puzzle_singles,
        puzzle_sixteen,
        puzzle_slant,
        puzzle_solo,
        puzzle_tents,
        puzzle_towers,
        puzzle_tracks,
        puzzle_twiddle,
        puzzle_undead,
        puzzle_unequal,
        puzzle_unruly,
        puzzle_untangle
    ]}
}

extension Puzzles {
    
    // MARK: Net
    static let puzzle_net = GameConfig(
        identifier: "net",
        internalGame: net,
        touchControls: [
            ControlConfig(label: String(localized: "Counter-Clockwise"), shortPress: PuzzleKeycodes.leftKeypress, longPress: PuzzleKeycodes.middleKeypress, imageName: "arrow.counterclockwise"),
            ControlConfig(label: String(localized: "Clockwise"), shortPress: PuzzleKeycodes.rightKeypress, longPress: PuzzleKeycodes.middleKeypress, imageName: "arrow.clockwise"),
            ControlConfig(label: String(localized: "Lock"), shortPress: PuzzleKeycodes.middleKeypress, longPress: .none, imageName: "lock"),
            ControlConfig(label: String(localized: "Center"), shortPress: MouseClick(usesArrowKeys: true, withModifier: PuzzleKeycodes.CtrlKey), longPress: .none),  // Move centre: Ctrl + arrow keys
            ControlConfig(label: String(localized: "Shift"), shortPress: MouseClick(usesArrowKeys: true, withModifier: PuzzleKeycodes.ShiftKey, reverseArrowDirections: true), displayCondition: { gameId in
                // Shift grid: Shift + arrow keys
                // Variaions of Net have a 'wrapping' mode, indicated by a leading "5x5w:" in the game ID. We're looking for the 'w:'
                return gameId.contains("w:")
            })
        ],
        overflowMenuControls: [
            ControlConfig(label: "Shuffle Blocks", command: ButtonPress(for: "j")),
        ]

    )
        .addSearchTerms(["FreeNet", "NetWalk"])
    .setDarkModeColors([
        1: (Theming.veryDarkGray, "Locked Tile"),
        2: (Theming.veryDarkGray, "Gridlines"),
        3: (Theming.midGray, "Wire"),
        //4: (Theming.boxBlue, "Endpoint"),
        //5: (Theming.highlightTeal, "Powered Wire")
    ])
    
    // MARK: Netslide
    static let puzzle_netslide = GameConfig(
        identifier: "netslide",
        internalGame: netslide
    )
        .setDarkModeColors([
            1: (Theming.darkGray, "Flashing"),
            //2: (Theming.veryDarkGray, "Gridlines"),
            3: (Theming.midGray, "Wire"),
        ])
    
    
    // MARK: Palisade
    static let puzzle_palisade = GameConfig(
        identifier: "palisade",
        internalGame: palisade
    )
    .setDarkModeColors([
        1: (Theming.darkGray, "Flashing"),
        2: (Theming.lightGray, "Grid"),
        3: (Theming.darkGray, "Clue"),
        4: (Theming.veryVeryDarkGray, "Line Maybe"), //Deemphasis
        //5: (Theming.turboBlue, "Line No")
    ])
    .addSearchTerms(["Five Cells"])
    
    // MARK: Pattern
    static let puzzle_pattern = GameConfig(
        identifier: "pattern",
        internalGame: pattern,
        touchControls: [ // TODO: We'll need special handling for these controls in Net.
            ControlConfig(label: "Black", shortPress: PuzzleKeycodes.leftKeypress, longPress: PuzzleKeycodes.rightKeypress),
            ControlConfig(label: "White", shortPress: PuzzleKeycodes.rightKeypress, longPress: PuzzleKeycodes.leftKeypress),
            ControlConfig(label: "Clear", shortPress: PuzzleKeycodes.middleKeypress, longPress: .none, imageName: "square.slash"),
        ]
    )
    .addSearchTerms(["Nonograms"])
    .setDarkModeColors([
        3: (Theming.text, "Text"),
    ])
    
    // MARK: Pearl
    static let puzzle_pearl = GameConfig(
        identifier: "pearl",
        internalGame: pearl,
        allowSingleFingerPanning: false
    )
    .setDarkModeColors([
        3: (Theming.darkGray, "Black Box"),
        4: (Theming.lightGray, "White Box")
    ])
    .addSearchTerms(["Masyu"])
    
    // MARK: Pegs
    static let puzzle_pegs = GameConfig(
        identifier: "pegs",
        internalGame: pegs,
        allowSingleFingerPanning: false
    )
    .setDarkModeColors([
        1: (Theming.midGray, "Highlight"),
        2: (Theming.darkGray, "Lowlight")
        //3: (Theming.boxBlue, "Pegs")
    ])
    .addSearchTerms(["Peg Solitaire"])
    
    // MARK: Range
    static let puzzle_range = GameConfig(
        identifier: "range",
        internalGame: range
    )
    .setDarkModeColors([
        1: (Theming.lightGray, "Grid"),
        //2: (Theming.warningRed, "Error"),
        3: (Theming.darkGray, "Lowlight")
    ])
    .addSearchTerms(["Kurodoko", "Kuromasu"])
    
    // MARK: Rectangles
    static let puzzle_rectangles = GameConfig(
        identifier: "rectangles",
        internalGame: rect
    )
    .setDarkModeColors([
       
        2: (Theming.white, "Drawn Line"),
        3: (Theming.text, "Text"),
        1: (Theming.white, "Grid"),
    ])
    
    // MARK: Samegame
    static let puzzle_samegame = GameConfig(
        identifier: "samegame",
        customParamInfo: String(localized: "samegame_params", table: "Puzzles"),
        internalGame: samegame,
        isExperimental: false)
    .setSaveIdentifier("Same Game")
    .setDarkModeColors([
        11: (Theming.midGray, "Selected Box"),
        12: (Theming.midGray, "Highlight"),
        13: (Theming.darkGray, "Lowlight")
    ])
    
    
    // MARK: Signpost
    static let puzzle_signpost = GameConfig(
        identifier: "signpost",
        internalGame: signpost
    )
    .setDarkModeColors([
        0: (Theming.midGray, "Background Color"),
        //1: (Theming.midGray, "Highlight"),
        //2: (Theming.veryDarkGray, "Lowlight"),
        3: (Theming.darkGray, "Grid"),
        //6: (Theming.enteredTextGreen, "Drag Origin"),
        //7: (Theming.veryDarkGray, "Arrow"),
        //8: (Theming.midGray, "Dimmed Arrow (Deemphasized)"),
        //10: (Theming.black, "Text color for Preset Squares"),
        //11: (Theming.veryDarkGray, "Locked-In Number"),
        //12: (Theming.midGray, "Background for Locked Squares (b0)"),
        //13: (Theming.veryVeryDarkGray, "Mid Arrow M0"),
        //14: (Theming.background, "Dim Arrows D0"),
        //15: (Theming.background, "Dim Arrows x0")
        // 14: (Theming.veryDarkGray, "Dim Arrow"), //d0
        // 15: (Theming.veryDarkGray, "Dim Arrow 2"), //x0
    ])
    .addSearchTerms(["Pfeilpfad", "Arrow Path", "Arrows"])
    
    // MARK: Singles
    static let puzzle_singles = GameConfig(
        identifier: "singles",
        internalGame: singles
    )
    .setDarkModeColors([
        3: (Theming.text, "Black"),
        4: (Theming.veryDarkGray, "White"),
        5: (Theming.midGray, "Black Color")
    ])
    .addSearchTerms(["Hitori"])
    
    // MARK: Sixteen
    static let puzzle_sixteen = GameConfig(
        identifier: "sixteen",
        internalGame: sixteen
    )
    .setDarkModeColors([
        1: (Theming.text, "Text"),
        2: (Theming.darkGray, "Highlight"),
        3: (Theming.veryDarkGray, "Lowlight")
    ])
    
    
    // MARK: Slant
    static let puzzle_slant = GameConfig(
        identifier: "slant",
        internalGame: slant
    )
    .setDarkModeColors([
        //1: (Theming.text, "Text"),
        2: (Theming.text, "Ink"),
        3: (Theming.white, "slant 1"),
        4: (Theming.white, "slant 2"),
        7: (Theming.background, "Filled Square"),
        8: (Theming.veryDarkGray, "Grounded Line")
    ])
    
    // MARK: Solo
    static let puzzle_solo = GameConfig(
        identifier: "solo",
        customParamInfo: String(localized: "solo_params", table: "Puzzles"),
        internalGame: solo,
        displayClearButtonInToolbar: true,
        overflowMenuControls: [
            ControlConfig.MarksControl
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
    .addSearchTerms(["Sudoku"])
    .setDarkModeColors([
        //1: (Theming.text, "Text"),
        1: (Theming.veryDarkGray, "X Diagonals"),
        2: (Theming.darkGray, "Grid"),
        3: (Theming.text, "Clue"),
        4: (Theming.enteredTextBlue, "User Entered Value"),
        //7: (CGColor(red: 0.533, green: 0.533, blue: 1, alpha: 1), "Pencil Marks"),
        8: (Theming.text, "Killer Mode Data")
    ])
    
    // MARK: Tents
    static let puzzle_tents = GameConfig(
        identifier: "tents",
        internalGame: tents,

        touchControls: [
            ControlConfig(label: "Add and Remove Tents", shortPress: PuzzleKeycodes.leftKeypress, longPress: PuzzleKeycodes.rightKeypress, imageName: "square", imageColor: .black),
            // ControlConfig(label: "Clear", shortPress: PuzzleKeycodes.middleKeypress, longPress: .none, imageName: "square.slash") (Tents does not support a dedicated clear button)
        ]
    )
        .setDarkModeColors([
            //1: (Theming.text, "Text"),
            1: (Theming.white, "Grid"),
            2: (Theming.darkGray, "Grass"),
            //3: (Theming.text, "Clue"),
            //4: (Theming.enteredTextBlue, "User Entered Value"),
            //7: (CGColor(red: 0.533, green: 0.533, blue: 1, alpha: 1), "Pencil Marks"),
            //8: (Theming.text, "Killer Mode Data")
        ])
    
    // MARK: Towers
    static let puzzle_towers = GameConfig(
        identifier: "towers",
        internalGame: towers,
        isExperimental: false,
        displayClearButtonInToolbar: true,

        buttonControls: [
            // ControlConfig(label: "Clear", command: PuzzleKeycodes.ClearButton, imageName: "square.slash"),
        ],
        
        overflowMenuControls: [
            ControlConfig.MarksControl
        ]
    ).numericButtonsBuilder({ gameId in
        // Sample game ID: 5:2/1/2/3/3/2/2/3/1/2/2/2/5/1/3/3/2/1/3/2
        // We just need that first digits, which indicates the number of towers in each row/column.
        
        guard !gameId.isEmpty else {
            return []
        }
        
        let numButtons = Int(gameId.split(separator: ":")[0])
        return Puzzles.createButtonControls(numButtons ?? 0)
    })
    .addSearchTerms(["Skyscrapers"])
    .setDarkModeColors([
        1: (Theming.text, "Grid"),
        2: (Theming.enteredTextBlue, "User Entered Guess")
    ])
    
    /*
     
     enum {
         COL_BACKGROUND,
         COL_GRID,
         COL_USER,
         COL_HIGHLIGHT,
         COL_ERROR,
         COL_PENCIL,
         COL_DONE,
         NCOLOURS
     };
     <color name="towers_night_colour_grid">#ffffff</color>
         <color name="towers_night_colour_user">#00ff00</color>
         <color name="towers_night_colour_pencil">#8888ff</color>
     */
    
    // MARK: Tracks
    static let puzzle_tracks = GameConfig(
        identifier: "tracks",
        internalGame: tracks
    )
    .setSaveIdentifier("Train Tracks")
    .setDarkModeColors([
        1: (Theming.midGray, "Track Background"),
        2: (Theming.text, "Grid"),
        3: (Theming.text, "Clue"),
        5: (Theming.darkGray, "User Entered Track"),
        6: (Theming.black, "Track Clue"),
        //7: (Theming.turboBlue, "Sleeper (Bottom of Track)"),
        8: (Theming.darkGray, "Drag On"),
        11: (Theming.white, "Flash"),
        12: (Theming.veryDarkGray, "Error Background")
    ])
    
    // MARK: Twiddle
    static let puzzle_twiddle = GameConfig(
        identifier: "twiddle",
        internalGame: twiddle,
        touchControls: [ControlConfig(label: String(localized: "Clockwise"), shortPress: PuzzleKeycodes.rightKeypress, longPress: PuzzleKeycodes.leftKeypress, imageName: "arrow.clockwise")] // Single touch controls makes the default tap command move objects clockwise
    )
    .setDarkModeColors([
        1: (Theming.text, "Text"),
        2: (Theming.midGray, "Highlight"),
        3: (Theming.darkGray, "Gentle Highlight"),
        4: (Theming.darkGray, "Lowlight"),
        5: (Theming.veryDarkGray, "Lowlight Gentle"),
    ])
    
    
    // MARK: Undead
    static let puzzle_undead = GameConfig(
        identifier: "undead",
        internalGame: undead,
        displayClearButtonInToolbar: true,

        buttonControls: [
            ControlConfig(label: String(localized: "Ghost"), command: ButtonPress(for: "G"), imageName: "ghost", isSystemImage: false, displayTextWithIcon: false),
            ControlConfig(label: String(localized: "Vampire"), command: ButtonPress(for: "V"), imageName: "vampire", isSystemImage: false, displayTextWithIcon: false),
            ControlConfig(label: String(localized: "Zombie"), command: ButtonPress(for: "Z"), imageName: "zombie", isSystemImage: false, displayTextWithIcon: false),
        ]
    )
    .addSearchTerms(["Haunted Mirror Maze"])
    .setDarkModeColors([
        1: (Theming.text, "Grid"),
        2: (Theming.text, "Text"),
    ])
    
    // MARK: Unequal
    static let puzzle_unequal = GameConfig(
        identifier: "unequal",
        internalGame: unequal,
        
        overflowMenuControls: [
            ControlConfig.MarksControl,
            ControlConfig(label: String(localized: "Hints"), command: ButtonPress(for: "H"), imageName: "plus.square")
        ]
    )
        .addSearchTerms(["Futoshiki"])
        .numericButtonsBuilder({gameId in
        // Game ID: 4:0,0,0,0D,0,0,0,0,2D,0D,0,0,0,0,0,3U,
        // Adjancent Game ID: 6a:0,0RD,0DL,0D,0D,0D,1,0UR,0UL,0U,0U,...
        
        guard !gameId.isEmpty else {
            return []
        }
        
        let numButtonsRegex = /^\d/
        let digitMatch = gameId.firstMatch(of: numButtonsRegex)
        
        let numButtons = Int(digitMatch?.output ?? "0")
        
        return Puzzles.createButtonControls(numButtons ?? 0)
    })
    .setDarkModeColors([
        1: (Theming.text, "Grid"),
        2: (Theming.text, "Text"),
        3: (Theming.enteredTextBlue, "User Guess"),
        6: (Theming.darkGray, "Highlight"),
        7: (Theming.veryDarkGray, "Lowlight"),
    ])
    
    
    // MARK: Unruly
    static let puzzle_unruly = GameConfig(
        identifier: "unruly",
        internalGame: unruly,
        isExperimental: false,
        touchControls: [
            //ControlConfig(label: "Black Blocks First", shortPress: .leftClick, longPress: .rightClick, imageName: "square.fill.black", isSystemImage: false),
            //ControlConfig(label: "White Blocks First", shortPress: .rightClick, longPress: .leftClick, imageName: "square.fill.white", isSystemImage: false),
            ControlConfig(label: String(localized: "Fill Blocks"), shortPress: PuzzleKeycodes.leftKeypress, longPress: PuzzleKeycodes.rightKeypress, imageName: "square.fill"),
            ControlConfig(label: String(localized: "Clear"), shortPress: PuzzleKeycodes.middleKeypress, longPress: PuzzleKeycodes.leftKeypress, imageName: "square.slash")
        ]
    )
    .addSearchTerms(["Futoshiki"])
    .setDarkModeColors([
        1: (Theming.midGray, "Grid"),
        2: (Theming.darkGray, "Empty Grid"),
        //3: (Theming.lightGray, "White Squares"),
        //4: (Theming.turboBlue, "Color 1 Highlight"),
        6: (Theming.veryDarkGray, "Black Squares")
    ])
    
    // MARK: Untangle
    static let puzzle_untangle = GameConfig(
        identifier: "untangle",
        internalGame: untangle,
        allowSingleFingerPanning: false,
        touchControls: [ControlConfig(label: "", shortPress: PuzzleKeycodes.leftKeypress, longPress: .none)] // Left click only, disables long presses
    )
    .setDarkModeColors([
        1: (Theming.background, "Background"),
        2: (Theming.white, "Line"),
        4: (Theming.white, "Outline")
    ])
    .addSearchTerms(["Planarity"])
}
