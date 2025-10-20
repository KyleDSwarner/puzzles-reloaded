//
//  GameView.swift
//  Puzzles
//
//  Created by Kyle Swarner on 2/23/24.
//  Copyright © 2024 Kyle Swarner. All rights reserved.
//

import SwiftUI

struct GameView: View {
    
    @AppStorage(AppSettings.key) var appSettings: CodableWrapper<AppSettings> = AppSettings.initialStorage()
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    
    @State private var displayingGameMenu = false
    @State private var displayingGameTypeMenu = false

    @State private var enableCompletionAnimation = false
    @State private var tapAnchor: CGPoint = .zero
    
    @State private var helpPageDisplayed = false
    @State private var settingsPageDisplayed = false
    @State private var customGameSettingsDisplayed = false
    @State private var displayingGameIdView = false
    @State private var displayingCustomSeedView = false
    
    @State private var scaleFactor: CGFloat = 1.0
    @State private var translation: CGSize = .zero
    @State private var currentGeometry: CGSize = .zero
    
    @FocusState private var imageIsFocused: Bool
    @State private var frontend: Frontend
    @State private var effectsManager = EffectsManager()
    
    @State private var undoUsed = false
    @State private var gameAutosolved = false
    @State private var gameLoggedToStats = false // Gate allows us to only allows gameStarted stats once for each game
    @State private var gameWon = false // Gate that allows us to know if the game has been won (now or in the past)
    
    @State var puzzleImageTransformation: CGAffineTransform = .identity
    
    @State private var singleFingerScrolling: Bool = false
    
    var game: Game
    private var keyboardHandler: KeyboardInputHandler?
    
    var touchControls: [ControlConfig] {
        game.gameConfig.touchControls
    }
    
    var overflowMenuControls: [ControlConfig] {
        game.gameConfig.overflowMenuControls.filter { control in
            control.displayCondition(frontend.gameId)
        }
    }
    
    init(game: Game) {
        self.game = game
        frontend = Frontend(game: game)
        self.keyboardHandler = KeyboardInputHandler(frontend: frontend)
        //var keyboardHandler = KeyboardInputHandler(frontend: frontend)
        frontend.midend.setGame(game.gameConfig.internalGame)
        
        if(!game.gameConfig.touchControls.isEmpty) {
            frontend.controlOption = game.gameConfig.touchControls.first!
        }
    }
    
    func exitGame() {
        imageIsFocused = false // Release focus to prevent any navigation issues down the line
        dismiss()
    }
    
    func emitButtonPress(_ button: ButtonPress?) {
        effectsManager.triggerShortPressEffects()
        frontend.fireButton(button)
    }
    
    // First Load function, run after the view is loaded & first appears.
    func gameFirstLoad() {
        setColorTheme()
        frontend.midend.createMidend(frontend: &frontend)
        imageIsFocused = true
        
        
        // Update the single finger scrolling value
        singleFingerScrolling = game.settings.singleFingerPanningEnabled
        
        Task {
            let saveGame: String? = game.settings.saveGame
            let isLoadingFromSavedGame: Bool = saveGame != nil
            
            if isLoadingFromSavedGame {
                // Games that are being loaded should not be logged to stats again - set the flag to true to disable future checks.
                self.gameLoggedToStats = true
                
                // Intentionally clear out the existing save as we're loading
                // This hellp prevent any errors that arise from malformed saves from reoccurring
                game.settings.saveGame = nil
            }
            
            await frontend.beginGame(isFirstLoad: true, withSaveGame: saveGame, withPreferences: game.settings.userPrefs)
        }
    }
    
    /**
     Set the theme to dark if the dark theme is explicitly selected, or if the user's device theme is dark mode & the theme is set to automatic.
     */
    func setColorTheme() {
        frontend.useDarkTheme = FeatureFlags.EnableDarkTheme == true && (
            appSettings.value.appTheme == .dark
            || (colorScheme == .dark && appSettings.value.appTheme == .auto))
    }
    
    func newGame() {
        Task {
            self.gameLoggedToStats = false
            self.gameAutosolved = false
            self.undoUsed = false
            
            frontend.stopAnimationTimer()
            await frontend.beginGame()
            
            self.gameWon = false
            self.puzzleImageTransformation = .identity
        }
    }
    
