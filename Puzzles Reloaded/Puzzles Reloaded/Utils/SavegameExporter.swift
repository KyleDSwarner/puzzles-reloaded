//
//  ExportedSavegame.swift
//  Puzzles Reloaded
//
//  Created by Kyle Swarner on 8/14/25.
//  Copyright © 2025 Kyle Swarner. All rights reserved.
//

import Foundation
import CoreTransferable
import UniformTypeIdentifiers

extension UTType {
    static let puzzleSavegame: UTType = UTType(exportedAs: "com.kds.sgtp.savegame")
}

struct SavegameExporter : Transferable {
    
    let generateSavegame: @Sendable () -> (filename: String, save: SaveContext)
    
    static var transferRepresentation: some TransferRepresentation {

        /*
        DataRepresentation(exportedContentType: .puzzleSavegame) { exporter in
            
            let savegame = exporter.generateSavegame() // Defer generation of the savegame until it's actually needed in order to avoid any odd issues with ShareLink race conditions
            let data = savegame.prefData as String
            return Data(data.utf8)
            
        }
         */
        
        FileRepresentation(exportedContentType: .puzzleSavegame, exporting: { exporter in
            
            
            let saveInfo = exporter.generateSavegame()
            let data = saveInfo.save.prefData as String
            
            let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent(saveInfo.filename, conformingTo: .puzzleSavegame)
            
            try data.write(to: fileURL, atomically: true, encoding: .utf8)
            
            return SentTransferredFile(fileURL)
        })
    }
    
}
