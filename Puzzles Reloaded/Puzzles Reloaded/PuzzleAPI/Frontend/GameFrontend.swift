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
class Frontend: @unchecked Sendable {
    var midend: Midend // Reference to the midend
    var colors: [CGColor] = [] // Array of colors used to build the puzzle. Set from the midend when building the puzzle.
    var useDarkTheme: Bool = false
    
    var gameHasStatusbar = false
    var movesTakenInGame = false
    var numColors: Int = 0
    var animationTimer = Timer()
    
    var gameGenerationTimer = Timer()
    var displayLoadingScreen = false
    var currentGameInvalidated = false
    var gameGenerationTask: Task<(), Never>?
    
    var game: Game
    
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
    
    init(game: Game) {
        self.game = game
        self.midend = Midend(game: game.gameConfig.internalGame) // Init midend and give it the internal game
    }
    
    deinit {
        gameGenerationTask?.cancel()
    }
    
    @MainActor func beginGame(isFirstLoad: Bool = false, withSaveGame saveGame: String? = nil, withPreferences preferences: String? = nil) async {
       
        self.gameGenerationTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { _ in
            withAnimation {
                self.displayLoadingScreen = true
                self.currentGameInvalidated = true
            }
        }
        
        // Go ahead and generate the game presets if they aren't already
        if gamePresets.isEmpty {
            gamePresets = midend.getGamePresets()
        }
        
        // If this is the first app load, load user preferences, saved games, and defaults.
        if isFirstLoad {
            
            // If there's a saved preset, use it!
            if !game.settings.customDefaultPreset.isEmpty {
                // Ignoring potential return value of this call, assuming that it can never be set without first having the error value checked in the UI.
                print("Detected Custom Preset - Loading Data into Puzzle")
                _ = midend.setGameCustomParameters(choices: game.settings.customDefaultPreset)
            }
            else if let userPreset = game.settings.selectedDefaultPreset {
                print("Detected Preset \(userPreset)")
                if let preset = gamePresets.first(where: { $0.id == userPreset}) {
                    print("Found Preset \(userPreset) == \(preset.title)")
                    self.setNewGamePreset(preset.params)
                }
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
    
    func setNewGamePreset(_ parameters: OpaquePointer?) {
        midend.setGameParams(params: parameters)
    }
    
    func getColor(_ index: Int) -> CGColor {
        
        // Replace background color for dark mode:
        if index == 0 && useDarkTheme == true {
            return CGColor(red: 0, green: 0, blue: 0, alpha: 1)
        }
        
        return colors[index]
        // TODO: Dark Mode Adjustments here!
    }
    
    /**
     Fire a button press to the puzzle midend.
     The result of `sendKeypress` is ignored as buttons as configured to handle their own visual effects. It would be odd if buttons didn't consistently provide the feedback.
     */
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


/** 
 Timer start/stop methods provided on the frontend
 These methods are typically triggered after the user interacts with the puzzle and emits midend calls to redraw - this is necessary for animations on the puzzle API that must redraw itself many times.
 The midend will trigger these via methods from `GlobalFunctions` and need not be called manually.
*/
extension Frontend {
    func startAnimationTimer() {
        if(animationTimer.isValid) {
            animationTimer.invalidate()
        }
        
        self.animationTimer = Timer.scheduledTimer(withTimeInterval: PuzzleConstants.animationRedrawDelay, repeats: true) { _ in
            self.midend.triggerTimer()
        }
        
    }
    
    func stopAnimationTimer() {
        animationTimer.invalidate()
    }
}

/**
 These methods set puzzle defaults to load when there's no save, either puzzle-provided defaults, or user-designed customs.
 */
extension Frontend {
    
    func setPuzzlePreset(defaultPreset: PresetMenuItem) {
        print("Saving Preset as Default: \(defaultPreset.title)")
        game.settings.selectedDefaultPreset = defaultPreset.id
        game.settings.customDefaultPreset = []
    }
    
    func setPuzzlePreset(customPreset: [CustomMenuItem]) {
        print("Saving Custom Presets!")
        game.settings.customDefaultPreset = customPreset
        game.settings.selectedDefaultPreset = nil
        
    }
}


