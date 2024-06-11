//
//  PuzzleSettings.swift
//  Puzzles
//
//  Created by Kyle Swarner on 4/18/24.
//  Copyright © 2024 Kyle Swarner. All rights reserved.
//

import Foundation

struct PuzzleConstants {
    
    static let puzzleSize = 1024 // Given to the puzzle midend & our CGContext to build the image. This needs to be consistent across several areas in the app!
    
}

struct PuzzleUtils {
    
    static func stringToPointer(_ theString: String) -> UnsafeMutablePointer<CChar> {
        // Convert the Swift String to a null-terminated C string
        let cString = theString.cString(using: .utf8)!

        // Allocate memory for the C string and copy the contents
        let pointer = UnsafeMutablePointer<CChar>.allocate(capacity: cString.count)
        
        // Loop over the cString array and allocate the pointer with the bytes of the UTF-8 String
        for index in 0..<cString.count {
            pointer[index] = cString[index]
        }
        
        return pointer
    }
}
