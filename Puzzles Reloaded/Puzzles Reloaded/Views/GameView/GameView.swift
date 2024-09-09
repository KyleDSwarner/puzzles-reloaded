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
    
    @State private var displayingGameMenu = false
    @State private var displayingGameTypeMenu = false
    @State private var displayNewGameButton = false
    @State private var displayRestartButton = false
    @State private var enableCompletionAnimation = false
    @State private var tapAnchor: CGPoint = .zero
    
    @State private var helpPageDisplayed = false
    @State private var settingsPageDisplayed = false
    @State private var customGameSettingsDisplayed = false
    
    @State private var scaleFactor: CGFloat = 1.0
    @State private var translation: CGSize = .zero
    @State private var currentGeometry: CGSize = .zero
    
    @FocusState private var imageIsFocused: Bool
    @State private var frontend: Frontend
    @State private var effectsManager = EffectsManager()
    @State private var gameWon = false // Gate that allows us to know if the game has been won (now or in the past)
    
    @State var puzzleImageTransformation: CGAffineTransform = .identity
    
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
    
    func cleanupAndBack() {
        
        saveUserData()
        
        // Remove our observer to terminate events
        //NotificationCenter.default.removeObserver(appTerminateObserver)
        
        dismiss()
    }
    
    func emitButtonPress(_ button: ButtonPress?) {
        effectsManager.triggerShortPressEffects()
        frontend.fireButton(button)
    }
    
    func newGame() {
        Task {
            await frontend.beginGame()
            self.game.settings.stats.updateStats_NewGame()
            self.gameWon = false
            self.puzzleImageTransformation = .identity
        }
    }
    
    func setNewGamePreset(_ preset: PresetMenuItem) {
        frontend.setNewGamePreset(preset.params)
        
        frontend.setPuzzlePreset(defaultPreset: preset)
        
        newGame()
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
                                .focused($imageIsFocused)
                            #if os(iOS)
                                .overlay {
                                    // MARK: Puzzle Interactions & Gestures
                                    PuzzleInteractionsView(transform: $puzzleImageTransformation, anchor: $tapAnchor, puzzleFrontend: frontend, allowSingleFingerPanning: game.gameConfig.allowSingleFingerPanning)
                                }
                            #endif
                                .transformEffect(puzzleImageTransformation)
                                // MARK: Keyboard Handling
                                .onKeyPress { key in                                    
                                    if key.key == .escape {
                                        self.cleanupAndBack()
                                        return .handled
                                    }
                                    
                                    return self.keyboardHandler?.handleKeypress(keypress: key) ?? KeyPress.Result.ignored
                                }
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
                                
                                .onChange(of: frontend.puzzleStatus) { old, new in
                                    if(new == .SOLVED) {
                                        //TODO: The affine transform is not animable, and I haven't found a way to animate completions while also keeping the navigation fluid.
                                        enableCompletionAnimation = true
                                        
                                        // Increment the game winning stats. `gameWon` gates this so it can only fire once per game.
                                        if gameWon == false {
                                            gameWon = true
                                            game.settings.stats.gameWon(gameId: frontend.gameId)
                                        }
                                        withAnimation(.easeInOut(duration: 0.5)) {
                                            puzzleImageTransformation = .identity
                                        }
                                    }
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
                        imageIsFocused = true
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
                VStack {
                    Spacer()
                    HStack {
                        if(frontend.gameHasStatusbar) {
                            Text(frontend.statusbarText)
                                .padding(5)
                                .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 5.0))
                        }
                        
                        if displayNewGameButton {
                            Button("New Game") {
                                Task {
                                    await frontend.beginGame()
                                }
                                
                            }
                            .padding(5)
                            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 5.0))
                            //.transition(AnyTransition.opacity.combined(with: .slide))
                        }
                        
                        if displayRestartButton {
                            Button("Restart") {
                                frontend.midend.restartGame()
                            }
                            .padding(5)
                            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 5.0))
                            //.transition(AnyTransition.opacity.combined(with: .slide))
                        }
                    }
                }
                .frame(height: currentGeometry.width < 600 ? 80 : 40) // <-- Keep a minimum height on this stack to prevent puzzle resizing when the new game button appears
                // MARK: New Game & Restart Button Popup Config
                .onChange(of: frontend.puzzleStatus) { old, new in
                    // When the game is solved, animate the appearance of the new game button
                    if(new == .SOLVED || new == .UNSOLVABLE) {
                        withAnimation(.smooth(duration: 0.5)) {
                            self.displayNewGameButton = true
                            
                            if new == .UNSOLVABLE {
                                self.displayRestartButton = true
                            }
                        }
                    }
                    else {
                        // New games shouldn't animate the disappearance
                        self.displayNewGameButton = false
                        self.displayRestartButton = false
                    }
                }
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
        .navigationBarBackButtonHidden(true)
        .background(Color("Puzzle Background"))

        //.toolbarBackground(Color(UIColor.red), for: .navigationBar)
        
        //.toolbarBackground(.visible, for: .navigationBar, .automatic, .bottomBar, .tabBar)
        
        //.toolbarBackground(Color.gray, for: .bottomBar)
        //.toolbarBackground(.visible, for: .bottomBar)
        // MARK: Help Page Sheet
        .sheet(isPresented: $helpPageDisplayed) {
            GameHelpView(game: game.gameConfig)
        }
        // MARK: Settings Page Sheet
        .sheet(isPresented: $settingsPageDisplayed) {
            SettingsView(game: game, frontend: frontend)
        }
        .sheet(isPresented: $customGameSettingsDisplayed) {
            GameCustomSettingsView(gameTitle: game.gameConfig.name, frontend: frontend, newGameCallback: newGame)
                .presentationDetents([.medium, .large])
        }
        
        // MARK: Toolbar
