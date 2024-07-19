//
//  GameFrontend.swift
//  Puzzles
//
//  Created by Kyle Swarner on 3/7/24.
//  Copyright © 2024 Kyle Swarner. All rights reserved.
//

import SwiftUI
import CoreGraphics

/** 
 Object representation of the puzzle frontend - this class is emitted to our swiftUI views and represents what is actually displayed to the user.
 It contains a reference to the midend - user interactions are piped from here into the midend, which will then relay back to us drawing instructions.
 */
@Observable
class Frontend {
    var midend: Midend // Reference to the midend
    var colors: [CGColor] = [] //typedef float rgb[3]; ?
    var gameHasStatusbar = false
    var movesTakenInGame = false
    var numColors: Int = 0
    var animationTimer = Timer()
    
    var gameGenerationTimer = Timer()
    var displayLoadingScreen = false
    var currentGameInvalidated = false
    var gameGenerationTask: Task<(), Never>?
    
    var game: game? // Reference to the actual game in the puzzle collection
    
    var imageManager: PuzzleImageManager?
    var statusbarText: String = ""
    var gameId: String = ""
    var puzzleTilesize: Int = 0
    
    var puzzleImage: CGImage?
    
    var canUndo = false
    var canRedo = false
    var canSolve = false
    var puzzleStatus: PuzzleStatus = .INPROGRESS
    
    var controlOption: ControlConfig = .defaultConfig
    
    var currentPreset: Int = -1 // Indicates the ID of the preset selected.
    var gamePresets: [PresetMenuItem] = []
    
    /** Split up the presets menu to prevent the menus from getting too large. If there's more than 10 items, split down the first 8 & overflow the rest.*/
    var gamePresetsPrimaryMenu: [PresetMenuItem] {
        guard gamePresets.count > 10 else {
            return gamePresets
        }
        return Array(gamePresets.prefix(8))
    }
    
    /** When needed, represents the overflow menu of game presets */
    var gamePresetsOverflowMenu: [PresetMenuItem] {
        guard gamePresets.count > 10 else {
            return []
        }
        return Array(gamePresets.suffix(gamePresets.count - 8))
    }
    
    init() {
        self.midend = Midend()
    }
    
    deinit {
        gameGenerationTask?.cancel()
    }
    
    func setGame(_ thegame: game) {
        self.game = thegame
    }
    
    @MainActor func beginGame(withSaveGame saveGame: String? = nil, withPreferences preferences: String? = nil) async {
       
        self.gameGenerationTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { _ in
            withAnimation {
                self.displayLoadingScreen = true
                self.currentGameInvalidated = true
            }
        }
        
        gameGenerationTask = Task {
            let dimensions = await midend.initGame(savegame: saveGame, preferences: preferences)
            
            // Stop timer here.
            self.gameGenerationTimer.invalidate()
            self.displayLoadingScreen = false
            self.currentGameInvalidated = false
            
            // Initialize the game and find the correct image boundaries
            self.imageManager = PuzzleImageManager(width: dimensions.x, height: dimensions.y)
            
            midend.drawPuzzle() // Actually draw the puzzle, once the image manager knows its size & is ready to go.
            self.puzzleTilesize = midend.getTilesize()
            
            gamePresets = midend.getGamePresets()
            self.movesTakenInGame = saveGame != nil // Assume moves have already been taken previously IF there's a savegame, otherewise set to false.
            updateFrontendFlags()
        }
    }
    
    func cancelNewGame() {
        self.displayLoadingScreen = false
        
        // Cancel the current game task to free up cycles
        gameGenerationTask?.cancel()
        
        self.gameGenerationTimer.invalidate()
    }
    
    func refreshImage() {
        //print("Refreshing Image")
        self.puzzleImage = imageManager?.toImage()
        updateFrontendFlags() // We still need this to ensure we update undo/redo buttons, etc when the puzzle state changes.
    }
    
    func undoMove() {
        // Ensure the image hasn't been disabled (during loading states)
        guard self.currentGameInvalidated == false else {
            return
        }
        
        midend.undo()
        updateFrontendFlags()
    }
    
    func redoMove() {
        // Ensure the image hasn't been disabled (during loading states)
        guard self.currentGameInvalidated == false else {
            return
        }
        
        midend.redo()
        updateFrontendFlags()
    }
    
    func clearSquare() {
        self.fireButton(PuzzleKeycodes.ClearButton)
        updateFrontendFlags()
    }
    
    
    func updateFrontendFlags() {
        self.canUndo = midend.undoEnabled()
        self.canRedo = midend.redoEnabled()
        self.puzzleStatus = midend.getPuzzleStatus()
        self.gameId = midend.getGameId()
        self.currentPreset = midend.getCurrentPreset()
        self.canSolve = midend.isPuzzleAutoSolvable()
    }
    
    func saveGame() -> String? {
        
        guard movesTakenInGame == true else {
            print("no moves taken in current game - not saving game")
            return nil
        }
        
        let save = midend.saveInProgressGame()
        return save?.saveToString() ?? nil
    }
    
    //
    func setNewGamePreset(_ parameters: OpaquePointer?) {
        midend.setGameParams(params: parameters)
    }
    
    func fireButton(_ button: ButtonPress?) {
        
        // Ensure the image hasn't been disabled (during loading states)
        guard self.currentGameInvalidated == false else {
            return
        }
        
        if let unwrappedButton = button {
            self.midend.sendKeypress(x: -1, y: -1, keypress: unwrappedButton.keycode)
            self.movesTakenInGame = true
        }
        else {
            print("Err: No button command provided on a button configured to emit a command.")
        }
        
        
    }

}

enum PuzzleStatus: Int {
    case SOLVED = 1
    case UNSOLVABLE = -1
    case INPROGRESS = 0
}

/** 
 Timer start/stop methods provided on the frontend
 These methods are typically triggered after the user interacts with the puzzle and emits midend calls to redraw - this is necessary for animations on the puzzle API that must redraw itself many times.
 The midend will trigger these via methods from `GlobalFunctions` and need not be called manually.
*/
extension Frontend {
    func startTimer() {
        if(animationTimer.isValid) {
            animationTimer.invalidate()
        }
        
        self.animationTimer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { _ in
            //print("Timer First WOO")
            self.midend.triggerTimer()
        }
        
    }
    
    func stopTimer() {
        //print("Stopping Timer beooooooo")
        animationTimer.invalidate()
    }
}


