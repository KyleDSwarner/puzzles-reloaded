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
    static let gameNotes: [GameConfigNote] = [
        GameConfigNote(gameName: "Solo", note: "Note: Enabling too many options may prevent the app from finding a valid puzzle and could get stuck in generation. Cancel or restart the app if you run in to any issues!")
    ]
    
    static let allHelpTexts: [GameConfigOption] = [
        GameConfigOption(gameName: "Net", helpField: "Barrier probability", isDecimalValue: true, minValue: 0, maxValue: 1, customHelpText: "Decimal value from 0-1. Higher values mean higher probability of walls."),
        GameConfigOption(gameName: "Netslide", helpField: "Barrier probability", isDecimalValue: true, minValue: 0, maxValue: 1, customHelpText: "Decimal value from 0-1. Higher values mean higher probability of walls."),
        GameConfigOption(gameName: "Black Box", helpField: "No. of balls", forceString: true, preferDeciKeyboard: true, customHelpText: "Enter a value ('3') or a range ('3-6')"),
        GameConfigOption(gameName: "Rectangles", helpField: "Expansion factor", isDecimalValue: true, minValue: 0, maxValue: 1, customHelpText: "Modifies game generation settings to prefer larger rectangles. Setting an expansion factor of around 0.5 tends to make the game more difficult, and tends to reward a less deductive and more intuitive playing style. Too high, and the game will become trivial."),
        GameConfigOption(gameName: "Pearl", helpField: "Allow unsoluble", customHelpText: "Enables simpler game generation that allows for larger grids and more clues, but does not guarantee unique solutions or that a solution can be logically deduced."),
        GameConfigOption(gameName: "Boats", helpField: "Fleet configuration", customHelpText: "Customize the fleet by entering a list of numbers. Each number indicates how many times a boat of a specific size appears. For example, the configuration 3,2,1 represents 3 boats of size 1, 2 boats of size 2, and 1 boat of size 3."),
        GameConfigOption(gameName: "Mines", helpField: "Ensure solubility", customHelpText: "When on (by default), Mines will ensure that the entire grid can be fully deduced starting from the initial open space. Turn off for a harder game that may involve guessing."),
        GameConfigOption(gameName: "Mosaic", helpField: "Aggressive generation (longer)", customHelpText: "When on, the game generator will try harder to eliminate unnecessary clues on the board. This slows down generation, so it's not recommended for boards larger than ~30×30."),
        GameConfigOption(gameName: "Same Game", helpField: "Scoring system", customHelpText: "Controls the precise mechanism used for scoring. With the default system, ‘(n-2)^2’, only regions of three squares or more will score any points at all. With the alternative ‘(n-1)^2’ system, regions of two squares score a point each, and larger regions score relatively more points."),
        GameConfigOption(gameName: "Same Game", helpField: "Ensure solubility", customHelpText: "If enabled (the default), generated grids are guaranteed to have at least one solution."),
    ]
    
    static func findOverride(gameName: String, field: String) -> GameConfigOption? {
        print("Looking for help info for game \(gameName) and field \(field)")
        return allHelpTexts.first(where: { $0.gameName == gameName && $0.helpField.caseInsensitiveCompare(field) == .orderedSame })
    }
    
    // This method does not lock by the game name.
    static func findOverride(field: String) -> GameConfigOption? {
        return allHelpTexts.first(where: { $0.helpField.caseInsensitiveCompare(field) == .orderedSame })
    }
    
    static func findGameNote(gameName: String) -> GameConfigNote? {
        return gameNotes.first(where: { $0.gameName.caseInsensitiveCompare(gameName) == .orderedSame })
    }
}
