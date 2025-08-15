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
    @State private var searchText: String = ""
    
    
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
    
    var filteredGames: [Game] {
        return filterGameListBySearchTerm(gameManager.getGameList(showHiddenGames: isHiddenSectionExpanded))
    }
    
    // Return a boolean if a search term would include results IF it included previously hidden games
    func wouldSearchFindHiddenGames() -> Bool {
        let games = filterGameListBySearchTerm(hiddenGames)
        return !games.isEmpty
    }
    
    func filterGameListBySearchTerm(_ games: [Game]) -> [Game] {
        let searchTerm = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        return games.filter({ game in
            searchTerm.isEmpty
            || game.gameConfig.name.localizedCaseInsensitiveContains(searchTerm) // Search the game name
            || game.gameConfig.savegameIdentifier.localizedCaseInsensitiveContains(searchTerm) // Search the savegame idenfitifier
            || game.gameConfig.searchTerms.contains(where: { $0.localizedCaseInsensitiveContains(searchTerm) }) // Search additional search terms configured in the app
        })
    }
    
    init() {
        configureToolbarDisplay()
    }
    
    // MARK: Toolbar Design Configuration
    func configureToolbarDisplay() {
        #if os(iOS)
        if #available(iOS 26.0, *) {
            // Do nothing - our navbar appearances should be disabled once glass comes into play
        } else {
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
        }
        #endif
        
        //UINavigationBar.appearance().tintColor = .white
    }
    
    // Function managed imported *.sgtp savegame
    func handleImportedSavegame(_ url: URL) {
        print("Opening imported savegame: %s", url.absoluteString)
        
        if let savegame = GameIdentifier.openSavegameFromURL(url) {
            let loadingResult = identifyAndOpenGame(savegame: savegame)
            
            if loadingResult == false {
                showingSavegameFailAlert = true
            }
        } else {
            showingSavegameFailAlert = true
        }
    }
    
    // From a savegame extracted from a *sgtp file, itentify & process the game
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
                    WelcomeMessageView(welcomeMessageDisplayed: $welcomeMessageDisplayed)
                }
                
                // MARK: Search Results
                if(!searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty) {
                    // Check for filtered games is nested as a 2nd if to ensure the "no games found" overlay can display on its own if a search is in progress.
                    if(filteredGames.count > 0) {
                        if(appSettings.value.gameListView == .listView) {
                            List {
                                Section("\(filteredGames.count) games found") {
                                    ForEach(filteredGames) { gameModel in
                                        GameListLargeItem(game: gameModel)
                                    }
                                }
                            }
                        } else {
                            // Search Grid View
                            ScrollView {
                                LazyVGrid(columns: columns, alignment: .leading) {
                                    Section("\(filteredGames.count) games found") {
                                        ForEach(filteredGames) { gameModel in
                                            GameListGridItem(game: gameModel)
                                        }
                                    }
                                }
                                .padding()
                            }
                        }
                    }
                }
                
                else if(appSettings.value.gameListView == .listView) {
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
            // MARK: Open *.sgpt
            .onOpenURL { url in
                handleImportedSavegame(url)
            }
            .alert("Save Import Failed", isPresented: $showingSavegameFailAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("The file you tried to import is not a valid savegame.")
            }
        }
        .searchable(text: $searchText, placement: .automatic, prompt: "Find a Game")
        .textInputAutocapitalization(.never)
        .onChange(of: searchText) { old, new in
            print("New Query: \(new)")
        }
        
        // MARK: Game Not Found overlay
        .overlay {
            if !searchText.isEmpty && filteredGames.isEmpty {
                ContentUnavailableView {
                    Label("No Games Found", systemImage: "magnifyingglass")
                } description: {
                    Text("'\(searchText)' does not match any games")
                } actions: {
                    if !isHiddenSectionExpanded, wouldSearchFindHiddenGames() {
                        Button("Include Hidden Games") {
                            isHiddenSectionExpanded = true
                        }
                            .modifier(ButtonDesigner())
                            .modifier(ButtonTextColor())
                    }
                }
            }
        }
    }

}

#Preview {
    GameListView()
        .environment(GameManager())
        .modelContainer(for: GameUserSettings.self, inMemory: true)
}
