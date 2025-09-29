//
//  GameView-Toolbars.swift
//  Puzzles Reloaded
//
//  Created by Kyle Swarner on 8/12/25.
//  Copyright © 2025 Kyle Swarner. All rights reserved.
//

import SwiftUI

struct GameViewToolbars: ViewModifier {
    
    @AppStorage(AppSettings.key) var appSettings: CodableWrapper<AppSettings> = AppSettings.initialStorage()

    var frontend: Frontend
    var gameName: String
    var gameAdditionalMenuOptions: [ControlConfig]
    var displayClearButton: Bool
    
    var exitGame: () -> Void
    var newGame: () -> Void
    var restartGame: () -> Void
    var setNewGamePreset: (_: PresetMenuItem) -> Void
    var clearSelection: () -> Void
    var undoMove: () -> Void
    var redoMove: () -> Void
    var autosolvePuzzle: () -> Void
    var removePuzzleFocus: () -> Void
    
    func generateSavegameExport() -> SavegameExporter {
        
        return SavegameExporter() {
            frontend.midend.restartGame() // Restart the game to give users on shared games a clean slate.
            let savegame = frontend.saveGame()
            frontend.undoMove() // Undo the move so the restart is not persistent for the user.
            
            var filename = ""
            
            let currentPreset = frontend.currentPreset
            
            // Custom presets have an ID of -1, double check before grabbing the preset information
            if currentPreset >= 0, frontend.gamePresets.count >= currentPreset {
                let presetName = frontend.gamePresets[currentPreset].title
                
                filename = "\(gameName) - \(presetName)"
            } else {
                filename = "\(gameName) - Custom Game"
            }
            
            return (filename, savegame)
        }
    }
    
    @Binding var helpPageDisplayed: Bool
    @Binding var settingsPageDisplayed: Bool
    @Binding var displayingGameIdView: Bool
    @Binding var displayingCustomSeedView: Bool
    @Binding var customGameSettingsDisplayed: Bool
    
    func body(content: Content) -> some View {
        content
        // MARK: Toolbar
#if os(iOS) // This toolbar doesn't function on macOS targets
        .toolbar {
            // MARK: Top Toolbar
            if !appSettings.value.enableSwipeBack {
                // Add a separate back button when swipeBack is disabled.
                ToolbarItem(placement: .topBarLeading) {
                    Button("Back", systemImage: "chevron.backward") {
                        exitGame()
                    }
                }
            }
             
            
            ToolbarItemGroup(placement: .topBarTrailing) {
                //ShareLink(item: generateGameToExport())
                if appSettings.value.displayShareMenu {
                    ShareLink(items: [generateSavegameExport()]) { data in
                        SharePreview("\(gameName) Savegame", image: Image("PuzzlesReloaded-Icon-Light"))
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                            .accessibilityHint("Share current game with others")
                    }
                }
                if DebugFlags.EnableThemeDebugger {
                    Button {
                        appSettings.value.appTheme = appSettings.value.appTheme == .dark ? .light : .dark
                    } label: {
                        Image(systemName: "sun.min")
                    }
                }
                Button {
                    removePuzzleFocus()
                    helpPageDisplayed = true
                } label: {
                    Image(systemName: "questionmark.circle")
                        .accessibilityHint("Open the help page")
                }
                Button() {
                    removePuzzleFocus()
                    settingsPageDisplayed = true
                } label: {
                    Image(systemName: "gearshape")
                        .accessibilityHint("Open the settings menu for the current game")
                }
                
            }
            
            // MARK: Bottom Toolbar
            ToolbarItemGroup(placement: .bottomBar) {
                Menu("Open Game Menu", systemImage: "menucard") {
                    Button {
                        newGame()
                    } label: {
                        Label("New Game", systemImage: "plus.circle")
                    }
                    
                    Button() {
                        restartGame()
                    } label: {
                        Label("Restart Game", systemImage: "arrow.circlepath")
                    }
                    .disabled(frontend.currentGameInvalidated)
                    
                    if(appSettings.value.displayCustomLoadMenu) {
                        Menu("Load By...", systemImage: "folder") {
                            Button("Game ID") { // Display Advanced Game Options?
                                removePuzzleFocus()
                                displayingGameIdView = true
                            }
                            Button("Random Seed") {
                                removePuzzleFocus()
                                displayingCustomSeedView = true
                            }
                        }
                    }
                    
                    // Display this section if we can auto-solve OR if the game has some overflow controls
                    if frontend.canSolve || !gameAdditionalMenuOptions.isEmpty {
                        Section {
                            
                            ForEach(gameAdditionalMenuOptions, id: \.id) { control in
                                Button {
                                    frontend.fireButton(control.buttonCommand)
                                } label: {
                                    if !control.imageName.isEmpty {
                                        Label(control.label, systemImage: control.imageName)
                                    } else {
                                        Text(control.label)
                                    }
                                }
                                .disabled(frontend.currentGameInvalidated)
                            }
                            
                            if frontend.canSolve {
                                Button {
                                    autosolvePuzzle()
                                } label: {
                                    Label("Auto-Solve", systemImage: "wand.and.rays")
                                }
                                .disabled(frontend.currentGameInvalidated)
                            }
                        }
                    }
                    
                    // Exit Button
                    Section {
                        Button() {
                            exitGame()
                        } label: {
                            Label("Back", systemImage: "chevron.backward")
                        }
                    }
                    
                }
                
                Spacer()
                
                if displayClearButton {
                    Button() {
                        clearSelection()
                    } label: {
                        Image(systemName: "square.slash")
                            .accessibilityLabel("Clear Selected Field")
                    }
                }
                
                Button() {
                    undoMove()
                } label: {
                    Image(systemName: "arrow.uturn.backward")
                        .accessibilityLabel("Undo previous move")
                }
                .disabled(!frontend.canUndo)
                
                Button() {
                    redoMove()
                } label: {
                    Image(systemName: "arrow.uturn.forward")
                        .accessibilityLabel("Redo previous move")
                }
                .disabled(!frontend.canRedo)
                
                Spacer()
                
                
                // MARK: Game Presets Menu
                Menu() {
                    ForEach(frontend.gamePresetsPrimaryMenu) { preset in
                        Button() {
                            setNewGamePreset(preset)
                        } label: {
                            if preset.id == frontend.currentPreset {
                                Label(preset.title, systemImage: "checkmark.circle")
                            } else {
                                Text(preset.title)
                            }
                            
                        }
                    }
                    if !frontend.gamePresetsOverflowMenu.isEmpty {
                        Menu("More Options") {
                            ForEach(frontend.gamePresetsOverflowMenu) { preset in
                                Button() {
                                    setNewGamePreset(preset)
                                } label: {
                                    if preset.id == frontend.currentPreset {
                                        Label(preset.title, systemImage: "checkmark.circle")
                                    } else {
                                        Text(preset.title)
                                    }
                                    
                                }
                            }
                        }
                    }
                    
                    // Display custom game menu if the game allows
                    if frontend.midend.canConfigureGameParams() {
                        Button {
                            removePuzzleFocus()
                            customGameSettingsDisplayed = true
                        } label: {
                            Label("Custom", systemImage: "chevron.right")
                        }
                    }
                } label: {
                    Image(systemName: "square.resize")
                        .accessibilityLabel("Game Size & Options")
                }
                .menuOrder(.fixed)
            }
        }
        #endif
    }
}
