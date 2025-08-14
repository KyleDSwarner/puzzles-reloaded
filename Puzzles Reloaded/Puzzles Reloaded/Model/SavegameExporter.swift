//
//  ExportedSavegame.swift
//  Puzzles Reloaded
//
//  Created by Kyle Swarner on 8/14/25.
//  Copyright © 2025 Kyle Swarner. All rights reserved.
//

import Foundation
import CoreTransferable

struct ExportedSavegame : Transferable {
    
    let generateSavegame: @Sendable () -> SaveContext
    
    static var transferRepresentation: some TransferRepresentation {

        DataRepresentation(exportedContentType: .puzzleSavegame) { exporter in
            
            let savegame = exporter.generateSavegame() // Defer generation of the savegame until it's actually needed in order to avoid any odd issues with ShareLink race conditions
            let data = savegame.prefData as String
            return Data(data.utf8)
            
        }
    }
    
}