    func restartGame() {
        frontend.midend.restartGame()
        self.puzzleImageTransformation = .identity
    }
    
    func setNewGamePreset(_ preset: PresetMenuItem) {
        frontend.setNewGamePreset(preset.params)
        
        frontend.setPuzzlePreset(defaultPreset: preset)
        
        newGame()
    }
    
    func undoMove() {
        effectsManager.triggerShortPressEffects()
        frontend.undoMove()
    }
    
    func redoMove() {
        effectsManager.triggerShortPressEffects()
        frontend.redoMove()
    }
    
    func clearPuzzleSelection() {
        effectsManager.triggerShortPressEffects()
        frontend.fireButton(PuzzleKeycodes.ClearButton)
    }
    
    var body: some View {
        VStack {            
            GeometryReader { geometry in
                ZStack {
                    VStack {
                        if let puzzleImage = frontend.puzzleImage {
                            Image(puzzleImage, scale: 1.0, label: Text("Puzzle View"))
                                .resizable()
                                .antialiased(true)
                                .interpolation(.high)
                                .scaledToFit()
                                .focusable()
                                .focused($imageIsFocused) // Check keyboard entry on other pages
                                .focusEffectDisabled()
                            #if os(iOS)
                                .overlay {
                                    // MARK: Puzzle Interactions & Gestures
                                    PuzzleInteractionsView(transform: $puzzleImageTransformation, anchor: $tapAnchor, puzzleFrontend: frontend, allowSingleFingerPanning: singleFingerScrolling)
                                }
                            #endif
                                .transformEffect(puzzleImageTransformation)
                                // MARK: Keyboard Handling
                                
                                // Instead of using transformEffect, this setup emulates the translations that are initially applied by our CGAFfineTransform
                                // This way, we're able to apply animations!
                                //.modifier(ModdedPuzzleImage(translation: puzzleImageTransformation, anchor: anchor))
                                //.animation(.easeInOut(duration:1.0), value: puzzleImageTransformation)
                                //.modifier(TranslatedImage(translation: puzzleImageTransformation, anchor: anchor, enablePuzzleCompleteAnimation: enableCompletionAnimation))
                                /* Available on iOS 17.5. Don't enable quite yet.
                                .onPencilDoubleTap { gesture in
                                        print("Double Tap on Pencil!!")
                                }
                                 */
                                
                                .onChange(of: frontend.puzzleStatus) { _, new in
                                    if(new == .SOLVED) {
                                        //TODO: The affine transform is not animable, and I haven't found a way to animate completions while also keeping the navigation fluid.
                                        enableCompletionAnimation = true
                                        
                                        // Increment the game winning stats. `gameWon` gates this so it can only fire once per game.
                                        // We also don't mark this as won if the autosolver was used.
                                        // MARK: Set game as WON
                                        if gameWon == false && gameAutosolved == false {
                                            gameWon = true
                                            game.settings.updateStatsForWonGame(gameId: frontend.gameId)
                                            // game.settings.stats.gameWon(gameId: frontend.gameId)
                                        }
                                        withAnimation(.easeInOut(duration: 0.5)) {
                                            puzzleImageTransformation = .identity
                                        }
                                    }
                                }
                                // MARK: Theme Change: Redraw current puzzle
                                .onChange(of: appSettings.value.appTheme) {
                                    print("!!!!!!!! Hey, the theme changed!")
                                    setColorTheme()
                                    frontend.midend.redrawPuzzle(frontend: frontend) // Redraw the puzzle using the new theme settings
                                }

                                .blur(radius: frontend.currentGameInvalidated ? 5 : 0)
                                .frame(width: min(geometry.size.width, 800), height: min(geometry.size.height, 800))
                                //.frame(width: min(geometry.size.width, 600), height: min(geometry.size.height, 600)) // 600px set as maximum default size: This limits puzzles from getting too large on ipads
                            
                                
                        }
                        
                    }
                    .frame(width: geometry.size.width, height: geometry.size.height) // take up all available space to center puzzle on the screen
                    .onChange(of: geometry.size) {
                        // print("width: \(geometry.size.width), height: \(geometry.size.height)")
                        currentGeometry = geometry.size
                    }
                    .onChange(of: frontend.puzzleImage) {
                        // There have been enough bugs where the image finishes drawing, but an update is never called and the undo/redo status doesn't properly reflect the internal state.
                        frontend.updateFrontendFlags()
                    }
                    
                    if frontend.displayLoadingScreen {
                        VStack {
                            VStack {
                                
                                Text("Generating Puzzle").font(.headline)
                                Text("This may take a long time for complex puzzles").font(.subheadline)
                                ProgressView()
                                Button("Cancel") {
                                    
                                    cancelGameGenerationAndRegernateMidend()
                                    
                                    // On the assumption that long-running generation should only ever occur when the user chose difficult custom settings,
                                    // Open the custom game settings menu.
                                    customGameSettingsDisplayed = true
                                }
                                .buttonStyle(.bordered)
                                .padding(10)
                            }
                            .padding(10)
                            .background(.thinMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 5))
                        }
                        .frame(width: geometry.size.width, height: geometry.size.height) // take up all available space to center puzzle on the screen
                    }
                }
                
            }
            
            Spacer()
            
            // MARK: Statusbar & Button Popups
            if(!appSettings.value.disableGameStatusbar) {
                GameViewStatusbar(frontend: frontend, newGame: newGame, restartGame: restartGame, currentGeometry: currentGeometry)
            }
            
            // MARK: Game Controls View
            HStack(alignment: .center) {
                GameControlsView(controlOption: $frontend.controlOption, touchControls: touchControls, buttonControls: game.gameConfig.buttonControls, numericButtonsFunction: game.gameConfig.numericButtonsBuilder, gameId: frontend.gameId, buttonPressFunction: emitButtonPress)
            }
            .padding(.bottom, 10)

            //.background(.thinMaterial, in: RoundedRectangle(cornerRadius: 5.0))
            //.background(Color.red)
            //.clipShape(RoundedRectangle(cornerRadius: 5.0 ))
            //.padding(.leading, 5)

        }
        
