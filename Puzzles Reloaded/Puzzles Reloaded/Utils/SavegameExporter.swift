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
    
    let generateSavegame: @Sendable () -> (filename: String, save: SaveContext?)
    
    enum ExportError: Error {
        case saveUnavailable
    }
    
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
            
            guard let save = saveInfo.save else {
                // The midend wasn't available when the export was requested (e.g. it was still being recreated).
                // Note: errors thrown from a FileRepresentation export are not surfaced by ShareLink itself,
                // so log here to keep the failure visible while debugging.
                print("Savegame export failed: midend unavailable")
                throw ExportError.saveUnavailable
            }
            
            let data = save.prefData as String
            
            let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent(saveInfo.filename, conformingTo: .puzzleSavegame)
            
            try data.write(to: fileURL, atomically: true, encoding: .utf8)
            
            return SentTransferredFile(fileURL)
        })
    }
    
}

/**
 Provides a user-facing message for export failures, so the error reads clearly if/when it is
 surfaced (e.g. via an alert in a caller that chooses to catch it).
 */
extension SavegameExporter.ExportError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .saveUnavailable:
            return "This puzzle isn't ready to share right now. Please try again in a moment."
        }
    }
}
