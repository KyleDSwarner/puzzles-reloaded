//
//  GameView.swift
//  Puzzles
//
//  Created by Kyle Swarner on 2/23/24.
//  Copyright © 2024 Kyle Swarner. All rights reserved.
//

import SwiftUI

struct GameView: View {
    @Environment(\.dismiss) var dismiss
    
    @State private var displayingGameMenu = false
    @State private var displayingGameTypeMenu = false
    @State private var displayNewGameButton = false
    @State private var displayRestartButton = false
    @State private var enableCompletionAnimation = false
    @State private var anchor: CGPoint = .zero
    
    @State private var helpPageDisplayed = false
    @State private var settingsPageDisplayed = false
    
    @State private var scaleFactor: CGFloat = 1.0
    @State private var translation: CGSize = .zero
    
    @State private var frontend = Frontend()
    
    @State var puzzleImageTransformation: CGAffineTransform = .identity
    
    var game: Game
    
    var touchControls: [ControlConfig] {
        game.game.touchControls
    }
    
    var overflowMenuControls: [ControlConfig] {
        game.game.overflowMenuControls.filter { control in
            control.displayCondition(frontend.gameId)
        }
    }
    
    init(game: Game) {
        

        
        self.game = game
        frontend.midend.setGame(game.game.internalGame) //lol
        
        if(!game.game.touchControls.isEmpty) {
            frontend.controlOption = game.game.touchControls.first!
        }
    }
    
    func cleanupAndBack() {
        
        saveUserData()
        
        // Remove our observer to terminate events
        //NotificationCenter.default.removeObserver(appTerminateObserver)
        
        dismiss()
    }
    
