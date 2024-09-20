//
//  GameIDView.swift
//  Puzzles Reloaded
//
//  Created by Kyle Swarner on 9/20/24.
//  Copyright © 2024 Kyle Swarner. All rights reserved.
//

import SwiftUI

struct CustomGameIDView: View {
    
    var frontend: Frontend
    var newGameCallback: () -> Void
    
    @Environment(\.dismiss) var dismiss
    @State private var gameId: String = ""
    
    @State private var currentGameId: String = ""
    
    @FocusState private var gameIdFocused: Bool
    
    @State private var presentingAlertMessage = false
    @State private var errorText = ""
    
    var body: some View {
        NavigationStack {
            Form {
                TextField("Enter Game ID", text: $gameId)
                    .autocorrectionDisabled()

                Button("Load Game") {
                    loadGame()
                }
                
                if(!currentGameId.isEmpty) {
                    Section {
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Current Game ID")
                                    .foregroundStyle(.secondary)
                                    .font(.caption)
                                
                                Button(currentGameId) {
                                    UIPasteboard.general.string = currentGameId
                                }
                                .foregroundStyle(.primary)
                                
                            }
                        }
                    } footer: {
                        Text("Tap to copy to clipboard")
                    }
                }
            }.onAppear() {
                currentGameId = frontend.midend.getGameId()
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
            .navigationTitle("Load Game ID")
            .navigationBarTitleDisplayMode(.inline)
            .presentationDetents([.medium])
            
        }
    }
    
    func loadGame() {
        gameIdFocused = false
        
        let error = frontend.midend.setCustomGameGenerationValue(gameId, configType: PuzzleConfigTypes.gameId)
        
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