        .navigationTitle(game.gameConfig.name)
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .navigationBarBackButtonHidden(!appSettings.value.enableSwipeBack)
        .background(Color("Puzzle Background"))
        
        // MARK: Keybaord Handling
        .onKeyPress { key in
            if(appSettings.value.enableHardwareKeyboard == false) {
                print("Ignoring Keypress based on user setting")
                return .ignored
            }
            
            if key.key == .escape {
                self.exitGame()
                return .handled
            }
            
            return self.keyboardHandler?.handleKeypress(keypress: key) ?? KeyPress.Result.ignored
        }

        //.toolbarBackground(Color(UIColor.red), for: .navigationBar)
        
        //.toolbarBackground(.visible, for: .navigationBar, .automatic, .bottomBar, .tabBar)
        
        //.toolbarBackground(Color.gray, for: .bottomBar)
        //.toolbarBackground(.visible, for: .bottomBar)
        // MARK: Help Page Sheet
        .sheet(isPresented: $helpPageDisplayed, onDismiss: reapplyFocusToPuzzleImage) {
            GameHelpView(game: game.gameConfig)
        }
        // MARK: Game ID Sheet
        .sheet(isPresented: $displayingGameIdView, onDismiss: reapplyFocusToPuzzleImage) {
            CustomGameIDView(frontend: frontend, newGameCallback: newGame)
        }
        // MARK: Custom Seed Sheet
        .sheet(isPresented: $displayingCustomSeedView, onDismiss: reapplyFocusToPuzzleImage) {
            CustomGameSeedView(frontend: frontend, newGameCallback: newGame)
        }
        // MARK: Settings Page Sheet
        .sheet(isPresented: $settingsPageDisplayed, onDismiss: reapplyFocusToPuzzleImage) {
            SettingsView(game: game, frontend: frontend, refreshSettingsCallback: refreshSettings)
        }
        .sheet(isPresented: $customGameSettingsDisplayed, onDismiss: reapplyFocusToPuzzleImage) {
            GameCustomSettingsView(gameTitle: game.gameConfig.name, frontend: frontend, newGameCallback: newGame)
               //  .presentationDetents([.medium, .large]) (Not rendering correctly on iPads)
        }
        // MARK: Toolbar View
        .modifier(GameViewToolbars(
            frontend: frontend,
            gameName: game.gameConfig.name,
            gameAdditionalMenuOptions: overflowMenuControls,
            displayClearButton: game.gameConfig.displayClearButtonInToolbar,
            exitGame: exitGame,
            newGame: newGame,
            restartGame: restartGame,
            setNewGamePreset: setNewGamePreset,
            clearSelection: clearPuzzleSelection,
            undoMove: undoMove,
            redoMove: redoMove,
            autosolvePuzzle: triggerAutosolver,
            removePuzzleFocus: removeImageFocus,
            helpPageDisplayed: $helpPageDisplayed,
            settingsPageDisplayed: $settingsPageDisplayed,
            displayingGameIdView: $displayingGameIdView,
            displayingCustomSeedView: $displayingCustomSeedView,
            customGameSettingsDisplayed: $customGameSettingsDisplayed))
        
