//
//  Game.swift
//  Puzzles
//
//  Created by Kyle Swarner on 2/27/24.
//  Copyright © 2024 Kyle Swarner. All rights reserved.
//

import Foundation

typealias NumButtonsFunction = (_ gameId: String) -> [ControlConfig]
typealias FireButtonFunction = (_ button: ButtonPress?) -> Void

// Intent: Representation of the game data fed from the on-device tatham games.
@Observable 
class GameConfig: Identifiable, Hashable {
    
    static func == (lhs: GameConfig, rhs: GameConfig) -> Bool {
        return lhs.name == rhs.name
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(description)
    }
    
    static let defaultNumericFunction: (String) -> Int = { _ in 0 }
    
    var id = UUID()
    var name: String
    var imageName: String
    var description: String
    var isExperimental: Bool
    
    var helpPage: HelpModel?
    
    var touchControls: [ControlConfig]
    var buttonControls: [ControlConfig]
    var overflowMenuControls: [ControlConfig]
    
    // Optionally provide a custom function that returns the number of numeric buttons to display for the given game type
    var numericButtonsBuilder: NumButtonsFunction
    var allowSingleFingerPanning: Bool // <-- Games that require dragging to select multiple boxes will need two-finger panning.
    var displayClearButtonInToolbar: Bool // <-- Many games need a clear button, this boolean adds it to the toolbar, next to undo/redo
    
    var game: game // The reference to the game representation from the c code.
    
    init(name: String, descritpion: String, imageName: String = "", helpPage: HelpModel? = nil, game: game, isExperimental: Bool = false, allowSingleFingerPanning: Bool = false, displayClearButtonInToolbar: Bool = false, touchControls: [ControlConfig] = [], buttonControls: [ControlConfig] = [], overflowMenuControls: [ControlConfig] = []) {
        self.name = name
        self.description = descritpion
        self.imageName = !imageName.isEmpty ? imageName : name //TODO: Clean this up once we fix up all the other games.
        self.helpPage = helpPage
        self.isExperimental = isExperimental
        self.game = game
        
        self.displayClearButtonInToolbar = displayClearButtonInToolbar
        self.allowSingleFingerPanning = allowSingleFingerPanning
        self.touchControls = touchControls
        self.buttonControls = buttonControls
        self.overflowMenuControls = overflowMenuControls
        
        self.numericButtonsBuilder = { _ in []}
        
    }
    
    func numericButtonsBuilder(_ numericButtonsBuilder: @escaping NumButtonsFunction) -> Self {
        self.numericButtonsBuilder = numericButtonsBuilder
        return self
    }
    
    var hasCustomControls: Bool {
        !touchControls.isEmpty || !buttonControls.isEmpty
    }
    
    static let exampleGame = GameConfig(name: "net", descritpion: "Example Text", game: net)
}
