//
//  PuzzleConfig.swift
//  Puzzles
//
//  Created by Kyle Swarner on 4/26/24.
//  Copyright © 2024 Kyle Swarner. All rights reserved.
//

import Foundation

struct Puzzles: RawRepresentable {
    var rawValue: GameConfig
}

extension Puzzles {
    
    static var allPuzzles: [GameConfig] {
        puzzlesAtoM + puzzlesNtoZ + puzzlesXsheep +
        [ // TODO finish cleaning up this master list into the smaller individual files
        puzzle_filling,
        puzzle_galaxies,
        puzzle_guess,
        puzzle_flip,
        puzzle_mosaic,
        puzzle_net,
        puzzle_loopy,
        puzzle_samegame,
        puzzle_signpost,
        puzzle_unequal,
        puzzle_undead,
        puzzle_unruly,
        puzzle_untangle,
        puzzle_towers,
        puzzle_tents,
    ]}
    
    static var allPuzzlesSorted: [GameConfig] {
        allPuzzles.sorted { $0.imageName < $1.imageName } //Image names are all lowercased values of the game name.
    }
}

extension Puzzles {
    
    static let NumericButtons = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0"]
    static let HexidecimalButtons = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z"] // Used by Solo, which supports up to 31 characters.
    static let AlphaButtons = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J"] // Used by ABCD
    
    static func createButtonControls(_ numControls: Int, keycodes: [String] = NumericButtons) -> [ControlConfig] {
        var controls = [ControlConfig]()
        
        guard numControls > 0 else {
            return controls
        }
        
        guard numControls <= keycodes.count else {
            print("Got a control request for a number exceeding the number of buttons provided. Cannot continue.")
            return controls
        }
        // This maxes out at 10 characters. Not currently restricted, but worth mentioning!
        
        for index in 1...numControls {
            //let command = keycodes[index]
            //print(command)
            controls.append(ControlConfig(label: keycodes[index - 1], command: ButtonPress(for: keycodes[index - 1].first))) //TODO short press for numbers/letters?
        }
        
        return controls
    }
}




