//
//  GamePresetMenuItem.swift
//  Puzzles Reloaded
//
//  Created by Kyle Swarner on 6/24/24.
//  Copyright © 2024 Kyle Swarner. All rights reserved.
//

import Foundation

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
