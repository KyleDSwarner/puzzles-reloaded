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
    
    var gameStats: UserSettingsSchemaV1.GameStats {
        game.settings.stats
    }
    
    var formattedWinPercentage: String? {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .percent

        // Using significant digits
        numberFormatter.usesSignificantDigits = false
        numberFormatter.maximumFractionDigits = 2
        
        return numberFormatter.string(from: gameStats.winPercentage as NSNumber)
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
                
                if let formattedWinPercentage = formattedWinPercentage {
                    HStack {
                        Text("Win Percentage")
                        Spacer()
                        Text(formattedWinPercentage)
                    }
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
