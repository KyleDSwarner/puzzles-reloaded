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
    @State private var gameSortOptionsViewDisplayed = false
    @State private var searchText: String = ""
    
    
    let columns = [
        GridItem(.adaptive(minimum: 80), alignment: .top)
    ]
    
    var favoriteGames: [Game] {
        retrieveAndSortGameList(category: .favorite)
    }
    
    var allGames: [Game] {
        retrieveAndSortGameList(category: .none)
    }
    
    var hiddenGames: [Game] {
        retrieveAndSortGameList(category: .hidden)
    }
    
    var filteredGames: [Game] {
        return filterGameListBySearchTerm(gameManager.getGameList(showHiddenGames: appSettings.value.gameListDisplayHidden))
    }
    
    func retrieveAndSortGameList(category: GameCategory) -> [Game] {
        
        let gameList = gameManager.gameModel.filter { game in
            game.settings.category == category && (!game.gameConfig.isExperimental || appSettings.value.showExperimentalGames)
        }
        
        return sortGameList(gameList)
    }
    
    func sortGameList(_ games: [Game]) -> [Game] {
        var gameList: [Game] = []
        let sortOrder = appSettings.value.gameListSortOrder
        
        if sortOrder == .name || sortOrder == .nameReversed {
            gameList = games.sorted(by: {$0.gameConfig.identifier < $1.gameConfig.identifier})
        }
        
        else if sortOrder == .playCountHigh || sortOrder == .playCountLow {
            gameList = games.sorted(by: { $0.settings.stats.gamesPlayed > $1.settings.stats.gamesPlayed})

        }
        
        // Reverse the order, if needed
        if sortOrder == .nameReversed || sortOrder == .playCountLow {
            gameList.reverse()
        }
        
        return gameList
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
            game.settings.persistSavegame(savegame.saveToString())
            
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
                                        GameListLargeItem(game: gameModel, navigationPath: $navPath)
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
                                    GameListLargeItem(game: gameModel, navigationPath: $navPath)
                                }
                            }
                        }
                        
                        if(!allGames.isEmpty) {
                            Section("All Games") {
                                ForEach(allGames) { gameModel in
                                    GameListLargeItem(game: gameModel, navigationPath: $navPath)
                                }
                            }
                        }
                        
                        if(!hiddenGames.isEmpty && appSettings.value.gameListDisplayHidden) {
                            Section("Hidden Games") {
                                ForEach(hiddenGames) { gameModel in
                                    GameListLargeItem(game: gameModel, navigationPath: $navPath)
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
                            
                            if(!hiddenGames.isEmpty && appSettings.value.gameListDisplayHidden) {
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
            .sheet(isPresented: $gameSortOptionsViewDisplayed) {
                GameListDisplayOptionsView()
            }
            .navigationDestination(for: Game.self) { gameModel in
                GameView(game: gameModel)
            }
            .navigationTitle("Puzzles Reloaded")
            .toolbar {
                Button {
                    gameSortOptionsViewDisplayed = true
                } label: {
                    Image(systemName: "arrow.up.arrow.down")
                        .accessibilityHint("Open game list sorting options menu")
                }
                Button {
                    settingsPageDisplayed = true
                } label: {
                    Image(systemName: "gearshape")
                }
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