#if os(iOS)
        .toolbar {
            // MARK: Top Toolbar
            ToolbarItem(placement: .topBarLeading) {
                Button("Back") {
                    cleanupAndBack()
                }
            }
            ToolbarItemGroup(placement: .topBarTrailing) {
                Button {
                    helpPageDisplayed = true
                } label: {
                    Image(systemName: "questionmark.circle")
                }
                Button() {
                    settingsPageDisplayed = true
                } label: {
                    Image(systemName: "gearshape")
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
                        frontend.midend.restartGame()
                        self.puzzleImageTransformation = .identity
                        
                    } label: {
                        Label("Restart Game", systemImage: "arrow.circlepath")
                    }
                    .disabled(frontend.currentGameInvalidated)
                    
                    
                    // TODO: Implement these features!
                    /*
                    Button("Enter Game ID") { // Display Advanced Game Options?
                        
                    }
                    Button("New Game by Random Seed") {
                        
                    }
                     */
                    
                    // Display this section if we can auto-solve OR if the game has some overflow controls
                    if frontend.canSolve || !overflowMenuControls.isEmpty {
                        Section {
                            
                            ForEach(overflowMenuControls, id: \.id) { control in
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
                                Button("Auto-Solve") {
                                    frontend.midend.solvePuzzle()
                                }
                                .disabled(frontend.currentGameInvalidated)
                            }
                        }
                    }
                    
                    // Exit Button
                    Section {
                        Button() {
                            cleanupAndBack()
                        } label: {
                            Label("Back", systemImage: "chevron.backward")
                        }
                    }
                    
                }
                
                Spacer()
                
                if game.gameConfig.displayClearButtonInToolbar {
                    Button() {
                        effectsManager.triggerShortPressEffects()
                        frontend.fireButton(PuzzleKeycodes.ClearButton)
                    } label: {
                        Image(systemName: "square.slash")
                            .accessibilityLabel("Clear Selected Field")
                    }
                }
                
                Button() {
                    effectsManager.triggerShortPressEffects()
                    frontend.undoMove()
                } label: {
                    Image(systemName: "arrow.uturn.backward")
                        .accessibilityLabel("Undo previous move")
                }
                .disabled(!frontend.canUndo)
                
                Button() {
                    effectsManager.triggerShortPressEffects()
                    frontend.redoMove()
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
                    Button {
                        customGameSettingsDisplayed = true
                    } label: {
                        Label("Custom", systemImage: "chevron.right")
                    }
                } label: {
                    Image(systemName: "square.resize")
                        .accessibilityLabel("Game Size & Options")
                }
                .menuOrder(.fixed)
            }
        }
        #endif
        
        // MARK: On Appear: Configure Frontend & Start Game
        .onAppear {
            frontend.midend.createMidend(frontend: &frontend)
            imageIsFocused = true
            Task {
                let isLoadingFromSavedGame: Bool = game.settings.saveGame != nil
                await frontend.beginGame(isFirstLoad: true, withSaveGame: game.settings.saveGame, withPreferences: game.settings.userPrefs)
                
                // If there's no saved game, increment the 'games played' stat
                if isLoadingFromSavedGame == false {
                    self.game.settings.stats.updateStats_NewGame()
                }
            }
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
    
    func cancelGameGenerationAndRegernateMidend() {
        frontend.cancelNewGame()
        
        /*
         Cancelling a game in places tends to desync the internal state of the puzzle midend, causing assertion failues when the user creates another game.
         This recreates the midend from scratch to avoid these issues (and has the added benefit of resetting the custom game settings, which feels cleaner)
         */
        frontend.midend.createMidend(frontend: &frontend)
    }

    func saveUserData() {
        // Save Game
        let save = frontend.saveGame()
        
        if save != nil {
            print("Game Saved")
        } else {
            print("Game not saved: nothing to store")
        }
        // Save the game, or null it out if the game should not be saved
        game.settings.saveGame = save
        
        
        let prefs = frontend.midend.saveUserPrefs()
        if prefs != nil {
            print("User Preferences Received")
        } else {
            print("No user preferences to store")
        }
        game.settings.userPrefs = prefs
    }
    
    func updateLocation(_ location: CGPoint) {
        print(location)
    }
    
}

#Preview {
    NavigationStack {
        GameView(game: Game.exampleGameModel)
            .modelContainer(for: GameUserSettings.self, inMemory: true)
    }
}
