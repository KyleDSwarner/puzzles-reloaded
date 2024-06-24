//
//  SaveContext.swift
//  Puzzles Reloaded
//
//  Created by Kyle Swarner on 6/24/24.
//  Copyright © 2024 Kyle Swarner. All rights reserved.
//

import Foundation

class SaveContext {
    var position: Int = 0 // Since file reads occur in chunks, this keeps track of what has already been read.
    var prefData: NSMutableString = ""
    
    func saveToString() -> String? {
        return prefData as String
    }
    
    init() {
        self.prefData = ""
    }
    
    init(savegame: String?) {
        self.prefData = NSMutableString(string: savegame ?? "")
    }
}