    func emitButtonPress(_ button: ButtonPress?) {
        frontend.fireButton(button)
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
                                .padding(5)
                                .overlay {
                                    // MARK: Puzzle Interactions & Gestures
                                    PuzzleInteractionsView(transform: $puzzleImageTransformation, anchor: $anchor, puzzleFrontend: frontend, limitToBounds: false, allowSingleFingerPanning: game.game.allowSingleFingerPanning, puzzleTilesize: frontend.puzzleTilesize, adjustTapsToTilesize: true) { point in // TODO: Adjust Taps from puzzle config
                                        print(point)
                                    }
                                    //GestureTransformView(transform: $transform)
                                }
                                .transformEffect(puzzleImageTransformation)
                                // Instead of using transformEffect, this setup emulates the translations that are initially applied by our CGAFfineTransform
                                // This way, we're able to apply animations!
                                //.modifier(ModdedPuzzleImage(translation: puzzleImageTransformation, anchor: anchor))
                                //.animation(.easeInOut(duration:1.0), value: puzzleImageTransformation)
                                //.modifier(TranslatedImage(translation: puzzleImageTransformation, anchor: anchor, enablePuzzleCompleteAnimation: enableCompletionAnimation))
                                .onChange(of: frontend.puzzleStatus) { old, new in
                                    if(new == .SOLVED) {
                                        //TODO: The affine transform is not animable, and I haven't found a way to animate completions while also keeping the navigation fluid.
                                        enableCompletionAnimation = true
                                        withAnimation(.easeInOut(duration: 0.5)) {
                                            puzzleImageTransformation = .identity
                                        }
                                    }
                                }
                                .frame(width: min(geometry.size.width, geometry.size.height)) //TODO: Maximum size for iPads? Limit these puzzles from getting too large initially
                                
                        }
                    }
                    .frame(width: geometry.size.width, height: geometry.size.height) // take up all available space to center puzzle on the screen
                    .onAppear {
                        print("Size of Picture Stack: w:\(geometry.size.width) h:\(geometry.size.height)")
                    }
                }
                
            }
            //.padding(20) Padding boundaries
            /*
            HStack {
                if let newdebug = frontend.imageManager?.debugImage {
                    Image(newdebug, scale: 1.0, label: Text("Puzzle View"))
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        
                }

            }
             */
            
            
            Spacer()
            
            // MARK: Statusbar & Button Popups
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
                            frontend.beginGame() // New Game Rename?
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
            .frame(height: 80) // <-- Keep a minimum height on this stack to prevent puzzle resizing when the new game button appears
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
            
            // MARK: Game Controls View
            HStack(alignment: .center) {
                GameControlsView(controlOption: $frontend.controlOption, touchControls: touchControls, buttonControls: game.game.buttonControls, numericButtonsFunction: game.game.numericButtonsBuilder, gameId: frontend.gameId, buttonPressFunction: emitButtonPress)
            }
            .padding(.bottom, 10)

            //.background(.thinMaterial, in: RoundedRectangle(cornerRadius: 5.0))
            //.background(Color.red)
            //.clipShape(RoundedRectangle(cornerRadius: 5.0 ))
            //.padding(.leading, 5)

        }
        .navigationTitle(game.game.name)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        //.toolbarBackground(Color(UIColor.red), for: .navigationBar)
        
        //.toolbarBackground(.visible, for: .navigationBar, .automatic, .bottomBar, .tabBar)
        
        //.toolbarBackground(Color.gray, for: .bottomBar)
        //.toolbarBackground(.visible, for: .bottomBar)
        // MARK: Help Page Sheet
        .sheet(isPresented: $helpPageDisplayed) {
            GameHelpView(game: game.game)
        }
        // MARK: Settings Page Sheet
        .sheet(isPresented: $settingsPageDisplayed) {
            SettingsView()
        }
        // MARK: Toolbar
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
                    Button("New Game") {
                        frontend.beginGame() // New Game Rename?
                        self.puzzleImageTransformation = .identity
                    }
                    Button() {
                        frontend.midend.restartGame()
                        self.puzzleImageTransformation = .identity
                        
                    } label: {
                        Label("Restart Game", systemImage: "arrow.circlepath")
                    }
                    
                    Button("Enter Game ID") { // Display Advanced Game Options?
                        
                    }
                    Button("New Game by Random Seed") {
                        
                    }
                    
                    // Display this section if we can auto-solve OR if the game has some overflow controls
                    if frontend.canSolve || !overflowMenuControls.isEmpty {
                        Section {
                            
                            ForEach(overflowMenuControls, id: \.id) { control in
                                Button {
                                    frontend.fireButton(control.buttonCommand)
                                } label: {
                                    Label(control.label, systemImage: control.imageName)
                                }
                            }
                            
                            if frontend.canSolve {
                                Button("Auto-Solve") {
                                    frontend.midend.solvePuzzle()
                                }
                            }
                        }
                    }
                    
                    Section {
                        Button() {
                            cleanupAndBack()
                        } label: {
                            Label("Back", systemImage: "chevron.backward")
                        }
                    }
                    
                }
                /*
                Button() {
                    displayingGameMenu = true
                } label: {
                    Image(systemName: "menucard")
                        .accessibilityLabel("Open Game Menu")
                }
                 */
                
                Spacer()
                
                if game.game.displayClearButtonInToolbar {
                    Button() {
                        frontend.fireButton(PuzzleKeycodes.ClearButton)
                    } label: {
                        Image(systemName: "square.slash")
                            .accessibilityLabel("Clear Selected Field")
                    }
                }
                Button() {
                    frontend.undoMove()
                } label: {
                    Image(systemName: "arrow.uturn.backward")
                        .accessibilityLabel("Undo previous move")
                }
                .disabled(!frontend.canUndo)
                
                Button() {
                    frontend.redoMove()
                } label: {
                    Image(systemName: "arrow.uturn.forward")
                        .accessibilityLabel("Redo previous move")
                }
                .disabled(!frontend.canRedo)
                
                Spacer()
                
                
                // MARK: Game Presets Menu
                Menu() {
                    ForEach(frontend.gamePresets) { preset in
                        Button() {
                            frontend.setNewGamePreset(preset.params)
                        } label: {
                            if preset.id == frontend.currentPreset {
                                Label(preset.title, systemImage: "checkmark.circle")
                            } else {
                                Text(preset.title)
                            }
                            
                        }
                    }
                    Button {
                        frontend.midend.getCustomGameSettingsMenu()
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
        
        // MARK: On Appear: Configure Frontend & Start Game
        .onAppear {
            //testBed()
            //let drawingapi = DrawingAPI()
            /*
            appTerminateObserver = NotificationCenter.default.addObserver(forName: UIApplication.willResignActiveNotification, object: nil, queue: .main) { _ in
                print("Shutting down app, saving user data")
                self.saveUserData()
            }
             */
            
            frontend.midend.createMidend(frontend: &frontend) // TODO: This feels weird
            frontend.beginGame(withSaveGame: game.settings.saveGame, withPreferences: game.settings.userPrefs)
        }
        // MARK: Background & App Terminate notifications
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification), perform: { output in
                print("Backgrounding app; Saving Data")
                saveUserData()
            })
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willTerminateNotification), perform: { output in
            // Note: This very rarely actually fires once the app is backgrounded - but the above backgrounding implemementation should handle most all use cases
                print("Shutting down app; Saving Data")
                saveUserData()
            })
    }

    func saveUserData() {
        // Save Game
        let save = frontend.saveGame()
        
        if save != nil {
            print("Saving Game:")
        } else {
            print("No game in progress, not saving state")
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
    GameView(game: Game.exampleGameModel)
        .modelContainer(for: GameListConfig.self, inMemory: true)
}
