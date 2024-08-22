//
//  GameHelpView.swift
//  Puzzles Reloaded
//
//  Created by Kyle Swarner on 5/24/24.
//  Copyright © 2024 Kyle Swarner. All rights reserved.
//

import SwiftUI

struct GameHelpView: View {
    
    @Environment(\.dismiss) var dismiss
    
    let game: GameConfig

    init(game: GameConfig) {
        self.game = game
    }
    
    var body: some View {
        
        NavigationStack {
            
                ScrollView {
                    
                    VStack(alignment: .leading) {
                    
                    Text(game.name).font(.largeTitle)
                    
                    HStack {
                        Image("\(game.imageName)-base")
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: 250, maxHeight: 250)
                        Spacer()
                    }
                    .padding(.bottom, 15)
                    
                        if let instructions = game.instructions {
                            Text(instructions)
                                .multilineTextAlignment(.leading)
                        }
                    
                    
                    if let controlInfo = game.controlInfo {
                        Spacer(minLength: 20)
                        Divider()
                        
                        Text("Controls", comment: "Heading for the 'controls' section on help page").font(.title2)
                            .padding(.bottom, 5)
                        Text(controlInfo)
                            .multilineTextAlignment(.leading)
                    }
                    
                    
                    if let customParamText = game.customParamInfo {
                        Spacer(minLength: 20)
                        Divider()
                        
                        Text("Game Parameters", comment: "Heading for the 'game parameters' section on the help page").font(.title2)
                            .padding(.bottom, 5)
                        Text(customParamText)
                            .multilineTextAlignment(.leading)
                    }
                    
                    if let userParamInfo = game.userParamInfo {
                        Spacer(minLength: 20)
                        Divider()
                        
                        Text("User Preferences", comment: "Heading for the 'user parameters' section on the game help page").font(.title2)
                            .padding(.bottom, 5)
                        Text(userParamInfo)
                            .multilineTextAlignment(.leading)
                    }
                }
                .padding(15)
                .navigationTitle("Help")
                    #if os(iOS)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button {
                            dismiss()
                        } label: {
                            Text("Done")
                        }
                    }
                    
                }
                    #endif
            }
        }
    }
    
}

#Preview {
    GameHelpView(game: GameConfig.exampleGame)
}
