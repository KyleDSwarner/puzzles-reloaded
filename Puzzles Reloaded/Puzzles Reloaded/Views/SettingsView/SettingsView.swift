//
//  SettingsView.swift
//  Puzzles
//
//  Created by Kyle Swarner on 2/26/24.
//  Copyright © 2024 Kyle Swarner. All rights reserved.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    
    // The settings page doesn't use the UserPreferences shared class to avoid an odd bug where the settings buttons didn't work correctly on first press
    @AppStorage(AppSettings.key) var appSettings: CodableWrapper<AppSettings> = AppSettings.initialStorage()
    @State private var gameSettingsMenu: [CustomMenuItem] = []
    
    // Game, to be provided when the settings menu is selected from within a game
    var game: Game? = nil
    var frontend: Frontend? = nil
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    if HapticEffects.deviceSupportsHaptics() {
                        Toggle("Enable Haptic Feedback", isOn: $appSettings.value.enableHaptics)
                    }
                    Toggle("Sounds", isOn: $appSettings.value.enableSounds)
                    
                }
                
                Section {
                    HStack {
                        Text("Long Press Duration")
                        Spacer()
                        Text("\(appSettings.value.longPressTime.formatted(.number.precision(.fractionLength(0))))ms")
                        //Text(Duration.milliseconds(appSettings.value.longPressTime.cle
                    }
                    Slider(value: $appSettings.value.longPressTime, in: 125...1000, step: 125) {
                        Text("Long Press Duration")
                    } minimumValueLabel: {
                        Text("125ms")
                    } maximumValueLabel: {
                        Text("1s")
                    }
                }
                
                Section {
                    Toggle("Disable Game Statusbars", isOn: $appSettings.value.disableGameStatusbar)
                } footer: {
                    Text("Disable game information that appears at the bottom of the screen")
                }
                
                if let game = game {
                    if !gameSettingsMenu.isEmpty {
                        Section {
                            CustomGameConfigView(gameMenu: $gameSettingsMenu)
                        } header: {
                            Text("\(game.gameConfig.name) Settings")
                        } footer: {
                            Text("Note: Some settings may not be applied until the next new game")
                        }
                    }
                    else {
                        Section {
                            Text("No settings available")
                        } header: {
                            Text("\(game.gameConfig.name) Settings")
                        }
                    }
                    /*
                    NavigationLink("Game Statistics") {
                        Text("Games Played: \(game.settings.stats.gamesPlayed)")
                        Text("Games Won: \(game.settings.stats.gamesWon)")
                        Text("Win Percentage: \(game.settings.stats.winPercentage)")
                        Text("Last Played: \(game.settings.stats.lastPlayed ?? Date.now)")
                    }
                    */
                }
                else { // About Game / Rate / Welcome message should only show up on the root settings page
                    Section {
                        NavigationLink("About Puzzles Reloaded") {
                            AboutView()
                        }
                        Toggle("Display First Run Message", isOn: $appSettings.value.showFirstRunMessage)
                        Button("Rate the App") {
                            requestReview()
                        }
                    }
                }
                
                /*
                 
                These sections are designed, but at the moment don't do anything
                 
                Section {
                    
                    Picker("Theme", selection: $appSettings.value.appTheme) {
                        Text("Auto (Follow Device)").tag(AppTheme.auto)
                        Text("Light").tag(AppTheme.light)
                        Text("Dark").tag(AppTheme.dark)
                    }
                    
                }
                Section {
                    Toggle("Experimental Games", isOn: $appSettings.value.showExperimentalGames)
                } footer: {
                    Text("Enable games that may be incomplete or broken")
                }
                 */
            }
            .navigationTitle("Settings")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        if frontend != nil {
                            print("Saving Game Settings")
                            _ = frontend?.midend.setGameUserSettings(choices: gameSettingsMenu)
                        }
                        dismiss()
                    } label: {
                        Text("Done")
                    }
                }
                
            }
            #endif
            .onAppear {
                if game != nil && frontend != nil {
                    let gameParams = frontend?.midend.getGameUserSettings()
                    
                    self.gameSettingsMenu = gameParams?.menu ?? []
                    
                    // Filter out puzzle settings that don't make sense for mobile devices
                    self.gameSettingsMenu = gameSettingsMenu.filter { setting in
                        !PuzzleConstants.settingExclusions.contains(setting.title)
                    }
                }
            }
        }
    }
    
    func requestReview() {
          let url = "https://apps.apple.com/app/id6504365885?action=write-review"
          guard let writeReviewURL = URL(string: url)
              else { fatalError("Expected a valid URL") }
          UIApplication.shared.open(writeReviewURL, options: [:], completionHandler: nil)
        }
}

#Preview {
    SettingsView()
}
