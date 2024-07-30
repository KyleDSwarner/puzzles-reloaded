//
//  PuzzleConstants.swift
//  Puzzles Reloaded
//
//  Created by Kyle Swarner on 6/24/24.
//  Copyright © 2024 Kyle Swarner. All rights reserved.
//

import Foundation

struct PuzzleConstants {
    
    static let puzzleSize = 1024 // Given to the puzzle midend & our CGContext to build the image. This needs to be consistent across several areas in the app!
    
    static let settingExclusions: [String] = ["Keyboard shortcuts without Ctrl", "Numpad inputs"]
    
}

// MARK: Global X/Y Dimensions
// These dimension variables are mutable & set globally to make it easy for the C & Swift code to interact better with each other.

/**
 X Dimension of the puzzle image, globally set for easy usage across the swift & C code.
 */
var puzzleDimensionsX: Int = 512

/**
 Y Dimension of the puzzle image, globally set for easy usage across the swift & C code.
 */
var puzzleDimensionsY: Int = 512

