//
//  GlobalStatsView.swift
//  Puzzles Reloaded
//
//  Created by Kyle Swarner on 11/21/24.
//  Copyright © 2024 Kyle Swarner. All rights reserved.
//

import SwiftUI

struct GlobalStatsView: View {
    // Game, to be provided when the settings menu is selected from within a game
    
    @State private var showingClearStatsDialog = false
    @State private var displayPerGameSection = true
    
    @AppStorage(AppSettings.key) var appSettings: CodableWrapper<AppSettings> = AppSettings.initialStorage()
    @Environment(GameManager.self) var gameManager: GameManager
    
    var totalGamesPlayed: Int {
        gameManager.gameModel.reduce(0, { result, game in
            result + game.settings.stats.gamesPlayed
        })
    }
    
    var totalGamesWon: Int {
        gameManager.gameModel.reduce(0, { result, game in
            result + game.settings.stats.gamesWon
        })
    }
    
    var totalWinPercentage: Double {
        guard totalGamesPlayed > 0 else { return 0 }
        return Double(totalGamesWon) / Double(totalGamesPlayed)
    }
    
    var formattedWinPercentage: String? {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .percent

        // Using significant digits
        numberFormatter.usesSignificantDigits = false
        numberFormatter.maximumFractionDigits = 2
        
        return numberFormatter.string(from: totalWinPercentage as NSNumber)
    }
    
    var mostPlayedGame: Game? {
        gameManager.gameModel.sorted(by: { $0.settings.stats.gamesPlayed > $1.settings.stats.gamesPlayed }).first
    }
    
    var gamesWithAtLeastOnePlay: [Game] {
        gameManager.gameModel.filter({$0.settings.stats.gamesPlayed > 0})
    }
    
    var gamesSortedByPlays: [Game] {
        gamesWithAtLeastOnePlay.sorted(by: { $0.settings.stats.gamesPlayed > $1.settings.stats.gamesPlayed })
    }
    
    var body: some View {
        Form {
            Section {
                HStack {
                    Text("Total Games Played")
                    Spacer()
                    Text("\(totalGamesPlayed)")
                }
                
                HStack {
                    Text("Total Games Won")
                    Spacer()
                    Text("\(totalGamesWon)")
                }
                
                if let formattedWinPercentage = formattedWinPercentage {
                    HStack {
                        Text("Win Percentage")
                        Spacer()
                        Text(formattedWinPercentage)
                    }
                }
                
            }
            
            if totalGamesPlayed > 0 {
                Section {
                    List {
                        ForEach(gamesSortedByPlays) { game in
                            NavigationLink {
                                GameStatsView(game: game)
                            } label: {
                                HStack {
                                    Text(game.gameConfig.name)
                                    Spacer()
                                    Text("\(game.settings.stats.gamesPlayed) Games")
                                }
                            }
                        }
                    }
                } header: {
                    Text("Most Frequently Played")
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
            "Clear All Game Statistics?",
            isPresented: $showingClearStatsDialog
        ) {
                Button("Reset Statistics", role: .destructive) {
                    resetGameStatistics()
                }
                Button("Cancel", role: .cancel) {
                    showingClearStatsDialog = false
                }
            }
        .navigationTitle("Statistics")
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: totalGamesPlayed) { old, new in
            print("ON CHANGE: \(new)")
        }
    }
    
    func resetGameStatistics() {
        gameManager.gameModel.forEach { game in
            withAnimation {
                game.settings.stats.resetStats()
            }
        }
    }
}

#Preview {
    GlobalStatsView()
}
