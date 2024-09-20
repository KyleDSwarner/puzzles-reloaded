//
//  GameIDView.swift
//  Puzzles Reloaded
//
//  Created by Kyle Swarner on 9/20/24.
//  Copyright © 2024 Kyle Swarner. All rights reserved.
//

import SwiftUI

struct GameIDView: View {
    
    var frontend: Frontend
    @State private var gameId: String = ""
    @State private var seed: String = ""
    
    @FocusState private var gameIdFocused: Bool
    
    var body: some View {
        NavigationStack {
            VStack {
                Form {
                    Section("By Game Id") {
                        TextField("Game ID", text: $gameId)
                            .keyboardType(.alphabet)
                            .focused($gameIdFocused)
                        Button("Load from Game ID") {
                            gameIdFocused = false
                        }
                    }
                    
                    Section("Generation Seed") {
                        TextField("Random Seed", text: $seed)
                        Button("Load from Random Seed") {
                            // lol
                        }
                    }
                }.onAppear() {
                    gameId = frontend.midend.getGameId()
                    seed = frontend.midend.getGameSeed()
                }
                .navigationTitle("Load Specific Game")
                .navigationBarTitleDisplayMode(.inline)
                //.presentationDetents([.medium, .large])
            }
        }
    }
}

/*
 #Preview {
 GameIDView()
 }
 */
