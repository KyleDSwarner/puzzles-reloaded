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
    @AppStorage(AppSettings.key) var settings: CodableWrapper<AppSettings> = AppSettings.initialStorage()
    
    @State private var isHiddenSectionExpanded = false
    @State private var settingsPageDisplayed = false
    
    
    let columns = [
        GridItem(.adaptive(minimum: 80), alignment: .top)
    ]
    
    var favoriteGames: [Game] {
        gameManager.filterGameList(category: .favorite, showExperimentalGames: settings.value.showExperimentalGames)
    }
    
    var allGames: [Game] {
        gameManager.filterGameList(category: .none, showExperimentalGames: settings.value.showExperimentalGames)
    }
    
    var hiddenGames: [Game] {
        gameManager.filterGameList(category: .hidden, showExperimentalGames: settings.value.showExperimentalGames)
    }
    
    init() {
        configureToolbarDisplay()
    }
    
    func configureToolbarDisplay() {
        
        print("Configuring Toolbar beep boop")
        
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
        
        //UINavigationBar.appearance().tintColor = .white
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                if(settings.value.gameListView == .listView) {
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
                    .listStyle(SidebarListStyle())
                    
                    
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
            .onAppear {
                // Function creates the games list and attaches/creates the user settings to each game!
                // Thoughts: Should this be moved to the root PuzzlesApp file?
                gameManager.setupData(with: modelContext)
                //gameManager.createGamesList(with: modelContext)
            }
            .sheet(isPresented: $settingsPageDisplayed) {
                SettingsView()
            }
            .navigationDestination(for: Game.self) { gameModel in
                GameView(game: gameModel)
            }
            .navigationTitle("Puzzles")
            //.toolbarBackground(Color.gray, for: .automatic)
            //.toolbarBackground(Color.blue, for: .bottomBar)
            .toolbar {
                if(settings.value.gameListView == .gridView && !gameManager.hiddenGames.isEmpty) {
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
                    settings.value.toggleGameListView()
                } label: {
                    if(settings.value.gameListView == .listView) {
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
        }
    }

}

#Preview {
    GameListView()
        .environment(GameManager())
        .modelContainer(for: GameListConfig.self, inMemory: true)
}
