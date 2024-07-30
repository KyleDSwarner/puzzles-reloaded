//
//  CustomConfigMenu.swift
//  Puzzles Reloaded
//
//  Created by Kyle Swarner on 6/24/24.
//  Copyright © 2024 Kyle Swarner. All rights reserved.
//

import Foundation

enum CustomMenuType: Codable {
    case INT, STRING, BOOLEAN, CHOICE
}

struct CustomMenuItem: Codable {
    var index: Int
    var type: CustomMenuType
    var title: String
    
    var intValue : Int
    
    var stringValue: String
    
    var boolValue: Bool
    
    var choiceIndex: Int
    var choices: [ChoiceMenuOption]
    
    init(index: Int, type: CustomMenuType, title: String, intValue: Int = -1, stringValue: String = "", boolValue: Bool = false, choiceIndex: Int = -1, choices: [ChoiceMenuOption] = []) {
        self.index = index
        self.type = type
        self.title = title
        self.intValue = intValue
        self.stringValue = stringValue
        self.boolValue = boolValue
        self.choiceIndex = choiceIndex
        self.choices = choices
    }
    
}

class CustomConfigMenu: Codable {
    // var configItem: config_item? // The original config item that must be submitted back to the midend.
    var menu: [CustomMenuItem] // A list of cleaned up & processed items for display by swift. Each
    
    init(menu: [CustomMenuItem] = []) {
       // self.configItem = configItem
        self.menu = menu
    }
    
    func addMenuItem(_ newItem: CustomMenuItem) {
        menu.append(newItem)
    }
    
    func addIntMenuItem(index: Int, title: String, currentValue: Int) {
        menu.append(CustomMenuItem(index: index, type: .INT, title: title, intValue: currentValue))
    }
    
    func addStringMenuItem(index: Int, title: String, currentValue: String) {
        menu.append(CustomMenuItem(index: index, type: .STRING, title: title, stringValue: currentValue))
    }
    
    func addBooleanMenuItem(index: Int, title: String, currentValue: Bool) {
        menu.append(CustomMenuItem(index: index, type: .BOOLEAN, title: title, boolValue: currentValue))
    }
}

struct ChoiceMenuOption: Codable {
    let id: Int
    let name: String
}

