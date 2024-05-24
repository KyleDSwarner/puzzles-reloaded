//
//  Midend.swift
//  Puzzles
//
//  Created by Kyle Swarner on 4/18/24.
//  Copyright © 2024 Kyle Swarner. All rights reserved.
//

import Foundation
import CoreGraphics

class PresetMenuItem: Identifiable {
    let id: Int
    let title: String
    
    //These items are mutuall exclusive: There will always be one or the other.
    var params: OpaquePointer? // End of the chain - this indicates parameters for the game.
    var submenu: [PresetMenuItem]? // Nested Menus!
    
    init(id: Int, title: String) {
        self.id = id
        self.title = title
        self.params = nil
        self.submenu = nil
    }
    
    func addNestedMenu(_ submenu: [PresetMenuItem]) {
        self.submenu = submenu
    }
    
    func addParams(_ params: OpaquePointer) {
        self.params = params
    }
}

/**
 Class represents the functions on the 'midend', the object that connects the puzzle backend to our code here.
 The actual midend object is provided as an `OpaquePointer` and the midend methods are provided globally by the puzzle code.
 This class attempts to organize & clean up these methods & prevent any 'non-swift-y' language to escape.
 */
class Midend {
    var midendPointer: OpaquePointer? = nil
    var game: game?
    var currentGamePreset: Int = -1
    
    init() {
    }
    
    func setMidendPointer(midendPointer: OpaquePointer?) {
        self.midendPointer = midendPointer
    }
    
    func setGame(_ thegame: game) {
        self.game = thegame
    }
    
    func triggerTimer() {
        midend_timer(midendPointer, 0.01)
    }
    
    func undo() {
        sendKeypress(x: -1, y: -1, keypress: PuzzleKeycodes.UNDO)
    }
    
    func redo() {
        sendKeypress(x: -1, y: -1, keypress: PuzzleKeycodes.REDO)
    }
    
    func restartGame() {
        midend_restart_game(midendPointer)
    }
    
    func undoEnabled() -> Bool {
        return midend_can_undo(midendPointer)
    }
    
    func redoEnabled() -> Bool {
        return midend_can_redo(midendPointer)
    }
    
    func isPuzzleAutoSolvable() -> Bool {
        return game?.can_solve == true
    }
    
    func solvePuzzle() {
        midend_solve(midendPointer)
    }
    
    func sendKeypress(x: Int, y: Int, keypress: Int) {
        midend_process_key(self.midendPointer, Int32(x), Int32(y), Int32(keypress)) // We need to process how we send what keys & when
    }
    
    func getPuzzleStatus() -> PuzzleStatus {
        return PuzzleStatus(rawValue: Int(midend_status(midendPointer))) ?? .INPROGRESS
    }
    
    func getGameId() -> String {
        let gameId = midend_get_game_id(midendPointer)
        
        if let unwrappedId = gameId {
            return String(cString: unwrappedId)
        }
        
        return "no-game-id-found"
    }
    
    func createMidend(frontend: inout Frontend) {
        
        guard let gameRef = game else {
            fatalError("ERROR: Game not defined!")
        }
        
        //let game = net // TODO make this game configurable!
        
        let drawingApi = DrawingAPI.asPointer()
        
        
        // Explicitly create pointers to the relevant items. Doing so explicitly prevents swift from automatically deallocating the data once we leave this method.
        
        //let drawingApiPointer = UnsafeMutablePointer<drawing_api>.allocate(capacity: 1)
        //drawingApiPointer.pointee = drawingApi
        
        let gamePointer = UnsafeMutablePointer<game>.allocate(capacity: 1)
        gamePointer.pointee = gameRef
        
        let frontendPointer = UnsafeMutablePointer<Frontend>.allocate(capacity: 1)
        frontendPointer.pointee = frontend
        
        let midend: OpaquePointer? = midend_new(OpaquePointer(frontendPointer), gamePointer, drawingApi, frontendPointer /* frontend again? */) // OpaquePointer to Midend object
        
        
        //frontend.midend.setMidendPointer(midendPointer: midend)
        self.midendPointer = midend
        frontend.gameHasStatusbar = midend_wants_statusbar(midend)
        buildGameColors(midend: midend, frontend: frontend)
        
        // Save/Load?
        
        //else start new game - GameView:174
        //initGame()
    }
    
