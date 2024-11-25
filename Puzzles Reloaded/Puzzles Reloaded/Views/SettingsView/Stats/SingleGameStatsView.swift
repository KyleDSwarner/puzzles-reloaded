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
    
    // Return game history sorted in descending order
    var sortedGameHistory: [GameHistory] {
        game.settings.playHistory.sorted {
            $0.datePlayed > $1.datePlayed
        }
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
            
            if !game.settings.playHistory.isEmpty {
                Section {
                    List {
                        ForEach(sortedGameHistory) { playHistory in
                            HStack {
                                VStack(alignment: .leading) {
                                    Button(playHistory.description) {
                                        UIPasteboard.general.string = playHistory.gameId
                                    }
                                    .foregroundStyle(.primary)
                                    
                                    Text("\(playHistory.datePlayed.formatted(date: .numeric, time: .shortened))")
                                        .font(.caption)
                                }
                                if playHistory.gameWon {
                                    Spacer()
                                    Image(systemName: "checkmark.circle.fill")
                                }
                                
                            }
                        }
                    }
                } header: {
                    Text("Play History")
                } footer: {
                    Text("Tap a game to copy its Game ID to the clipboard")
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
                    withAnimation {
                        game.settings.resetStatistics()
                    }
                }
                Button("Cancel", role: .cancel) {
                    showingClearStatsDialog = false
                }
            }
        .navigationTitle("\(game.gameConfig.name) Statistics")
        .navigationBarTitleDisplayMode(.inline)
        
    }
}
