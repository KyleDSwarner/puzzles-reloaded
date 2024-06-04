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
        name: String(localized: "net_name", table: "Puzzles"),
        description: String(localized: "net_description", table: "Puzzles"),
        instructions: String(localized: "net_instructions", table: "Puzzles"),
        controlInfo: String(localized: "net_controls", table: "Puzzles"),
        imageName: "net",
        internalGame: net,
        touchControls: [ // TODO: We'll need special handling for these controls in Net.
            ControlConfig(label: "Clockwise", shortPress: PuzzleKeycodes.rightKeypress, longPress: PuzzleKeycodes.middleKeypress, imageName: "arrow.clockwise"), // Left/Right is reversed intentionally to make clockwise the 'default' option
            ControlConfig(label: "Counter-Clockwise", shortPress: PuzzleKeycodes.leftKeypress, longPress: PuzzleKeycodes.middleKeypress, imageName: "arrow.counterclockwise"),
            ControlConfig(label: "Lock", shortPress: PuzzleKeycodes.middleKeypress, longPress: .none, imageName: "lock"),
            ControlConfig(label: "Center", shortPress: PuzzleKeycodes.leftKeypress, longPress: .none),  // Move centre: Ctrl + arrow keys
            ControlConfig(label: "Shift", shortPress: PuzzleKeycodes.leftKeypress, displayCondition: { gameId in // Shift grid: Shift + arrow keys
                // Variaions of Net have a 'wrapping' mode, indicated by a leading "5x5w:" in the game ID. We're looking for the 'w:'
                return gameId.contains("w:")
            })
        ],
        buttonControls: [
            ControlConfig(label: "Jumble", command: ButtonPress(for: "j")),
        ]

    )
    
    // MARK: Netslide
    static let puzzle_netslide = GameConfig(
        name: "Netslide",
        description: "Net, but more",
        imageName: "netslide",
        internalGame: netslide
    )
    
    // MARK: Pattern
    static let puzzle_pattern = GameConfig(
        name: "Pattern",
        description: "A pretty one!",
        imageName: "pattern",
        internalGame: pattern,
        touchControls: [ // TODO: We'll need special handling for these controls in Net.
            ControlConfig(label: "Black Boxes", shortPress: PuzzleKeycodes.leftKeypress, longPress: PuzzleKeycodes.rightKeypress, imageName: "square.fill", imageColor: .black),
            ControlConfig(label: "White Boxes", shortPress: PuzzleKeycodes.rightKeypress, longPress: PuzzleKeycodes.leftKeypress, imageName: "square.fill", imageColor: .white),
            ControlConfig(label: "Clear", shortPress: PuzzleKeycodes.middleKeypress, longPress: .none, imageName: "square.slash"),
        ]
    )
    
    // MARK: Pearl
    static let puzzle_pearl = GameConfig(
        name: "Pearl",
        description: "Like from a clam",
        imageName: "pearl",
        internalGame: pearl,
        allowSingleFingerPanning: false
    )
    
    // MARK: Pegs
    static let puzzle_pegs = GameConfig(
        name: "Pegs",
        description: "I played this a lot at cracker barrel",
        imageName: "pegs",
        internalGame: pegs,
        allowSingleFingerPanning: false
    )
    
    // MARK: Range
    static let puzzle_range = GameConfig(
        name: "Range",
        description: "down on the this",
        imageName: "range",
        internalGame: range
    )
    
    // MARK: Rectangles
    static let puzzle_rectangles = GameConfig(
        name: "Rectangles",
        description: "These angles are so Rect",
        imageName: "rect",
        internalGame: rect
    )
    
    // MARK: Samegame
    static let puzzle_samegame = GameConfig(
        name: String(localized: "samegame_name", table: "Puzzles"),
        description: String(localized: "samegame_description", table: "Puzzles"),
        instructions: String(localized: "samegame_instructions", table: "Puzzles"),
        controlInfo: String(localized: "samegame_controls", table: "Puzzles"),
        imageName: "samegame",
        internalGame: samegame,
        isExperimental: false)
    
    // MARK: Signpost
    static let puzzle_signpost = GameConfig(
        name: String(localized: "signpost_name", table: "Puzzles", comment: "Display name for the puzzle 'signpost'"),
        description: String(localized: "signpost_desc", table: "Puzzles", comment: "Short Description for the puzzle 'signpost'"),
        instructions: String(localized: "signpost_instructions", table: "Puzzles", comment: "Instructions for the puzzle 'signpost'"),
        controlInfo: String(localized: "signpost_controls", table: "Puzzles", comment: "Control Info for the puzzle 'signpost'"),
        imageName: "signpost",
        internalGame: signpost
    )
    
    // MARK: Singles
    static let puzzle_singles = GameConfig(
        name: "Singles",
        description: "Black out the right set of duplicate numbers",
        imageName: "singles",
        internalGame: singles
    )
    
    // MARK: Sixteen
    static let puzzle_sixteen = GameConfig(
        name: "Sixteen",
        description: "Slide the grid squares around so that the numbers end up in consecutive order from the top left corner",
        imageName: "sixteen",
        internalGame: sixteen
    )
    
    // MARK: Slant
    static let puzzle_slant = GameConfig(
        name: "Slant",
        description: "--slant--",
        imageName: "slant",
        internalGame: slant
    )
    
    // MARK: Solo
    static let puzzle_solo = GameConfig(
        name: "Solo",
        description: "--solo--",
        imageName: "solo",
        internalGame: solo,
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
    
    // MARK: Tents
    static let puzzle_tents = GameConfig(
        name: String(localized: "tents_name", table: "Puzzles"),
        description: String(localized: "tents_description", table: "Puzzles"),
        instructions: String(localized: "tents_instructions", table: "Puzzles"),
        controlInfo: String(localized: "tents_controls", table: "Puzzles"),
        imageName: "tents",
        internalGame: tents,

        touchControls: [
            ControlConfig(label: "Add and Remove Tents", shortPress: PuzzleKeycodes.leftKeypress, longPress: PuzzleKeycodes.rightKeypress, imageName: "square.fill.black", isSystemImage: false, imageColor: .black),
            ControlConfig(label: "Clear", shortPress: PuzzleKeycodes.middleKeypress, longPress: .none, imageName: "square.slash")
        ]
    )
    
    // MARK: Towers
    static let puzzle_towers = GameConfig(
        name: String(localized: "towers_name", table: "Puzzles"),
        description: String(localized: "towers_description", table: "Puzzles"),
        instructions: String(localized: "towers_instructions", table: "Puzzles"),
        controlInfo: String(localized: "towers_controls", table: "Puzzles"),
        imageName: "towers",
        internalGame: towers,
        isExperimental: false,
        displayClearButtonInToolbar: true,

        buttonControls: [
            // ControlConfig(label: "Clear", command: PuzzleKeycodes.ClearButton, imageName: "square.slash"),
        ],
        
        overflowMenuControls: [
            ControlConfig(label: "Marks", command: PuzzleKeycodes.MarksButton, imageName: "square.and.pencil")
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
    
    // MARK: Tracks
    static let puzzle_tracks = GameConfig(
        name: "Tracks",
        description: "--tracks--",
        imageName: "tracks",
        internalGame: tracks
    )
    
    // MARK: Twiddle
    static let puzzle_twiddle = GameConfig(
        name: "Twiddle",
        description: "--twiddle--",
        imageName: "twiddle",
        internalGame: twiddle
    )
    
    // MARK: Undead
    static let puzzle_undead = GameConfig(
        name: String(localized: "undead_name", table: "Puzzles", comment: "Display name for the game 'undead'"),
        description: String(localized: "undead_description", table: "Puzzles", comment: "Short description for the game 'undead'"),
        instructions: String(localized: "undead_instructions", table: "Puzzles", comment: "Instructions for the game 'undead'"),
        controlInfo: String(localized: "undead_controls", table: "Puzzles", comment: "Control info for the game 'undead'"),
        imageName: "undead",
        internalGame: undead,
        displayClearButtonInToolbar: true,

        buttonControls: [
            ControlConfig(label: "Ghost", command: ButtonPress(for: "G"), imageName: "ghost", isSystemImage: false, displayTextWithIcon: false),
            ControlConfig(label: "Vampire", command: ButtonPress(for: "V"), imageName: "vampire", isSystemImage: false, displayTextWithIcon: false),
            ControlConfig(label: "Zombie", command: ButtonPress(for: "Z"), imageName: "zombie", isSystemImage: false, displayTextWithIcon: false),
        ]
    )
    
    // MARK: Unequal
    static let puzzle_unequal = GameConfig(
        name: "unequal",
        description: "equality",
        imageName: "unequal",
        internalGame: unequal,
        
        overflowMenuControls: [
            ControlConfig(label: "Marks", command: PuzzleKeycodes.MarksButton, imageName: "square.and.pencil"),
            ControlConfig(label: "Hints", command: ButtonPress(for: "H"), imageName: "plus.square")
        ]
    ).numericButtonsBuilder({gameId in
        // Game ID: 4:0,0,0,0D,0,0,0,0,2D,0D,0,0,0,0,0,3U,
        
        guard !gameId.isEmpty else {
            return []
        }
        
        let numButtons = Int(gameId.split(separator: ":")[0])
        return Puzzles.createButtonControls(numButtons ?? 0)
    })
    
    // MARK: Unruly
    static let puzzle_unruly = GameConfig(
        name: String(localized: "unruly_name", table: "Puzzles"),
        description: String(localized: "unruly_description", table: "Puzzles"),
        instructions: String(localized: "unruly_instructions", table: "Puzzles"),
        controlInfo: String(localized: "unruly_controls", table: "Puzzles"),
        imageName: "unruly",
        internalGame: unruly,
        isExperimental: false,
        touchControls: [
            //ControlConfig(label: "Black Blocks First", shortPress: .leftClick, longPress: .rightClick, imageName: "square.fill.black", isSystemImage: false),
            //ControlConfig(label: "White Blocks First", shortPress: .rightClick, longPress: .leftClick, imageName: "square.fill.white", isSystemImage: false),
            ControlConfig(label: "Fill Blocks", shortPress: PuzzleKeycodes.leftKeypress, longPress: PuzzleKeycodes.rightKeypress, imageName: "square.fill"),
            ControlConfig(label: "Clear", shortPress: PuzzleKeycodes.middleKeypress, longPress: PuzzleKeycodes.leftKeypress, imageName: "square.slash")
        ]
    )
    
    // MARK: Untangle
    static let puzzle_untangle = GameConfig(
        name: String(localized: "untangle_name", table: "Puzzles", comment: "Display name for the game 'untangle'"),
        description: String(localized: "untangle_description", table: "Puzzles", comment: "Short Description for the game 'untangle'"),
        instructions: String(localized: "untangle_instructions", table: "Puzzles", comment: "Game instructions for 'untangle'"),
        controlInfo: String(localized: "untangle_controls", table: "Puzzles", comment: "Description of controls for the game 'untangle'"),
        imageName: "untangle",
        internalGame: untangle,
        allowSingleFingerPanning: false
    )
}
