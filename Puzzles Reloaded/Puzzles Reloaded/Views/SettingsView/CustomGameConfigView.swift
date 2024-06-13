//
//  CustomGameConfigView.swift
//  Puzzles Reloaded
//
//  Created by Kyle Swarner on 6/12/24.
//  Copyright © 2024 Kyle Swarner. All rights reserved.
//

import SwiftUI

struct CustomGameConfigView: View {
    
    @Binding var gameMenu: [CustomMenuItem2]
    
    var body: some View {
        List($gameMenu, id:\.index) { menuItem in
            
            switch menuItem.wrappedValue.type {
            case .BOOLEAN:
                Toggle(isOn: menuItem.boolValue) {
                    Text(menuItem.wrappedValue.title)
                }
            case .STRING:
                TextField(menuItem.wrappedValue.title, text: menuItem.stringValue, prompt: Text(menuItem.wrappedValue.title))
            case .INT:
                HStack {
                    Text(menuItem.wrappedValue.title)
                    TextField("", value: menuItem.intValue, formatter: NumberFormatter())
                        .frame(maxWidth: 80)
                        .padding(.vertical, 5)
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
    }
}

/*
 #Preview {
 CustomGameConfigView()
 }
 */
