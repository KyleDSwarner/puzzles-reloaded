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
        name: String(localized: "net_name", table: "Puzzles"),
        description: String(localized: "net_description", table: "Puzzles"),
        instructions: String(localized: "net_instructions", table: "Puzzles"),
        controlInfo: String(localized: "net_controls", table: "Puzzles"),
        imageName: "net",
        internalGame: net,
        touchControls: [ // TODO: We'll need special handling for these controls in Net.
            ControlConfig(label: String(localized: "Clockwise"), shortPress: PuzzleKeycodes.rightKeypress, longPress: PuzzleKeycodes.middleKeypress, imageName: "arrow.clockwise"), // Left/Right is reversed intentionally to make clockwise the 'default' option
            ControlConfig(label: String(localized: "Counter-Clockwise"), shortPress: PuzzleKeycodes.leftKeypress, longPress: PuzzleKeycodes.middleKeypress, imageName: "arrow.counterclockwise"),
            ControlConfig(label: String(localized: "Lock"), shortPress: PuzzleKeycodes.middleKeypress, longPress: .none, imageName: "lock"),
            ControlConfig(label: String(localized: "Center"), shortPress: PuzzleKeycodes.leftKeypress, longPress: .none),  // Move centre: Ctrl + arrow keys
            ControlConfig(label: String(localized: "Shift"), shortPress: PuzzleKeycodes.leftKeypress, displayCondition: { gameId in // Shift grid: Shift + arrow keys
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
        name: String(localized: "netslide_name", table: "Puzzles"),
        description: String(localized: "netslide_description", table: "Puzzles"),
        instructions: String(localized: "netslide_instructions", table: "Puzzles"),
        controlInfo: String(localized: "sixteen_controls", table: "Puzzles"), // This is intentional! Reuses the same control scheme as Sixteen
        imageName: "netslide",
        internalGame: netslide
    )
    
    // MARK: Palisade
    static let puzzle_palisade = GameConfig(
        name: String(localized: "palisade_name", table: "Puzzles"),
        description: String(localized: "palisade_description", table: "Puzzles"),
        instructions: String(localized: "palisade_instructions", table: "Puzzles"),
        controlInfo: String(localized: "palisade_controls", table: "Puzzles"),
        imageName: "palisade",
        internalGame: palisade
    )
    
    // MARK: Pattern
    static let puzzle_pattern = GameConfig(
        name: String(localized: "pattern_name", table: "Puzzles"),
        description: String(localized: "pattern_description", table: "Puzzles"),
        instructions: String(localized: "pattern_instructions", table: "Puzzles"),
        controlInfo: String(localized: "pattern_controls", table: "Puzzles"),
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
        name: String(localized: "pearl_name", table: "Puzzles"),
        description: String(localized: "pearl_description", table: "Puzzles"),
        instructions: String(localized: "pearl_instructions", table: "Puzzles"),
        controlInfo: String(localized: "pearl_controls", table: "Puzzles"),
        imageName: "pearl",
        internalGame: pearl,
        allowSingleFingerPanning: false
    )
    
    // MARK: Pegs
    static let puzzle_pegs = GameConfig(
        name: String(localized: "pegs_name", table: "Puzzles"),
        description: String(localized: "pegs_description", table: "Puzzles"),
        instructions: String(localized: "pegs_instructions", table: "Puzzles"),
        controlInfo: String(localized: "pegs_controls", table: "Puzzles"),
        imageName: "pegs",
        internalGame: pegs,
        allowSingleFingerPanning: false
    )
    
    // MARK: Range
    static let puzzle_range = GameConfig(
        name: String(localized: "range_name", table: "Puzzles"),
        description: String(localized: "range_description", table: "Puzzles"),
        instructions: String(localized: "range_instructions", table: "Puzzles"),
        controlInfo: String(localized: "range_controls", table: "Puzzles"),
        imageName: "range",
        internalGame: range
    )
    
    // MARK: Rectangles
    static let puzzle_rectangles = GameConfig(
        name: String(localized: "rectangles_name", table: "Puzzles"),
        description: String(localized: "rectangles_description", table: "Puzzles"),
        instructions: String(localized: "rectangles_instructions", table: "Puzzles"),
        controlInfo: String(localized: "rectangles_controls", table: "Puzzles"),
        imageName: "rect",
        internalGame: rect
    )
    
    // MARK: Samegame
    static let puzzle_samegame = GameConfig(
        name: String(localized: "samegame_name", table: "Puzzles"),
        description: String(localized: "samegame_description", table: "Puzzles"),
        instructions: String(localized: "samegame_instructions", table: "Puzzles"),
        controlInfo: String(localized: "samegame_controls", table: "Puzzles"),
        customParamInfo: String(localized: "samegame_params", table: "Puzzles"),
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
        name: String(localized: "singles_name", table: "Puzzles"),
        description: String(localized: "singles_description", table: "Puzzles"),
        instructions: String(localized: "singles_instructions", table: "Puzzles"),
        controlInfo: String(localized: "singles_controls", table: "Puzzles"),
        imageName: "singles",
        internalGame: singles
    )
    
    // MARK: Sixteen
    static let puzzle_sixteen = GameConfig(
        name: String(localized: "sixteen_name", table: "Puzzles"),
        description: String(localized: "sixteen_description", table: "Puzzles"),
        instructions: String(localized: "sixteen_instructions", table: "Puzzles"),
        controlInfo: String(localized: "sixteen_controls", table: "Puzzles"),
        imageName: "sixteen",
        internalGame: sixteen
    )
    
    // MARK: Slant
    static let puzzle_slant = GameConfig(
        name: String(localized: "slant_name", table: "Puzzles"),
        description: String(localized: "slant_description", table: "Puzzles"),
        instructions: String(localized: "slant_instructions", table: "Puzzles"),
        controlInfo: String(localized: "slant_controls", table: "Puzzles"),
        imageName: "slant",
        internalGame: slant
    )
    
    // MARK: Solo
    static let puzzle_solo = GameConfig(
        name: String(localized: "solo_name", table: "Puzzles"),
        description: String(localized: "solo_description", table: "Puzzles"),
        instructions: String(localized: "solo_instructions", table: "Puzzles"),
        controlInfo: String(localized: "solo_controls", table: "Puzzles"),
        customParamInfo: String(localized: "solo_params", table: "Puzzles"),
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
            ControlConfig(label: String(localized: "Marks"), command: PuzzleKeycodes.MarksButton, imageName: "square.and.pencil")
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
        name: String(localized: "tracks_name", table: "Puzzles"),
        description: String(localized: "tracks_description", table: "Puzzles"),
        instructions: String(localized: "tracks_instructions", table: "Puzzles"),
        controlInfo: String(localized: "tracks_controls", table: "Puzzles"),
        imageName: "tracks",
        internalGame: tracks
    )
    
    // MARK: Twiddle
    static let puzzle_twiddle = GameConfig(
        name: String(localized: "twiddle_name", table: "Puzzles"),
        description: String(localized: "twiddle_description", table: "Puzzles"),
        instructions: String(localized: "twiddle_instructions", table: "Puzzles"),
        controlInfo: String(localized: "twiddle_controls", table: "Puzzles"),
        imageName: "twiddle",
        internalGame: twiddle,
        touchControls: [ControlConfig(label: String(localized: "Clockwise"), shortPress: PuzzleKeycodes.rightKeypress, longPress: PuzzleKeycodes.leftKeypress, imageName: "arrow.clockwise")] // Single touch controls makes the default tap command move objects clockwise
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
            ControlConfig(label: String(localized: "Ghost"), command: ButtonPress(for: "G"), imageName: "ghost", isSystemImage: false, displayTextWithIcon: false),
            ControlConfig(label: String(localized: "Vampire"), command: ButtonPress(for: "V"), imageName: "vampire", isSystemImage: false, displayTextWithIcon: false),
            ControlConfig(label: String(localized: "Zombie"), command: ButtonPress(for: "Z"), imageName: "zombie", isSystemImage: false, displayTextWithIcon: false),
        ]
    )
    
    // MARK: Unequal
    static let puzzle_unequal = GameConfig(
        name: String(localized: "unequal_name", table: "Puzzles"),
        description: String(localized: "unequal_description", table: "Puzzles"),
        instructions: String(localized: "unequal_instructions", table: "Puzzles"),
        controlInfo: String(localized: "unequal_controls", table: "Puzzles"),
        imageName: "unequal",
        internalGame: unequal,
        
        overflowMenuControls: [
            ControlConfig(label: String(localized: "Marks"), command: PuzzleKeycodes.MarksButton, imageName: "square.and.pencil"),
            ControlConfig(label: String(localized: "Hints"), command: ButtonPress(for: "H"), imageName: "plus.square")
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
            ControlConfig(label: String(localized: "Fill Blocks"), shortPress: PuzzleKeycodes.leftKeypress, longPress: PuzzleKeycodes.rightKeypress, imageName: "square.fill"),
            ControlConfig(label: String(localized: "Clear"), shortPress: PuzzleKeycodes.middleKeypress, longPress: PuzzleKeycodes.leftKeypress, imageName: "square.slash")
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
