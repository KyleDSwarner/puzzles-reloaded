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
    var refreshSettingsCallback: (() -> Void)?
    
    /**
     Determines if there are any game-specific settings to display
     */
    var displayGameSettingsMenu: Bool {
        !gameSettingsMenu.isEmpty || game?.gameConfig.allowSingleFingerPanning == true
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    if HapticEffects.deviceSupportsHaptics() {
                        Toggle("Enable Haptic Feedback", isOn: $appSettings.value.enableHaptics)
                    }
                    Toggle("Sounds", isOn: $appSettings.value.enableSounds)
                    
                }
                
                NavigationLink("Controls") {
                    Form {
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
                            Toggle("Swipe to Exit Game", isOn: $appSettings.value.enableSwipeBack)
                        } footer: {
                            Text("Enable swiping back to exit puzzles. Use with caution: very likely to interfere with interactions in some games!")
                        }
                        
                        Section {
                            Toggle("Mouse Secondary Click", isOn: $appSettings.value.enableRightClick)
                        } footer: {
                            Text("Controls if secondary/right clicks from a mouse or trackpad acts as a shortcut for long press actions.")
                        }
                        
                        Section {
                            
                            Toggle("Enable Physical Keyboard", isOn: $appSettings.value.enableHardwareKeyboard)
                            if appSettings.value.enableHardwareKeyboard {
                                NavigationLink("View Keyboard Shortcuts") { KeyboardCommandsView() }
                            }
                        } footer: {
                            Text("Toggle whether or not you want inputs from physical keyboards to control the game.")
                        }
                
                    }
                    .navigationTitle("Controls")
                    .navigationBarTitleDisplayMode(.inline)
                }
                
                NavigationLink("Appearance") {
                    Form {
                        
                        if FeatureFlags.EnableDarkTheme {
                            Section {
                                Picker("Puzzle Theme", selection: $appSettings.value.appTheme) {
                                    Text("Auto").tag(AppTheme.auto)
                                    Text("Light").tag(AppTheme.light)
                                    Text("Dark").tag(AppTheme.dark)
                                }
                            } footer: {
                            Text("Dark mode is a new feature and may have some quirks. Please reach out with any issues!")
                            }
                        }
                        
                        Section {
                            Toggle("Disable Game Statusbars", isOn: $appSettings.value.disableGameStatusbar)
                        } footer: {
                            Text("Disable game information that appears at the bottom of the screen")
                        }
                        
                        Section {
                            Toggle("Display Game ID & Seed Menus", isOn: $appSettings.value.displayCustomLoadMenu)
                        } footer: {
                            Text("Enables the display of menu to load game menus by specific game IDs and seeds.")
                        }
                        
                        Section {
                            Toggle("Display Share Menu", isOn: $appSettings.value.displayShareMenu)
                        } footer: {
                            Text("Enables the display of the share button within game options.")
                        }
                        
                        if FeatureFlags.EnableExperiementalGamesDisplay {
                            Section {
                                Toggle("Show Experimental Games", isOn: $appSettings.value.showExperimentalGames)
                            } footer: {
                                Text("Add games marked as experimental to the games list. These are newer games to the collection that may some some usability or performance issues. Feel free to report any issues to help improve these games!")
                            }
                            
                        }
                        
                        
                    }
                    .navigationTitle("Appearance")
                    .navigationBarTitleDisplayMode(.inline)
                }
                
                // MARK: In-Game Settings
                if let game = game {
                    
                    if displayGameSettingsMenu {
                        Section {
                            if game.gameConfig.allowSingleFingerPanning {
                                let singleFingerNavBinding = Binding<Bool>(get: { game.settings.singleFingerPanningEnabled}, set: {
                                    game.settings.singleFingerPanningEnabled = $0
                                    if let refreshSettingsCallback = refreshSettingsCallback {
                                        refreshSettingsCallback() // Function callback triggers a refresh of settings back on the main game page
                                    }
                                })
                                Toggle("Single finger scrolling", isOn: singleFingerNavBinding)
                            }
                            
                            if !gameSettingsMenu.isEmpty {
                                CustomGameConfigView(gameMenu: $gameSettingsMenu)
                            }
                            
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
                    
                    NavigationLink("Game Statistics") {
                        GameStatsView(game: game)
                    }
                    
                    NavigationLink("View Game Parameters") {
                        Form {
                            Section {
                                if let seed = frontend?.midend.getGameSeed() {
                                    if !seed.isEmpty {
                                        HStack {
                                            VStack(alignment: .leading) {
                                                Text("Random Seed")
                                                    .foregroundStyle(.secondary)
                                                    .font(.caption)
                                                    //.padding([.bottom], 5)
                                                Button(seed) {
                                                    print("Copied Game Seed to clipboard")
                                                    UIPasteboard.general.string = seed
                                                }
                                                .foregroundStyle(.primary)
                                                    
                                            }
                                        }
                                    }
                                }
                                
                                if let gameId = frontend?.gameId {
                                    if !gameId.isEmpty {
                                        HStack {
                                            VStack(alignment: .leading) {
                                                Text("Game ID")
                                                    .foregroundStyle(.secondary)
                                                    .font(.caption)
                                                    //.padding([.bottom], 5)
                                                Button(gameId) {
                                                    print("Copied game ID to clipboard")
                                                    UIPasteboard.general.string = gameId
                                                }
                                                .foregroundStyle(.primary)
                                                    
                                            }
                                        }
                                    }
                                }
                                
                                
                            } footer: {
                                Text("These values were used to generate the current puzzle. Tap these sections to copy them to your clipboard.")
                            }
                        }
                        .navigationTitle("Game Parameters")
                        .navigationBarTitleDisplayMode(.inline)
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
                // MARK: Global Settings Bottom Options
                else { // Stats / About Game / Rate / Welcome message should only show up on the root settings page
                    Section {
                        NavigationLink("Statistics") {
                            GlobalStatsView()
                        }
                    }
                    
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

struct KeyboardCommandsView: View {
    
    var body: some View {
        List {
            Section {
                HStack(alignment: .center) {
                    Text("New Game")
                        .bold()
                    Spacer()
                    Text("N, Ctrl+N")
                }
                HStack(alignment: .center) {
                    Text("Solve Puzzle")
                        .bold()
                    Spacer()
                    Text("S, Ctrl+S")
                }
                HStack(alignment: .center) {
                    Text("Undo")
                        .bold()
                    Spacer()
                    Text("U, Ctrl+Z, Ctrl+_, *")
                }
                HStack(alignment: .center) {
                    Text("Redo")
                        .bold()
                    Spacer()
                    Text("R, Ctrl+R, #")
                }
                HStack(alignment: .center) {
                    Text("Clear Square")
                        .bold()
                    Spacer()
                    Text("Backspace, Delete")
                }
                HStack(alignment: .center) {
                    Text("Exit Game")
                        .bold()
                    Spacer()
                    Text("Escape")
                }
            }
            
            Section {
                HStack(alignment: .center) {
                    Text("Marks")
                        .bold()
                    Spacer()
                    Text("M")
                }
                HStack(alignment: .center) {
                    Text("Hint")
                        .bold()
                    Spacer()
                    Text("H")
                }
            } header: {
                Text("Supported By Some Puzzles")
            }
        }.navigationTitle("Keyboard Commands")
    }
}

#Preview {
    return SettingsView()
}
