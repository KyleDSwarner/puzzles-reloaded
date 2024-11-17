//
//  GameStatsView.swift
//  Puzzles Reloaded
//
//  Created by Kyle Swarner on 11/17/24.
//  Copyright © 2024 Kyle Swarner. All rights reserved.
//

import SwiftUI

struct GameStatsView: View {
    
    // Game, to be provided when the settings menu is selected from within a game
    var game: Game? = nil
    
    var gameStats: UserSettingsSchemaV1.GameStats? {
        game?.settings.stats
    }
    
    var body: some View {
        if let game = game {
            Form {
                Section {
                    HStack {
                        Text("Total Games Played")
                        Spacer()
                        Text("\(game.settings.stats.gamesPlayed)")
                    }
                    
                    HStack {
                        Text("Games Won")
                        Spacer()
                        Text("\(game.settings.stats.gamesWon)")
                    }
                    
                    HStack {
                        Text("Win Percentage")
                        Spacer()
                        Text(String(format: "%.2f%%", game.settings.stats.winPercentage))
                    }
                    
                    
                }
                Section {
                    Button("Reset Game Stats") {
                        print("Resetting Game Stats")
                        game.settings.stats.resetStats()
                    }
                }
                
            }
            .navigationTitle("\(game.gameConfig.name) Statistics")
            .navigationBarTitleDisplayMode(.inline)
        } else {
            VStack {
                Text("No Game Provided, global stats go here?")
            }
        }
        
    }
}

#Preview {
    GameStatsView()
}
