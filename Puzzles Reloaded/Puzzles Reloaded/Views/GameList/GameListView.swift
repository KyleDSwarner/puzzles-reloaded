//
//  GameListView.swift
//  Puzzles
//
//  Created by Kyle Swarner on 2/23/24.
//  Copyright © 2024 Kyle Swarner. All rights reserved.
//

import SwiftUI
import SwiftData

struct GameListView: View {
    
    @Environment(\.modelContext) private var modelContext
    @Environment(GameManager.self) var gameManager: GameManager
    @AppStorage(AppSettings.key) var appSettings: CodableWrapper<AppSettings> = AppSettings.initialStorage()
    
    @State private var navPath = NavigationPath()
    @State private var isHiddenSectionExpanded = false
    @State private var settingsPageDisplayed = false
    @State private var welcomeMessageDisplayed = false
    @State private var showingSavegameFailAlert = false
    
    
    let columns = [
        GridItem(.adaptive(minimum: 80), alignment: .top)
    ]
    
    var favoriteGames: [Game] {
        gameManager.filterGameList(category: .favorite, showExperimentalGames: appSettings.value.showExperimentalGames)
    }
    
    var allGames: [Game] {
        gameManager.filterGameList(category: .none, showExperimentalGames: appSettings.value.showExperimentalGames)
    }
    
    var hiddenGames: [Game] {
        gameManager.filterGameList(category: .hidden, showExperimentalGames: appSettings.value.showExperimentalGames)
    }
    
    init() {
        configureToolbarDisplay()
    }
    
    // MARK: Toolbar Design Configuration
    func configureToolbarDisplay() {
        #if os(iOS)
            let navbarAppearance = UINavigationBarAppearance()
            navbarAppearance.backgroundEffect = UIBlurEffect(style: .systemUltraThinMaterialDark)
            navbarAppearance.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.7)
            //navbarAppearance.backgroundColor = UIColor.r
            
