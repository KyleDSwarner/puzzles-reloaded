//
//  GameContextMenu.swift
//  Puzzles
//
//  Created by Kyle Swarner on 2/25/24.
//  Copyright © 2024 Kyle Swarner. All rights reserved.
//

import SwiftUI

struct GameContextMenu: View {
    
    var game: Game
    
    var body: some View {
        if(!game.isHidden) { // Don't let the user promote something to favorite straight from hidden
            Button {
                withAnimation {
                    game.settings.updateGameCategory(.favorite)
                }
            } label: {
                if(!game.isFavorite) {
                    Label("Favorite", systemImage: "star")
                }
                else {
                    Label("Unfavorite", systemImage: "star.slash")
                }
            }
            .tint(.yellow)
        }
        
        if(!game.isFavorite) { // Don't let the user accidentially hide a favorite game
            Button {
                withAnimation {
                    game.settings.updateGameCategory(.hidden)
                }
            } label: {
                if(!game.isHidden) {
                    Label("Hide", systemImage: "eye.slash")
                }
                else {
                    Label("Unhide", systemImage: "eye")
                }
            }
        }
        
        if(game.settings.hasSavedGame) {
            Button {
                withAnimation {
                    game.settings.abandonSave()
                }
            } label: {
                Label("Abandon Save", systemImage: "trash")
            }
            .tint(.red)
        }
    }
}

#Preview {
    List {
        Text("Test Item!")
            .contextMenu {
                GameContextMenu(game: Game.exampleGameModel)
            }
            .swipeActions(allowsFullSwipe: false) {
                GameContextMenu(game: Game.exampleGameModel)
            }
    }
}
