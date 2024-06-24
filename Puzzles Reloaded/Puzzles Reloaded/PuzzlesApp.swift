//
//  PuzzlesApp.swift
//  Puzzles
//
//  Created by Kyle Swarner on 2/23/24.
//  Copyright © 2024 Kyle Swarner. All rights reserved.
//

import SwiftUI
import SwiftData

@main
struct PuzzlesApp: App {
    
    @State private var gameManager = GameManager()
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            GameUserSettings.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
        
    }()

    var body: some Scene {
        WindowGroup {
            GameListView()
        }
        .modelContainer(sharedModelContainer)
        .environment(gameManager)
    }
}

#Preview {
    GameListView()
        .modelContainer(for: GameUserSettings.self, inMemory: true)
        .environment(GameManager())
}