            let toolbarAppearance = UIToolbarAppearance()
            toolbarAppearance.backgroundEffect = UIBlurEffect(style: .systemUltraThinMaterialDark)
            toolbarAppearance.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.7)
            
            //UIToolbar.appearance().standardAppearance = coloredAppearance
            
            UIToolbar.appearance().standardAppearance = toolbarAppearance
            UIToolbar.appearance().compactAppearance = toolbarAppearance
            UIToolbar.appearance().scrollEdgeAppearance = toolbarAppearance
            
            
            UINavigationBar.appearance().standardAppearance = navbarAppearance
            UINavigationBar.appearance().compactAppearance = navbarAppearance
            UINavigationBar.appearance().scrollEdgeAppearance = navbarAppearance
        #endif
        
        //UINavigationBar.appearance().tintColor = .white
    }
    
    func identifyAndOpenGame(savegame: SaveContext) -> Bool {
        guard let gameName = GameIdentifier.identifyGame(savegame) else {
            return false
        }
        
        print("Game Identified: \(gameName)")
        
        if let game = gameManager.findGameBySaveName(name: gameName) {
            print("Game Found! Loading \(game.gameConfig.identifier)")
            
            // Load the imported savegame into the game's context
            game.settings.saveGame = savegame.saveToString()
            
            // Navigate to the game!
            navPath.append(game)
            
            return true
        } else {
            print("Failed to find game for name: \(gameName)")
            return false
        }
        
    }
    
    var body: some View {
        NavigationStack(path: $navPath) {
            VStack {
                
                // MARK: First Run Message
                // Note: `welcomeMessageDisplayed` is a separate boolean in order for animations to work properly. Toggling animations based on the appSettings wrapper didn't work properly.
                if(appSettings.value.showFirstRunMessage && welcomeMessageDisplayed) {
                    VStack(alignment: .leading) {
                        WelcomeMessageView()
                       
                        Button("Dismiss Message") {
                            withAnimation {
                                welcomeMessageDisplayed = false
                            } completion: {
                                appSettings.value.showFirstRunMessage = false
                            }
                        }.buttonStyle(.bordered)
                        
                    }
                    .frame(
                      minWidth: 0,
                      maxWidth: .infinity,
                      minHeight: 0,
                      maxHeight: .infinity,
                      alignment: .topLeading
                    )
                    .fixedSize(horizontal: false, vertical: /*@START_MENU_TOKEN@*/true/*@END_MENU_TOKEN@*/)
                    .padding(20)
                    
                    //.border(.green, 3)
                    .border(.blue, width: 3)
                    
                    .clipShape(RoundedRectangle(cornerRadius: 3))
                    .padding(10)
                }
                
                if(appSettings.value.gameListView == .listView) {
                    List {
                        if(!favoriteGames.isEmpty) {
                            Section("Favorites") {
                                ForEach(favoriteGames) { gameModel in
                                    GameListLargeItem(game: gameModel)
                                }
                            }
                        }
                        
                        if(!allGames.isEmpty) {
                            Section("All Games") {
                                ForEach(allGames) { gameModel in
                                    GameListLargeItem(game: gameModel)
                                }
                            }
                        }
                        
                        if(!hiddenGames.isEmpty) {
                            Section("Hidden Games", isExpanded: $isHiddenSectionExpanded) {
                                ForEach(hiddenGames) { gameModel in
                                    GameListLargeItem(game: gameModel)
                                }
                            }
                        }
                    }
                    .listStyle(SidebarListStyle()) // Sidebar list style allows the collapsible hidden games section
                    //.listStyle(.plain)
                    
                    
                }
                else { // Grid View
                    ScrollView {
                        LazyVGrid(columns: columns, alignment: .leading) {
                            if(!gameManager.favoriteGames.isEmpty) {
                                Section("Favorites") {
                                    ForEach(favoriteGames) { gameModel in
                                        GameListGridItem(game: gameModel)
                                    }
                                }
                                .padding(.bottom)
                            }
                            if(!gameManager.allGames.isEmpty) {
                                Section("All Games") {
                                    ForEach(allGames) { gameModel in
                                        GameListGridItem(game: gameModel)
                                    }
                                }
                                .padding(.bottom)
                            }
                            
                            if(isHiddenSectionExpanded && !gameManager.hiddenGames.isEmpty) {
                                Section("Hidden Games") {
                                    ForEach(hiddenGames) { gameModel in
                                        GameListGridItem(game: gameModel)
                                    }
                                }
                            }
                        }
                        .padding()
                        
                    }
                    
                    Spacer()
                    
                }
            }
            // MARK: Game Manager Setup Task
            .onAppear {
                // Function creates the games list and attaches/creates the user settings to each game!
                // Thoughts: Should this be moved to the root PuzzlesApp file?
                
                gameManager.createGamesList(with: modelContext)
                
                if appSettings.value.showFirstRunMessage == true {
                    welcomeMessageDisplayed = true
                }
            }
            // Detects changes to the welcome message settings & updates the flags accordingly
            .onChange(of: appSettings.value.showFirstRunMessage) { _, newValue in
                withAnimation {
                    welcomeMessageDisplayed = newValue
                }
            }
            .sheet(isPresented: $settingsPageDisplayed) {
                SettingsView()
            }
            .navigationDestination(for: Game.self) { gameModel in
                GameView(game: gameModel)
            }
            .navigationTitle("Simon Tatham Puzzles")
            .toolbar {
                if(appSettings.value.gameListView == .gridView && !gameManager.hiddenGames.isEmpty) {
                    Button() {
                        isHiddenSectionExpanded.toggle()
                    } label: {
                        if(isHiddenSectionExpanded) {
                            Image(systemName: "eye")
                        } else { // "grid"
                            Image(systemName: "eye.slash")
                        }
                    }
                }
                Button {
                    appSettings.value.toggleGameListView()
                } label: {
                    if(appSettings.value.gameListView == .listView) {
                        Image(systemName: "rectangle.grid.1x2")
                    } else { // "grid"
                        Image(systemName: "square.grid.3x3")
                    }
                    
                }
                Button {
                    settingsPageDisplayed = true
                } label: {
                    Image(systemName: "gearshape")
                }
                //EditButton()
            }
            .onOpenURL { url in
                print("Open URL: %s\n", url.absoluteString)
                let save = try! String(contentsOf: url)
                print(save)
                
                if let savegame = GameIdentifier.openSavegameFromURL(url) {
                    let loadingResult = identifyAndOpenGame(savegame: savegame)
                    
                    if loadingResult == false {
                        showingSavegameFailAlert = true
                    }
                } else {
                    showingSavegameFailAlert = true
                }

            }
            .alert("Save Import Failed", isPresented: $showingSavegameFailAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("The file you tried to import is not a valid savegame.")
            }
        }
    }

}

#Preview {
    GameListView()
        .environment(GameManager())
        .modelContainer(for: GameUserSettings.self, inMemory: true)
}
