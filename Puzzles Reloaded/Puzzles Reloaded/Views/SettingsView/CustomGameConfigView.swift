//
//  CustomGameConfigView.swift
//  Puzzles Reloaded
//
//  Created by Kyle Swarner on 6/12/24.
//  Copyright © 2024 Kyle Swarner. All rights reserved.
//

import SwiftUI

struct CustomGameConfigView: View {
    
    var gameName: String
    @Binding var gameMenu: [CustomMenuItem]
    var isCustomOptionsMenu: Bool = false
    
    
    var body: some View {
        Section {
            List($gameMenu, id:\.index) { menuItem in
                let fieldTitle = menuItem.wrappedValue.title
                let helpInfo: GameConfigOption? = GameConfigOverrides.findOverride(gameName: gameName, field: menuItem.wrappedValue.title)
                
                VStack(alignment: .leading) {
                    
                    switch menuItem.wrappedValue.type {
                    case .BOOLEAN:
                        Toggle(isOn: menuItem.boolValue) {
                            Text(fieldTitle)
                        }
                    case .STRING:
                        CustomGameConfigStringView(menuItem: menuItem, helpConfig: helpInfo)
                    case .INT:
                        CustomGameConfigIntView(menuItem: menuItem, helpConfig: helpInfo)
                    case .DECIMAL:
                        CustomGameConfigDecimalView(menuItem: menuItem, helpConfig: helpInfo)
                    case .CHOICE:
                        Picker(fieldTitle, selection: menuItem.choiceIndex) {
                            ForEach(menuItem.choices, id:\.id) { choice in
                                Text(choice.wrappedValue.name)
                            }
                        }
                    }
                    
                    //MARK: Help Text
                    if let helpText = helpInfo?.customHelpText {
                        Text(helpText)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                
                
            }
        } footer: {
            // MARK: Custom Game Notes for extra info
            if isCustomOptionsMenu, let customGameNote = GameConfigOverrides.findGameNote(gameName: gameName) {
                Text(customGameNote.note)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        
        
        
    }
}

struct CustomGameConfigDecimalView: View {
    var menuItem: Binding<CustomMenuItem>
    let helpConfig: GameConfigOption?
    
    let decimalFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
          return formatter
    }()
    
    var body: some View {
        HStack {
            Text(menuItem.wrappedValue.title)
                .layoutPriority(1) // Try to prevent field from truncating if space is constrained
                .fixedSize(horizontal: false, vertical: true) // Allow to expand vertically if needed
            
            TextField("", value: menuItem.decimalValue, formatter: decimalFormatter)
                .modifier(CustomGameConfigTextfieldDesign())
            
            #if os(iOS)
                .keyboardType(.decimalPad)
                .onReceive(NotificationCenter.default.publisher(for: UITextField.textDidBeginEditingNotification)) { obj in
                    // Select all text automatically when you tap on the text field for easier data entry
                    if let textField = obj.object as? UITextField {
                        textField.selectedTextRange = textField.textRange(from: textField.beginningOfDocument, to: textField.endOfDocument)
                    }
                }
            #endif
            
            let minValue = Double(helpConfig?.minValue ?? 0)
            let maxValue = Double(helpConfig?.maxValue ?? 20)
            
            Slider(value: menuItem.decimalValue, in: minValue...maxValue, step: 0.01) {
                // Label is intentionally empty
            } minimumValueLabel: {
                Text("\(Int(minValue))")
            } maximumValueLabel: {
                Text("\(Int(maxValue))")
            }
            .accessibilityHidden(true)
            
        }
    }
    
    
}

struct CustomGameConfigIntView: View {
    var menuItem: Binding<CustomMenuItem>
    let helpConfig: GameConfigOption?
    
    var body: some View {
        HStack {
            Text(menuItem.wrappedValue.title)
                .layoutPriority(1)
                .fixedSize(horizontal: false, vertical: true)
            
            TextField("", value: menuItem.intValue, formatter: NumberFormatter())
                .modifier(CustomGameConfigTextfieldDesign())
            
            #if os(iOS)
                .keyboardType(.numberPad)
                .onReceive(NotificationCenter.default.publisher(for: UITextField.textDidBeginEditingNotification)) { obj in
                    // Select all text automatically when you tap on the text field for easier data entry
                    if let textField = obj.object as? UITextField {
                        textField.selectedTextRange = textField.textRange(from: textField.beginningOfDocument, to: textField.endOfDocument)
                    }
                }
            #endif
            

            let minValue = helpConfig?.minValue ?? 0
            let maxValue = helpConfig?.maxValue ?? 20
                
            Stepper("", value: menuItem.intValue, in: minValue...maxValue)
                .accessibilityHidden(true)
        }
    }
}

struct CustomGameConfigStringView: View {
    var menuItem: Binding<CustomMenuItem>
    let helpConfig: GameConfigOption?
    
    var body: some View {
        HStack {
            
            Text(menuItem.wrappedValue.title)
                .layoutPriority(1) // Try to prevent field from truncating if space is constrained
                .fixedSize(horizontal: false, vertical: true) // Allow to expand vertically if needed
            
            TextField("", text: menuItem.stringValue)
                .modifier(CustomGameConfigTextfieldDesign())
            
            #if os(iOS)
                .keyboardType(helpConfig?.preferDeciKeyboard == true ? .numbersAndPunctuation : .default)
                .onReceive(NotificationCenter.default.publisher(for: UITextField.textDidBeginEditingNotification)) { obj in
                    // Select all text automatically when you tap on the text field for easier data entry
                    if let textField = obj.object as? UITextField {
                        textField.selectedTextRange = textField.textRange(from: textField.beginningOfDocument, to: textField.endOfDocument)
                    }
                }
            #endif
                
        }
    }
    
    
}

// Apply consistent styling to text fields across all custom fields
struct CustomGameConfigTextfieldDesign: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(5) // Internal spacing
            .background(Color.primary.opacity(0.1)) // Subtle background
            .cornerRadius(8) // Rounded corners
            .bold()
    }
}


/*
 #Preview {
 CustomGameConfigView()
 }
 */
