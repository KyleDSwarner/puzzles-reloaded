//
//  CustomConfigMenu.swift
//  Puzzles Reloaded
//
//  Created by Kyle Swarner on 6/24/24.
//  Copyright © 2024 Kyle Swarner. All rights reserved.
//

import Foundation

enum CustomMenuType: Codable {
    case INT, DECIMAL, STRING, BOOLEAN, CHOICE
}

struct CustomMenuItem: Codable, Hashable {
    var index: Int
    var type: CustomMenuType
    var title: String
    
    var intValue : Int
    var decimalValue: Double = -1
    
    var stringValue: String
    
    var boolValue: Bool
    
    var choiceIndex: Int
    var choices: [ChoiceMenuOption]
    
    init(index: Int, type: CustomMenuType, title: String, intValue: Int = -1, decimalValue: Double = -1, stringValue: String = "", boolValue: Bool = false, choiceIndex: Int = -1, choices: [ChoiceMenuOption] = []) {
        self.index = index
        self.type = type
        self.title = title
        self.intValue = intValue
        self.decimalValue = decimalValue
        self.stringValue = stringValue
        self.boolValue = boolValue
        self.choiceIndex = choiceIndex
        self.choices = choices
    }
    
    enum CodingsKeys: String, CodingKey {
        case index, type, title, intValue, decimalValue, stringValue, boolValue, choiceIndex, choices
    }
    
    /**
        Custom decoder method allows for smooth migrations when we add or remove fields, otherwise data will be lost when the decoder can't create the new model.
     */
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        index = try values.decodeIfPresent(Int.self, forKey: .index) ?? 0
        type = try values.decodeIfPresent(CustomMenuType.self, forKey: .type) ?? .STRING
        title = try values.decodeIfPresent(String.self, forKey: .title) ?? ""
        intValue = try values.decodeIfPresent(Int.self, forKey: .intValue) ?? -1
        decimalValue = try values.decodeIfPresent(Double.self, forKey: .decimalValue) ?? 0.0
        stringValue = try values.decodeIfPresent(String.self, forKey: .stringValue) ?? ""
        boolValue = try values.decodeIfPresent(Bool.self, forKey: .boolValue) ?? false
        choiceIndex = try values.decodeIfPresent(Int.self, forKey: .choiceIndex) ?? -1
        choices = try values.decodeIfPresent([ChoiceMenuOption].self, forKey: .choices) ?? []
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
    
    func addDecimalManuItem(index: Int, title: String, currentValue: Double) {
        menu.append(CustomMenuItem(index: index, type: .DECIMAL, title: title, decimalValue: currentValue))
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

struct ChoiceMenuOption: Codable, Hashable {
    let id: Int
    let name: String
}

