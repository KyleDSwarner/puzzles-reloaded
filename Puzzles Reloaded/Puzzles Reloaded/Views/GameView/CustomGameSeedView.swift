//
//  GameIDView.swift
//  Puzzles Reloaded
//
//  Created by Kyle Swarner on 9/20/24.
//  Copyright © 2024 Kyle Swarner. All rights reserved.
//

import SwiftUI

struct CustomGameSeedView: View {
    
    var frontend: Frontend
    var newGameCallback: () -> Void
    
    @Environment(\.dismiss) var dismiss
    @State private var seed: String = ""
    
    @State private var currentSeed: String = ""
    
    @FocusState private var seedFieldFocused: Bool
    
    @State private var presentingAlertMessage = false
    @State private var errorText = ""
    
    var body: some View {
        NavigationStack {
            Form {
                TextField("Enter Random Seed", text: $seed)
                    .autocorrectionDisabled()

                Button("Load Game") {
                    loadGame()
                }
                
                if(!currentSeed.isEmpty) {
                    Section {
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Current Seed")
                                    .foregroundStyle(.secondary)
                                    .font(.caption)
                                
                                Button(currentSeed) {
                                    UIPasteboard.general.string = currentSeed
                                }
                                .foregroundStyle(.primary)
                                
                            }
                        }
                    } footer: {
                        Text("Tap to copy to clipboard")
                    }
                }
            }.onAppear() {
                currentSeed = frontend.midend.getGameSeed()
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Text("Cancel")
                    }
                }
            }
            .alert("Configuration Error", isPresented: $presentingAlertMessage) {
                Button("OK") {
                    // Intentionally Empty
                }
            } message: {
                Text(errorText)
            }
            .navigationTitle("Load Seed")
            .navigationBarTitleDisplayMode(.inline)
            .presentationDetents([.medium])
            
        }
    }
    
    func loadGame() {
        seedFieldFocused = false
        
        let error = frontend.midend.setCustomGameGenerationValue(seed, configType: PuzzleConfigTypes.gameSeed)
        
        if let error = error {
            errorText = error
            presentingAlertMessage = true
        }
        else {
            newGameCallback()
            dismiss()
            
        }
        
        
        
        
        print("Check Me Out")
    }
    
}

/*
 #Preview {
 GameIDView()
 }
 */