        // MARK: On Appear: Configure Frontend & Start Game
        .onAppear {
            gameFirstLoad()
        }
        // MARK: On Disappear: Save data when leaving
        .onDisappear {
            saveUserData()
        }
        // MARK: Update New Game Statistics On First Move
        .onChange(of: frontend.movesTakenInGame) { old, newValue in
            // The game ID and other information will have also resolved at this point.
            
            // If we haven't already logged the game to stats & the new value is `true`, then log the game to user statistics.
            if gameLoggedToStats == false && newValue == true {
                print("!!! Game Started! New Game ID: \(frontend.gameId)")
                
                self.game.settings.updateStatsForNewGame(gameId: frontend.gameId, gameDescription: getCurrentGameDescription())
            }
            /*
            self.game.settings.stats.updateStats_NewGame(
                gameId: frontend.gameId,
                gameDescription: getCurrentGameDescription())
             */
        }
        // MARK: Single Finger Navigation Sync
        .onChange(of: singleFingerScrolling) {
            // Syncronize the finger panning settings to the model
            game.settings.singleFingerPanningEnabled = singleFingerScrolling
        }
        // MARK: Background & App Terminate notifications
        #if os(iOS)
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification), perform: { output in
                print("Backgrounding app; Saving Data")
                saveUserData()
            })
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willTerminateNotification), perform: { output in
            // Note: This very rarely actually fires once the app is backgrounded - but the above backgrounding implemementation should handle most all use cases
                print("Shutting down app; Saving Data")
                saveUserData()
            })
        #endif
    }
    
    /**
        Refresh settings that are represented as Bindings to other objects & trigger proper view resets.
            Fired as a callback from Settings View
     */
    func refreshSettings() {
        singleFingerScrolling = game.settings.singleFingerPanningEnabled
    }
    
    func cancelGameGenerationAndRegernateMidend() {
        frontend.cancelNewGame()
        
        /*
         Cancelling a game in places tends to desync the internal state of the puzzle midend, causing assertion failues when the user creates another game.
         This recreates the midend from scratch to avoid these issues (and has the added benefit of resetting the custom game settings, which feels cleaner)
         */
        frontend.midend.createMidend(frontend: &frontend)
    }
    
    func getCurrentGameDescription() -> String {
        let gameDescription = frontend.gamePresets.first(where: { $0.id == frontend.currentPreset})?.title
        
        if let gameDescription = gameDescription {
            return gameDescription
        }
        else {
            // Custom Game Preset??
            // TODO: Better titles for custom games, and the ability to name your own games.
            return "Custom Game"
        }
    }

    func saveUserData() {
        // Save Game
        let save = frontend.saveGameIfMovesTaken()
        
        if save != nil {
            print("Game Saved")
        } else {
            print("Game not saved: nothing to store")
        }
        // Save the game, or null it out if the game should not be saved
        game.settings.saveGame = save?.saveToString()
        
        
        let prefs = frontend.midend.saveUserPrefs()
        if prefs != nil {
            print("User Preferences Received")
        } else {
            print("No user preferences to store")
        }
        game.settings.userPrefs = prefs
    }
    
    func triggerAutosolver() {
        print("!!! Puzzle Autosolver used")
        self.gameAutosolved = true
        frontend.midend.solvePuzzle()
    }
    
    func removeImageFocus() {
        print("Removing focus from puzzle image")
        imageIsFocused = false
    }
    
    func reapplyFocusToPuzzleImage() {
        print("Reapplying focus to the puzzle image")
        imageIsFocused = true
    }
    
}

#Preview {
    NavigationStack {
        GameView(game: Game.exampleGameModel)
            .modelContainer(for: GameUserSettings.self, inMemory: true)
    }
}
