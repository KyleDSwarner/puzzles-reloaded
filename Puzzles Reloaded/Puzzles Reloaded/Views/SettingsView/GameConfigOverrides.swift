//
//  CustomGameConfigHelpText.swift
//  Puzzles Reloaded
//
//  Created by Kyle Swarner on 5/18/26.
//  Copyright © 2026 Kyle Swarner. All rights reserved.
//

import Foundation

struct GameConfigOption {
    var gameName: String
    var helpField: String
    var forceString: Bool = false // Even if it's a number, force option to string mode
    var isDecimalValue: Bool = false // If number being entry is a decimal value
    var preferDeciKeyboard: Bool = false //for entering values like "3-6"
    var minValue: Int = 0
    var maxValue: Int = 10
    var customHelpText: String?
}

struct GameConfigNote {
    var gameName: String
    var note: String
}

struct GameConfigOverrides {
    // Game notes give us a way to add help text to the bottom of any custom game menu page for extra info.
    static let gameNotes: [GameConfigNote] = [
        GameConfigNote(gameName: "Solo", note: String(localized: "solo_custom_note", table: "Puzzles"))
    ]
    
    static let allHelpTexts: [GameConfigOption] = [
        GameConfigOption(gameName: "Net", helpField: "Barrier probability", isDecimalValue: true, minValue: 0, maxValue: 1, customHelpText: String(localized: "net_help_barrier_probability", table: "Puzzles")),
        GameConfigOption(gameName: "Netslide", helpField: "Barrier probability", isDecimalValue: true, minValue: 0, maxValue: 1, customHelpText: String(localized: "net_help_barrier_probability", table: "Puzzles")),
        GameConfigOption(gameName: "Black Box", helpField: "No. of balls", forceString: true, preferDeciKeyboard: true, customHelpText: String(localized: "blackbox_help_num_balls", table: "Puzzles")),
        GameConfigOption(gameName: "Rectangles", helpField: "Expansion factor", isDecimalValue: true, minValue: 0, maxValue: 1, customHelpText: String(localized: "rectangles_help_expansion_factor", table: "Puzzles")),
        GameConfigOption(gameName: "Pearl", helpField: "Allow unsoluble", customHelpText: String(localized: "pearl_help_allow_unsoluble", table: "Puzzles")),
        GameConfigOption(gameName: "Boats", helpField: "Fleet configuration", preferDeciKeyboard: true, customHelpText: String(localized: "boats_help_fleet_configuration", table: "Puzzles")),
        GameConfigOption(gameName: "Mines", helpField: "Ensure solubility", customHelpText: String(localized: "mines_help_ensure_solubility", table: "Puzzles")),
        GameConfigOption(gameName: "Mosaic", helpField: "Aggressive generation (longer)", customHelpText: String(localized: "mosaic_help_agressive_generation", table: "Puzzles")),
        GameConfigOption(gameName: "Same Game", helpField: "Scoring system", customHelpText: String(localized: "samegame_help_scoring_system", table: "Puzzles")),
        GameConfigOption(gameName: "Same Game", helpField: "Ensure solubility", customHelpText: String(localized: "samegame_help_ensure_solubility", table: "Puzzles")),
    ]
    
    static func findOverride(gameName: String, field: String) -> GameConfigOption? {
        return allHelpTexts.first(where: { $0.gameName == gameName && $0.helpField.caseInsensitiveCompare(field) == .orderedSame })
    }
    
    // This method does not lock by the game name. Used by midend to look up overrides
    static func findOverride(field: String) -> GameConfigOption? {
        return allHelpTexts.first(where: { $0.helpField.caseInsensitiveCompare(field) == .orderedSame })
    }
    
    static func findGameNote(gameName: String) -> GameConfigNote? {
        return gameNotes.first(where: { $0.gameName.caseInsensitiveCompare(gameName) == .orderedSame })
    }
}
