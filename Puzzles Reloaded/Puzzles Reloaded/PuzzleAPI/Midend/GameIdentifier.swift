//
//  GameIdentifier.swift
//  Puzzles Reloaded
//
//  Created by Kyle Swarner on 8/12/25.
//  Copyright © 2025 Kyle Swarner. All rights reserved.
//

import Foundation

// Uses the `identify_game` method from the midend to identify a game from a specific save file

class GameIdentifier {
    
    static func openSavegameFromURL(_ saveFileURL: URL) -> SaveContext? {
        do {
            let save = try String(contentsOf: saveFileURL)
            return SaveContext(savegame: save)
        } catch {
            print("Error opening savegame from file: \(error)")
            return nil
        }
    }
    
    /**
     From a given savegame, try to identify what game its' for. This validates that the file format is correct and that we can handle the savegame version provided. Ultimately, it returns the game name it finds within the file.
     */
    static func identifyGame(_ save: SaveContext) -> String? {
        
        var returnValue: String?
        
        //let gameNamePointer = UnsafeMutablePointer<CChar>.allocate(capacity: 1)
        
        let gameNamePointer = UnsafeMutablePointer<UnsafeMutablePointer<CChar>?>.allocate(capacity: 1)
        //pointerToGameNamePointer.pointee = gameNamePointer
        
        withUnsafePointer(to: save) { savePointer in
            // name: UnsafeMutablePointer<UnsafeMutablePointer<CChar>?>!
            // read: ((UnsaveMutableRawPointer?, UnsafeMutableRawPointer?, Int32) -> Bool)!
            // rctx: UnsafeMutableRawPointer!
            let error = identify_game(gameNamePointer, midend_readFile, UnsafeMutableRawPointer(mutating: savePointer))

            //TODO: Process errors, if any? This returns an error message, but will we display it?
            
            // First check for errors
            if error != nil {
                let errorMessage = String.init(cString: error!)
                print("Error when opening savegame: \(errorMessage)")               
            // Then check to see if a valid game was returned
            } else if let result = gameNamePointer.pointee {
                returnValue = String.init(cString: result)
            }
        }
        
        gameNamePointer.deallocate()
        
        return returnValue
    }
}