    func buildGameColors(midend: OpaquePointer?, frontend: Frontend) {
        let numColorsPointer = UnsafeMutablePointer<Int32>.allocate(capacity: 1)
        
        let colors: UnsafeMutablePointer<Float> = midend_colours(midend, numColorsPointer)
        let numColors = Int(numColorsPointer.pointee)
        print("Num colors: \(Int(numColors))")
        

        // Color 0 comes from the `frontend_default_colour` function in `GlobalFunctions`. The others are configured per-game.
        for i in 0..<numColors {
            let r = colors[i*3], g = colors[i*3+1], b = colors[i*3+2]
            let newColor = CGColor(red: CGFloat(r), green: CGFloat(g), blue: CGFloat(b), alpha: 1.0)
            
            frontend.colors.append(newColor)
        }
        
        frontend.numColors = numColors
    }
    
    func initGame() -> (x: Int, y: Int) {
        midend_new_game(midendPointer)
        
        //This function will create a new game_drawstate, but does not actually perform a redraw (since you often need to call midend_size() before the redraw can be done). So after calling this function and after calling midend_size(), you should then call midend_redraw(). (It is not necessary to call midend_force_redraw(); that will discard the draw state and create a fresh one, which is unnecessary in this case since there's a fresh one already. It would work, but it's usually excessive.)
        
        //void midend_size(midend *me, int *x, int *y, bool user_size, double device_pixel_ratio);
        // midend_size(me, &w, &h, FALSE, 1.0);
        
        /*
         Use user_size to indicate whether *x and *y are a requested size, or just a maximum size.

         If user_size is set to true, the mid-end will treat the input size as a request, and will pick a tile size which approximates it as closely as possible, going over the game's preferred tile size if necessary to achieve this. The mid-end will also use the resulting tile size as its preferred one until further notice, on the assumption that this size was explicitly requested by the user. Use this option if you want your front end to support dynamic resizing of the puzzle window with automatic scaling of the puzzle to fit.

         If user_size is set to false, then the game's tile size will never go over its preferred one, although it may go under in order to fit within the maximum bounds specified by *x and *y. This is the recommended approach when opening a new window at default size: the game will use its preferred size unless it has to use a smaller one to fit on the screen. If the tile size is shrunk for this reason, the change will not persist; if a smaller grid is subsequently chosen, the tile size will recover.

         The mid-end will try as hard as it can to return a size which is less than or equal to the input size, in both dimensions. In extreme circumstances it may fail (if even the lowest possible tile size gives window dimensions greater than the input), in which case it will return a size greater than the input size. Front ends should be prepared for this to happen (i.e. don't crash or fail an assertion), but may handle it in any way they see fit: by rejecting the game parameters which caused the problem, by opening a window larger than the screen regardless of inconvenience, by introducing scroll bars on the window, by drawing on a large bitmap and scaling it into a smaller window, or by any other means you can think of. It is likely that when the tile size is that small the game will be unplayable anyway, so don't put too much effort into handling it creatively.
         */
        
        let devicePixelRatio = 2.0 //Could it be improved on higher density displays? TBD.
        let userSize = true

        let puzzleWidth = UnsafeMutablePointer<Int32>.allocate(capacity: 1) // TODO size of image, as computed?
        puzzleWidth.initialize(to: Int32(PuzzleSettings.puzzleSize))
        
        let puzzleHeight = UnsafeMutablePointer<Int32>.allocate(capacity: 1)// TODO size of image, as computed?
        puzzleHeight.initialize(to: Int32(PuzzleSettings.puzzleSize))
    
        
        
        midend_size(midendPointer, puzzleWidth, puzzleHeight, userSize, devicePixelRatio)
        
        print("??? Puzzle determined ideal size as \(Int(puzzleWidth.pointee)) by \(Int(puzzleHeight.pointee)) ???")
        
        
        
        let gameHasStatusbar: Bool = midend_wants_statusbar(midendPointer)
        print("Game Requests Statusbar: \(gameHasStatusbar)")
        
        // Set global X & Y Variables to drive image drawing & interpolation
        puzzleDimensionsX = Int(puzzleWidth.pointee)
        puzzleDimensionsY = Int(puzzleHeight.pointee)
        
        let gameId = midend_get_game_id(midendPointer)
        
        let gameIdString = String(cString: gameId!)
        print("Game ID: \(gameIdString)")
        
        return (x: Int(puzzleWidth.pointee), y: Int(puzzleHeight.pointee))
        
        //midend_redraw(midendPointer)
    }
    
    func drawPuzzle() {
        // Ensure puzzle settings have been configured correctly before running this!
        midend_redraw(midendPointer)
    }
    
    func setGameParams(params: OpaquePointer?) {
        midend_set_params(midendPointer, params)
    }
}

extension Midend {

}
