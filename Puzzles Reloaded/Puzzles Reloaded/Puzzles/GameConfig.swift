//
//  Game.swift
//  Puzzles
//
//  Created by Kyle Swarner on 2/27/24.
//  Copyright © 2024 Kyle Swarner. All rights reserved.
//

import Foundation
import SwiftUI

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
        hasher.combine(shortDescription)
    }
    
    static let defaultNumericFunction: (String) -> Int = { _ in 0 }
    
    var id = UUID()
    // var name: String
    var identifier: String
    var imageName: String
    var isExperimental: Bool
    
    // var instructions: String?
    // var controlInfo: String?
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
        identifier: String,
        customParamInfo: String? = nil,
        userParamInfo: String? = nil,
        imageName: String? = nil,
        internalGame: game,
        isExperimental: Bool = false,
        allowSingleFingerPanning: Bool = false,
        displayClearButtonInToolbar: Bool = false,
        touchControls: [ControlConfig] = [],
        buttonControls: [ControlConfig] = [],
        overflowMenuControls: [ControlConfig] = []) {
            
            self.identifier = identifier
        
            self.imageName = imageName ?? identifier // In case we need to pass in a cusom image name, otherwise reuse the main identifier.
            self.isExperimental = isExperimental
            self.internalGame = internalGame
            
            self.displayClearButtonInToolbar = displayClearButtonInToolbar
            self.allowSingleFingerPanning = allowSingleFingerPanning
            self.touchControls = touchControls
            self.buttonControls = buttonControls
            self.overflowMenuControls = overflowMenuControls
            
            self.numericButtonsBuilder = { _ in []}
    }
    
    // MARK: Localized Strings
    
    var name: String {
        let nameKey = "\(self.identifier)_name"
        return String(localized: String.LocalizationValue(nameKey), table: "Puzzles")
    }
    
    var shortDescription: String {
        let descriptionKey = "\(self.identifier)_description"
        return String(localized: String.LocalizationValue(descriptionKey), table: "Puzzles")
    }
    
    var instructions: String {
        let instructionsKey = "\(self.identifier)_instructions"
        return String(localized: String.LocalizationValue(instructionsKey), table: "Puzzles")
    }
    
    var controlInfo: String {
        let controlsKey = "\(self.identifier)_controls"
        return String(localized: String.LocalizationValue(controlsKey), table: "Puzzles")
    }
    
    func numericButtonsBuilder(_ numericButtonsBuilder: @escaping NumButtonsFunction) -> Self {
        self.numericButtonsBuilder = numericButtonsBuilder
        self.displayClearButtonInToolbar = true
        return self
    }
    
    var hasCustomControls: Bool {
        !touchControls.isEmpty || !buttonControls.isEmpty
    }
    
    static let exampleGame = GameConfig(
        identifier: "signpost",
        customParamInfo: "Information about custom parameters go here",
        userParamInfo: "Information about user parameters go here",
        imageName: "signpost",
        internalGame: net)
}
