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
    var numColors: Int = 0
    var timer = Timer()
    
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
    
    var currentPreset: Int = -1// Indicates the ID of the preset selected.
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
        self.imageManager = nil // Can we get rid of this? Can't create the image processor until we know the height, otherwise the bitmap starts getting weird.
        self.midend = Midend()
    }
    
    func setGame(_ thegame: game) {
        self.game = thegame
    }
    
    func beginGame(withSaveGame saveGame: String? = nil, withPreferences preferences: String? = nil) {
        // This isn't done in the initializer because I need a reference to this object as an inout (&frontend) that is passed in from the view. I can't pass it here due to immutability concerns.
        // If I can refactor this down the road, we can clean this code up a bit!
        
        
        let dimensions = midend.initGame(savegame: saveGame, preferences: preferences) // Initialize the game and find the correct image boundaries
        self.imageManager = PuzzleImageManager(width: dimensions.x, height: dimensions.y) // Adding 10 to y dimensions to even out items that line riiiight up to the top of the puzzle
        midend.drawPuzzle() // Actually draw the puzzle, once the image manager knows its size & is ready to go.
        self.puzzleTilesize = midend.getTilesize()
        
        //print("777 FORCE FULL REFRESH 777")
        //self.imageManager?.forceRefresh()
        gamePresets = midend.getGamePresets()
        updateFrontendFlags()
        
    }
    
    func refreshImage() {
        //print("Refreshing Image")
        self.puzzleImage = imageManager?.toImage()
        updateFrontendFlags() // We still need this to ensure we update undo/redo buttons, etc when the puzzle state changes.
    }
    
    func undoMove() {
        midend.undo()
        updateFrontendFlags()
    }
    
    func redoMove() {
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
        
        //withAnimation(.easeInOut(duration: 2.0)) {
        self.puzzleStatus = midend.getPuzzleStatus()
        
        // !!!
        //midend.saveUserPrefs()
        //let save = midend.saveInProgressGame()
        //midend.readSave(save)
        //}
        
    }
    
    func saveGame() -> String? {
        let save = midend.saveInProgressGame()
        return save?.saveToString() ?? nil
        //midend.readSave(save)
    }
    
    //
    func setNewGamePreset(_ parameters: OpaquePointer?) {
        midend.setGameParams(params: parameters)
        self.beginGame() // Immediately start a new game based on the preset parameters provided.
    }
    
    func fireButton(_ button: ButtonPress?) {
        
        if let unwrappedButton = button {
            self.midend.sendKeypress(x: -1, y: -1, keypress: unwrappedButton.keycode)
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
        if(timer.isValid) {
            timer.invalidate()
        }
        
        self.timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { _ in
            //print("Timer First WOO")
            self.midend.triggerTimer()
        }
        
    }
    
    func stopTimer() {
        //print("Stopping Timer beooooooo")
        timer.invalidate()
    }
}


