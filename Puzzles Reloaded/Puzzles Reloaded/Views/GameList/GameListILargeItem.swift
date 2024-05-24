//
//  SwiftUIView.swift
//  Puzzles
//
//  Created by Kyle Swarner on 2/23/24.
//  Copyright © 2024 Kyle Swarner. All rights reserved.
//

import SwiftUI

struct GameListLargeItem: View {
       
    var game: Game
    
    var gameConfig: GameConfig {
        game.game
    }
    
    var gameSettings: GameListConfig {
        game.settings
    }
    
    var body: some View {
        NavigationLink(value: game) {
            HStack {
                /*
                if editMode?.wrappedValue.isEditing == true {
                    Image(systemName: "star")
                        .padding(5)
                        .onTapGesture {
                            print("Pencil")
                        }
                }
                 */
                Image(gameConfig.imageName)
                VStack(alignment: .leading) {
                    Text(gameConfig.name)
                        .font(.title)
                    Text(gameConfig.description)
                        .font(.callout)
                    Spacer()
                }
                .padding(5)
            }
        }
        .swipeActions(allowsFullSwipe: false) {
            GameContextMenu(game: game)
        }
        .contextMenu() {
            GameContextMenu(game: game)
        }
    }
}

#Preview {
    NavigationStack {
        List {
            GameListLargeItem(game: Game.exampleGameModel)
        }
    }
}
