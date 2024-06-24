//
//  Midend-UserPreferences.swift
//  Puzzles Reloaded
//
//  Created by Kyle Swarner on 6/6/24.
//  Copyright © 2024 Kyle Swarner. All rights reserved.
//

import Foundation

func midend_getPrefContext(_ context: UnsafeMutableRawPointer?) -> SaveContext {
    let pointer = context?.bindMemory(to: SaveContext.self, capacity: 1)
    return pointer!.pointee // Note: Force unwrapping the value here. Frontend _shouldn't_ ever be null, but there's really not much we can do if it isn't! TODO: Add some messaging to trace if/when this situation occurs.
}

/**
 Global function used as part of writing preferences to a longer string.
 This will be called multiple times and build the final preference string over time.
 */
func midend_writeFile(context: UnsafeMutableRawPointer?, buffer: UnsafeRawPointer?, length: Int32) {
   
    let saveContext = midend_getPrefContext(context)
    
    guard let unwrappedBuffer = buffer else {
        return
    }
    
    let convertedstring = NSString(bytes: unwrappedBuffer, length: Int(length), encoding: NSUTF8StringEncoding)
    
    guard let fileString = convertedstring as? String else {
        return
    }
    
    saveContext.prefData.append(fileString)
}



func midend_writeSave(context: UnsafeMutableRawPointer, buffer: UnsafeRawPointer?, length: Int32) {
    
}

func midend_readFile(context: UnsafeMutableRawPointer?, buffer: UnsafeMutableRawPointer?, length: Int32) -> Bool {
    
    guard buffer != nil else {
        return false
    }
    
    let context = midend_getPrefContext(context)
    
    //let convertedstring = NSString(bytes: unwrappedBuffer, length: Int(length), encoding: NSUTF8StringEncoding)
    
    guard context.prefData.length > 0 else {
        return false
    }
    
    var usedBytes: Int = 0
    
    let someBytesCopied = context.prefData.getBytes(buffer, maxLength: Int(length), usedLength: &usedBytes, encoding: NSUTF8StringEncoding, range: NSMakeRange(context.position, context.prefData.length - context.position), remaining: nil)
    context.position += usedBytes
    
    return someBytesCopied
    
    /*
    NSUInteger used = 0;
    BOOL r = [save getBytes:buf maxLength:len usedLength:&used encoding:NSUTF8StringEncoding options:0 range:NSMakeRange(srctx->pos, save.length-srctx->pos) remainingRange:NULL];
    srctx->pos += used;
    return r;
     */
}

/**
 Extension methods for saving & loading user preferences
 */
extension Midend {
    
    /**
     Saves user-configured game settings to a string
     */
    func saveUserPrefs() -> String? {
        let newSave = SaveContext()
        
        withUnsafePointer(to: newSave) { savePointer in
            midend_save_prefs(midendPointer, midend_writeFile, UnsafeMutableRawPointer(mutating: savePointer))
        }
        
        return newSave.saveToString()
    }
    
    func loadUserPrefs(preferences: String?) {
        
        guard preferences != nil else {
            print("No user preferences provided")
            return
        }
        
        let wrappedPrefs = SaveContext(savegame: preferences)
        
        withUnsafePointer(to: wrappedPrefs) { pointer in
            let error = midend_load_prefs(midendPointer, midend_readFile, UnsafeMutableRawPointer(mutating: pointer))
            
            if error != nil {
                let errString = String(cString: error!)
                print(errString)
            }
            
        }
    }
}

/**
 Extension methods for saving & loading saved games
 */
extension Midend {
    func saveInProgressGame() -> SaveContext? {
        print("Attempting to Save Game")
        // Verify we should save a game - if we're at the beginning or end of a game, we shouldn't!
        let shouldSave = midend_can_undo(midendPointer) && self.getPuzzleStatus() == .INPROGRESS
        
        if !shouldSave {
            print("Game Not In Progress, closing")
            return nil
        }
        
        var newSave = SaveContext()
        
        withUnsafePointer(to: &newSave) { savePointer in
            midend_serialise(midendPointer, midend_writeFile, UnsafeMutableRawPointer(mutating: savePointer))
        }
        
        return newSave
    }
    
    func readSave(_ savegame: SaveContext?) {
        
        guard let save = savegame else {
            return
        }
        
        withUnsafePointer(to: save) { savePointer in
            _ = midend_deserialise(midendPointer, midend_readFile, UnsafeMutableRawPointer(mutating: savePointer))
            //TODO: Process errors, if any? This returns an error message, but will we display it?
        }
    }
}


