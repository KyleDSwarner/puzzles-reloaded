//
//  GameListGridItem.swift
//  Puzzles
//
//  Created by Kyle Swarner on 2/24/24.
//  Copyright © 2024 Kyle Swarner. All rights reserved.
//

import SwiftUI

struct GameListGridItem: View {
    
    @State private var showDetails = false
    var game: Game
    //var updateCategory: (Game, GameCategory) -> Void
    
    var body: some View {
        NavigationLink(value: game) {
            ZStack {
                //RoundedRectangle(cornerRadius: 5, style: .continuous)
                //    .fill(Color.primary)
                Image("\(game.gameConfig.imageName)")
                    .resizable()
                    
                //.padding(2)
                    .scaledToFit()
                    .padding(2)
                    .border(.primary, width: 2)
                
                    .clipShape(RoundedRectangle(cornerRadius: 5, style: .continuous))
                    .contentShape(.contextMenuPreview, RoundedRectangle(cornerRadius: 5))
                    .contextMenu() {
                        GameContextMenu(game: game)
                    }
                
                // Future additions : Indicators for games on progress?
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
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    return GameListGridItem(game: Game.exampleGameModel)
    
}




