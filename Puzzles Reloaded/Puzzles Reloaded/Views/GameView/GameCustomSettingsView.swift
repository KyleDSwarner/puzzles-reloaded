//
//  GameCustomSettingsView.swift
//  Puzzles Reloaded
//
//  Created by Kyle Swarner on 6/10/24.
//  Copyright © 2024 Kyle Swarner. All rights reserved.
//

import SwiftUI

struct GameCustomSettingsView: View {
    
    @Environment(\.dismiss) var dismiss
    @State private var presentingAlertMessage = false
    @State private var errorText = ""
    
    var gameTitle: String = ""
    
    var frontend: Frontend
    var newGameCallback: () -> Void
    
    private var gameConfig: CustomConfigMenu?
    @State private var gameMenu: [CustomMenuItem] = []
    
    init(gameTitle: String, frontend: Frontend, newGameCallback: @escaping () -> Void) {
        self.gameTitle = gameTitle
        
        self.frontend = frontend
        self.newGameCallback = newGameCallback
        
        gameConfig = frontend.midend.getGameCustomParameters()
    }
    
    var body: some View {
        NavigationStack {
                Form {
                    CustomGameConfigView(gameMenu: $gameMenu)
                    
                    Section {
                        Button("Save Changes") {
                            saveChanges()
                        }
                    }
                }
                .navigationTitle("\(gameTitle) Configuration")
                .navigationBarTitleDisplayMode(.inline)

                .toolbar {
                    ToolbarItemGroup(placement: .topBarLeading) {
                        Button("Cancel") {
                            dismiss()
                        }
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Save") {
                            saveChanges()
                        }
                    }
                    ToolbarItem(placement: .keyboard) {
                        Button("Done") {
                            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                        }
                    }
                }
            }
        // MARK: Create Game Menu Object
        .onAppear {
            self.gameMenu = gameConfig?.menu ?? []
        }
        .alert("Configuration Error", isPresented: $presentingAlertMessage) {
            Button("OK") {
                // Intentionally Empty
            }
        } message: {
            Text(errorText)
        }
    }
    
    func saveChanges() {
        let error = frontend.midend.setGameCustomParameters(choices: self.gameMenu)
        
        if let errorText = error {
            // Present the error to the user
            self.errorText = errorText
            presentingAlertMessage = true
        } else {
            dismiss()
            frontend.setPuzzlePreset(customPreset: self.gameMenu)
            newGameCallback()
            // Success! Close the modal and generate a new game.
            // Do we need to consider long-running game generation?
            // TODO: Move this to a callback function?
        }
    }
}


/*
 #Preview {
 
 var configMenu: CustomConfigMenu = CustomConfigMenu(configItem: nil, menu: [
 StringMenuItem(title: "Test Value", value: "6", index: 0),
 BooleanMenuItem(title: "Release the Hounds", value: true, index: 1),
 ChoiceMenuItem(title: "Make a Choice", choices: [
 ChoiceMenuOption
 ], selection: , index: <#T##Int#>)
 ])
 
 GameCustomSettingsView()
 }
*/
