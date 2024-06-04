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
    
    var instructions: String?
    var controlInfo: String?
    var customParamInfo: String?
    var userParamInfo: String?
    
    var touchControls: [ControlConfig]
    var buttonControls: [ControlConfig]
    var overflowMenuControls: [ControlConfig]
    
    // Optionally provide a custom function that returns the number of numeric buttons to display for the given game type
    var numericButtonsBuilder: NumButtonsFunction
    var allowSingleFingerPanning: Bool // <-- Games that require dragging to select multiple boxes will need two-finger panning.
    var displayClearButtonInToolbar: Bool // <-- Many games need a clear button, this boolean adds it to the toolbar, next to undo/redo
    
    var internalGame: game // The reference to the game representation from the c code.
    
    init(
        name: String,
        description: String,
        instructions: String? = nil,
        controlInfo: String? = nil,
        customParamInfo: String? = nil,
        userParamInfo: String? = nil,
        imageName: String,
        internalGame: game,
        isExperimental: Bool = false,
        allowSingleFingerPanning: Bool = false,
        displayClearButtonInToolbar: Bool = false,
        touchControls: [ControlConfig] = [],
        buttonControls: [ControlConfig] = [],
        overflowMenuControls: [ControlConfig] = []) {
            
            self.name = name
            self.description = description
            self.instructions = instructions
            self.controlInfo = controlInfo
            self.customParamInfo = customParamInfo
            self.userParamInfo = userParamInfo
        
            self.imageName = imageName
            self.isExperimental = isExperimental
            self.internalGame = internalGame
            
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
    
    static let exampleGame = GameConfig(
        name: "Example Game",
        description: "Example Text",
        instructions: """
        Here are some long form game instructions. These will tend to get pretty wordy!

        Multiple lines go here. Anyway, how are you today? I hope everything is great.
        """,
        controlInfo: "Controls go here. Left click, right click, all that jazz.",
        customParamInfo: "Information about custom parameters go here",
        userParamInfo: "Information about user parameters go here",
        imageName: "signpost",
        internalGame: net)
}
