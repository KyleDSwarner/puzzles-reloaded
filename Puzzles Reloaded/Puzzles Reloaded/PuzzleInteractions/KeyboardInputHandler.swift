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
    private var gameConfig: GameConfig
    
    private var gameControls: [ControlConfig] = []
    
    private var currentGameId: String = ""
    
    init(frontend: Frontend) {
        self.frontend = frontend
        self.gameConfig = frontend.game.gameConfig
    }
    
    func handleKeypress(keypress: KeyPress) -> KeyPress.Result {
        // print("Keypress Pressed: \(keypress.characters)")
        
        //let keypress: Character = something.first
        guard let keypressChar = keypress.characters.first else {
            return .ignored
        }
        
        var commandToFire = -1
        
        // Regnerate locally cached controls when we detect a change to the game ID
        if currentGameId != frontend.gameId {
            currentGameId = frontend.gameId
            gameControls = gameConfig.numericButtonsBuilder(frontend.gameId)
            
            print("Touch Controls: \(gameControls)")
            
            if gameControls.isEmpty {
                print("Empty, so filling with \(gameConfig.buttonControls)")
                gameControls = gameConfig.buttonControls
            }
            
            // Append the overflow menu controls so we can check it all at once
            gameControls.append(contentsOf: gameConfig.overflowMenuControls)
        }
        
        // TODO: Is any of this part necessary? If we're going to ASCII everything, does this matter AT ALL?
        // If there's a numeric button builder & we have a game ID, let's check that.
        if let gameControl = gameControls.first(where: { $0.buttonCommand?.character != nil}), let controlCharacter = gameControl.buttonCommand?.character, controlCharacter.uppercased() == keypressChar.uppercased() {
            print("Matching Control: \(controlCharacter)")
            // commandToFire = gameControl.buttonCommand?.keycode ?? -1
        }
        
        // If the game Control isn't yet found, move on to built-in commands:
        
        if commandToFire == -1 {
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
        }
        
        // Otherwise, let's just convert it to the ascii value and see wtf happens:
        if commandToFire == -1 {
            print("Trying ascii value for \(keypress.characters)")
            commandToFire = Int(keypressChar.asciiValue ?? 0)
        }
        
        print("Applying Modifiers")
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
        
        // We should also check the overflow Menu
        
        //if controlOptions.buil
        
        //controlOptions.first(where: { $0.buttonCommand?.keycode != nil})
        
        // Check if input is valid from touch controls (Sudoku, etc, 1-0)
        
        // check for solve, undo, hints, etc.
        
        // Check for arrow keys
        
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
    
    func generateControls() -> [ControlConfig] {
        return []
    }
    
    func convertKeypress(keypress: KeyPress) -> Int {
        switch keypress.key {
        case .upArrow:
            return CURSOR_UP
        case .downArrow:
            return CURSOR_UP
        case .leftArrow:
            return CURSOR_LEFT
        case .rightArrow:
            return CURSOR_RIGHT
        default:
            return -1
        }
    }
    
    
    /*
    //UIPress *press;
    for (press in presses) {
        if (press.key != nil) {
            int sendKey = -1;
            if (
                ourgame->can_solve
                && press.key.modifierFlags & UIKeyModifierControl
                && [press.key.charactersIgnoringModifiers isEqual: @"s"]
            ) {
                sendKey = UI_SOLVE;
            } else if ([press.key.charactersIgnoringModifiers length] == 1) {
                sendKey = [press.key.charactersIgnoringModifiers characterAtIndex:0];
            } else {
                switch (press.key.keyCode) {
                    case UIKeyboardHIDUsageKeyboardLeftArrow:
                        sendKey = CURSOR_LEFT;
                        break;
                    case UIKeyboardHIDUsageKeyboardUpArrow:
                        sendKey = CURSOR_UP;
                        break;
                    case UIKeyboardHIDUsageKeyboardRightArrow:
                        sendKey = CURSOR_RIGHT;
                        break;
                    case UIKeyboardHIDUsageKeyboardDownArrow:
                        sendKey = CURSOR_DOWN;
                        break;
                }
            }
            if (sendKey != -1) {
                midend_process_key(me, -1, -1, sendKey);
            }
        }
    }
     */
    
}
