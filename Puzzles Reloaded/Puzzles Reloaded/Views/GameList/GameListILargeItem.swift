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
    
    var gameSettings: GameUserSettings {
        game.settings
    }
    
    var body: some View {
        NavigationLink(value: game) {
            HStack(alignment: .top) {
                /*
                if editMode?.wrappedValue.isEditing == true {
                    Image(systemName: "star")
                        .padding(5)
                        .onTapGesture {
                            print("Pencil")
                        }
                }
                 */
                VStack {
                    ZStack {
                        
                        Image(gameConfig.imageName)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 75, height: 75)
                        
                        if game.settings.hasSavedGame {
                            VStack(alignment:.trailing) {
                                Spacer()
                                HStack {
                                    Spacer()
                                    Circle()
                                        .stroke(.black, lineWidth: 2)
                                        .fill(.yellow)
                                        .frame(width: 10, height: 10)
                                        .padding(4)
                                }
                            }
                        }
                    }
                    .frame(width: 75, height: 75)
                }
                .padding(.vertical, 5)
               
                
                VStack(alignment: .leading) {
                    Text(gameConfig.name)
                        .font(.title)
                    Text(gameConfig.description)
                        .font(.subheadline)
                }
                
            }
            //.border(.blue)
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
