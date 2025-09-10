//
//  KeyboardInputHandler.swift
//  Puzzles Reloaded
//
//  Created by Kyle Swarner on 8/19/24.
//  Copyright © 2024 Kyle Swarner. All rights reserved.
//

import SwiftUI

class KeyboardInputHandler {
    
    private var frontend: Frontend
    
    init(frontend: Frontend) {
        self.frontend = frontend
    }
    
    func handleKeypress(keypress: KeyPress) -> KeyPress.Result {
        // print("Keypress Pressed: \(keypress.characters)")
        
        guard let keypressChar = keypress.characters.first else {
            return .ignored
        }
        
        var commandToFire = -1
        
        // If the game Control isn't yet found, move on to built-in commands:
        
        switch keypress.key {
        case .upArrow:
            commandToFire = CURSOR_UP
        case .downArrow:
            commandToFire = CURSOR_DOWN
        case .leftArrow:
            commandToFire = CURSOR_LEFT
        case .rightArrow:
            commandToFire = CURSOR_RIGHT
        case .return:
            commandToFire = CURSOR_SELECT
        case .space:
            commandToFire = CURSOR_SELECT2
        default:
            commandToFire = -1
        }
        
        // Otherwise, let's just convert it to the ascii value and see wtf happens:
        if commandToFire == -1 {
            print("Keypress received: \(keypress.characters)")
            commandToFire = Int(keypressChar.asciiValue ?? 0)
        }
        
        if keypress.modifiers.contains(.command) || keypress.modifiers.contains(.control) {
            print("Control button detected, modding")
            commandToFire = commandToFire | MOD_CTRL
        }
        if keypress.modifiers.contains(.shift) {
            print("Shift  button detected, modding")
            commandToFire = commandToFire | MOD_SHFT
        }
        
        /*
         New game (‘N’, Ctrl+‘N’)
         Starts a new game, with a random initial state.
         Restart game
         Resets the current game to its initial state. (This can be undone.)
         Load
         Loads a saved game from a file on disk.
         Save
         Saves the current state of your game to a file on disk.
         The Load and Save operations preserve your entire game history (so you can save, reload, and still Undo and Redo things you had done before saving).

         Print
         Where supported (currently only on Windows), brings up a dialog allowing you to print an arbitrary number of puzzles randomly generated from the current parameters, optionally including the current puzzle. (Only for puzzles which make sense to print, of course – it's hard to think of a sensible printable representation of Fifteen!)
         Undo (‘U’, Ctrl+‘Z’, Ctrl+‘_’, ‘*’)
         Undoes a single move. (You can undo moves back to the start of the session.)
         Redo (‘R’, Ctrl+‘R’, ‘#’)
         Redoes a previously undone move.
         Copy
         Copies the current state of your game to the clipboard in text format, so that you can paste it into (say) an e-mail client or a web message board if you're discussing the game with someone else. (Not all games support this feature.)
         Solve
         Transforms the puzzle instantly into its solved state. For some games (Cube) this feature is not supported at all because it is of no particular use. For other games (such as Pattern), the solved state can be used to give you information, if you can't see how a solution can exist at all or you want to know where you made a mistake. For still other games (such as Sixteen), automatic solution tells you nothing about how to get to the solution, but it does provide a useful way to get there quickly so that you can experiment with set-piece moves and transformations.
         Some games (such as Solo) are capable of solving a game ID you have typed in from elsewhere. Other games (such as Rectangles) cannot solve a game ID they didn't invent themself, but when they did invent the game ID they know what the solution is already. Still other games (Pattern) can solve some external game IDs, but only if they aren't too difficult.

         The ‘Solve’ command adds the solved state to the end of the undo chain for the puzzle. In other words, if you want to go back to solving it yourself after seeing the answer, you can just press Undo.

         Quit (‘Q’, Ctrl+‘Q’)
         Closes the application entirely.
         Preferences
         Where supported, brings up a dialog allowing you to configure personal preferences about a particular game. Some of these preferences will be specific to a particular game; others will be common to all games.
         One option common to all games allows you to turn off the one-key shortcuts like ‘N’ for new game or ‘Q’ for quit, so that there's less chance of hitting them by accident. You can still access the same shortcuts with the Ctrl key.
         */
        
        
        // If keypress is still -1, fall out
        if commandToFire == -1 {
            return .ignored
        }
        
        // Apply Modifiers (Ctrl, Alt, Shift)
        
        // Send Keypress
        let result = frontend.midend.sendKeypress(x: -1, y: -1, keypress: commandToFire)
        
        if result == PuzzleInteractionResponse.someEffect {
            //print("Hooray, something happened!")
            return .handled
        }
        
        return .ignored
    }

    
}
