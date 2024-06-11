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
    
    var gameTitle: String = "Test"
    
    //@State var gameMenu: [CustomMenuItem] = []
    
    var frontend: Frontend
    
    private var gameConfig: CustomConfigMenu?
    @State private var gameMenu: [CustomMenuItem2] = []
    
    init(gameTitle: String, frontend: Frontend) {
        self.gameTitle = gameTitle
        
        self.frontend = frontend
        
        gameConfig = frontend.midend.getCustomGameSettingsMenu()
    }
    
    var body: some View {
        NavigationStack {
                Form {
                    List($gameMenu, id:\.index) { menuItem in
                        switch menuItem.wrappedValue.type {
                        case .BOOLEAN:
                            Toggle(isOn: menuItem.boolValue) {
                                Text(menuItem.wrappedValue.title)
                            }
                        case .STRING:
                            HStack {
                                Text(menuItem.wrappedValue.title)
                                Spacer()
                                TextField("", text: menuItem.stringValue)
                            }
                            TextField(menuItem.wrappedValue.title, text: menuItem.stringValue, prompt: Text(menuItem.wrappedValue.title))
                        case .INT:
                            HStack {
                                Text(menuItem.wrappedValue.title)
                                TextField("", value: menuItem.intValue, formatter: NumberFormatter())
                                    //.frame(width: 30)
                                    .bold()
                                    //.multilineTextAlignment(.trailing)
                                    //.padding(.horizontal, 5)
                                    //.background(.gray)
                                    //.clipShape(RoundedRectangle(cornerRadius: 5))
                                    .keyboardType(.numberPad)
                                    //.submitLabel(.done)
                                    .onReceive(NotificationCenter.default.publisher(for: UITextField.textDidBeginEditingNotification)) { obj in
                                        // Select all text automatically when you tap on the text field for easier data entry
                                        if let textField = obj.object as? UITextField {
                                            textField.selectedTextRange = textField.textRange(from: textField.beginningOfDocument, to: textField.endOfDocument)
                                        }
                                    }
                                Stepper("", value: menuItem.intValue, in: 0...100)
                                    .accessibilityHidden(true)
                            }
                        case .CHOICE:
                            Picker(menuItem.wrappedValue.title, selection: menuItem.choiceIndex) {
                                ForEach(menuItem.choices, id:\.id) { choice in
                                    Text(choice.wrappedValue.name)
                                }
                            }
                        }
                    }
                    
                    Section {
                        Button("Save Changes") {
                            saveChanges()
                        }
                    }
                    /*
                    ForEach($gameMenu, id:\.index) { $menuItem in
                        if $menuItem.wrappedValue is BooleanMenuItem {
                            
                            
                            
                            //let booleanMenu = $menuItem as! Binding<BooleanMenuItem>
                            Toggle(isOn: ($menuItem.wrappedValue as BooleanMenuItem).value) {
                                Text(menuItem.title)
                            }
                            
                            //Text("\(booleanMenu.value)")
                        }
                        else if menuItem is StringMenuItem {
                            let stringMenuItem = menuItem as! StringMenuItem
                            
                        }
                        else if menuItem is ChoiceMenuItem {
                            
                        }
                        Text(menuItem.title)
                    }
                     */
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
        let error = frontend.midend.setNewGameParams(choices: self.gameMenu)
        
        if let errorText = error {
            // Present the error to the user
            self.errorText = errorText
            presentingAlertMessage = true
        } else {
            dismiss()
            frontend.beginGame()
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
