//
//  GameStatsView.swift
//  Puzzles Reloaded
//
//  Created by Kyle Swarner on 11/17/24.
//  Copyright © 2024 Kyle Swarner. All rights reserved.
//

import SwiftUI

struct GameStatsView: View {
    
    @State private var showingClearStatsDialog = false
    
    // Game, to be provided when the settings menu is selected from within a game
    var game: Game
    
    var gameStats: UserSettingsSchemaV1.GameStats? {
        game.settings.stats
    }
    
    var body: some View {
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
                    Text(String(format: "%.0f%%", game.settings.stats.winPercentage))
                }
                
                
            }
            Section {
                Button("Reset Game Stats") {
                    print("Resetting Game Stats")
                    showingClearStatsDialog = true
                    
                }
            }
            
        }
        .confirmationDialog(
            "Clear Statistics For \(game)?",
            isPresented: $showingClearStatsDialog
        ) {
                Button("Reset Statistics", role: .destructive) {
                    game.settings.stats.resetStats()
                }
                Button("Cancel", role: .cancel) {
                    showingClearStatsDialog = false
                }
            }
        .navigationTitle("\(game.gameConfig.name) Statistics")
        .navigationBarTitleDisplayMode(.inline)
        
    }
}
