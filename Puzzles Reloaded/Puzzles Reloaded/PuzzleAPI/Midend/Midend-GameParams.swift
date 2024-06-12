//
//  Midend-GameConfig.swift
//  Puzzles
//
//  Created by Kyle Swarner on 5/3/24.
//  Copyright © 2024 Kyle Swarner. All rights reserved.
//

import Foundation

struct PuzzleConfigTypes {
    static let gameParameters = CFG_SETTINGS
    static let userPreferences = CFG_PREFS
    static let gameSeed = CFG_SEED
    static let gameId = CFG_DESC
}

extension Midend {
    
    
    public func getCurrentPreset() -> Int {
        return Int(midend_which_preset(midendPointer))
    }
    
    /**
        Query the midend for the list of game presets & construct a preset menu for use in the UI.
     */
    public func getGamePresets() -> [PresetMenuItem] {
        
        currentGamePreset = Int(midend_which_preset(midendPointer))
        
        let presetMenuPointer: UnsafeMutablePointer<preset_menu> = midend_get_presets(midendPointer, nil)
        
        return convertPresetMenu(presetMenuPointer.pointee)
    }
    
    private func convertPresetMenu(_ presetMenu: preset_menu) -> [PresetMenuItem] {
        var convertedMenu = [PresetMenuItem]()
        
        let numPresets = Int(presetMenu.n_entries)
        
        for i in 0..<numPresets {
            convertedMenu.append(contentsOf: convertPresetMenuEntry(presetMenu.entries[i]))
        }
        
        return convertedMenu
    }
    
    private func convertPresetMenuEntry(_ presetMenu: preset_menu_entry) -> [PresetMenuItem] {
        
        let newMenuItem = PresetMenuItem(id: Int(presetMenu.id), title: String(cString: presetMenu.title))
        //print(newMenuItem.title)
        // If there are params, we're all done. Set them and return.
        if presetMenu.params != nil {
            // This is an opaque pointer to a `game_params` object - to change the game type, we'll pass this pointer to midend_set_para
            newMenuItem.params = presetMenu.params
            return [newMenuItem]
        }
        
        // If not, there should be a nested submenu - recursively process that new item.
        // This is used very rarely (I've seen it as an 'extended menu' on loopy, and that's about it). Instead, let's concatenate the menus together.We
        if presetMenu.submenu != nil {
            return convertPresetMenu(presetMenu.submenu.pointee)
            //newMenuItem.submenu = convertPresetMenu(presetMenu.submenu.pointee)
        }
        
        return []
    }
    
    /**
     Tests the game config to see if it supports custom configurations
     */
    public func canConfigureGameParams() -> Bool {
        return game?.can_configure == true
    }
    
    public func getGameUserSettings() -> CustomConfigMenu? {
        return getPuzzleConfig(for: PuzzleConfigTypes.userPreferences)
    }
    
    public func setGameUserSettings(choices: [CustomMenuItem2]) -> String? {
        return setPuzzleConfig(choices: choices, for: PuzzleConfigTypes.userPreferences)
    }
    
    public func getGameCustomParameters() -> CustomConfigMenu? {
        
        // Note: Game can send can_configure = false, which would disable this custom menu.
        guard canConfigureGameParams() else {
            print("Err: Custom settings menu called when game does not support it")
            return nil
        }
        
        return getPuzzleConfig(for: PuzzleConfigTypes.gameParameters)
    }
    
    public func setGameCustomParameters(choices: [CustomMenuItem2]) -> String? {
        return setPuzzleConfig(choices: choices, for: PuzzleConfigTypes.gameParameters)
    }
    
    
    
    public func getGameSeedSettings() -> CustomConfigMenu? {
        return getPuzzleConfig(for: PuzzleConfigTypes.gameSeed)
    }
    
    public func getGameIdSettings() -> CustomConfigMenu? {
        return getPuzzleConfig(for: PuzzleConfigTypes.gameId)
    }
    
    
    public func getPuzzleConfig(for configType: Int) -> CustomConfigMenu? {
                
        let config = getCustomParamsConfig(for: configType)
        
        if let configMenu = config {

            let customConfigMenu: CustomConfigMenu = CustomConfigMenu(configItem: configMenu.pointee)
            
            var menuIsProcessing = true
            var index = 0
            
            while menuIsProcessing {
                let configItem = configMenu[index]
                
                
                let type = Int(configItem.type)
                
                if type == C_END {
                    //print("END found")
                    menuIsProcessing = false // short circuit the while loop
                    break
                }
                
                let title = String(cString: configItem.name)
                
                // Type will be one of the following values that tell us how to process the data: C_STRING, C_CHOICES, C_BOOLEAN, C_END
                switch type {
                case C_STRING:
                    //print("This is a string value: \(title)")
                    let value = String(cString: configItem.u.string.sval)
                    
                    // Determine if this is an integer value or not
                    let intValue = Int(value)
                    
                    if let unwrappedInt = intValue {
                        //print("Integer Value found: \(unwrappedInt)")
                        customConfigMenu.addIntMenuItem(index: index, title: title, currentValue: unwrappedInt)
                    } else {
                        //print("String found: \(value)")
                        //let newMenuItem = StringMenuItem(title: title, value: String(cString: configItem.u.string.sval), index: index)
                        customConfigMenu.addStringMenuItem(index: index, title: title, currentValue: String(cString: configItem.u.string.sval))
                    }
                    
                case C_BOOLEAN:
                    //print("This is a Bool value: \(title)")
                    customConfigMenu.addBooleanMenuItem(index: index, title: title, currentValue: configItem.u.boolean.bval)
                case C_CHOICES:
                    //print("This is a choice value: \(title)")
                    let newMenuItem = processChoiceMenu(configItem, title: title, index: index)
                    customConfigMenu.addMenuItem(newMenuItem)
                    
                    
                    // Choice Names is a non-null delimited string. For example, :Foo:Bar:Baz gives three options.
                    /*
                    let choices = String(cString: configItem.u.choices.choicenames)
                    let delimiter = choices.first
                    let splitChoices = choices.split(separator: delimiter!)
                    
                    
                    
                    let selection = Int(configItem.u.choices.selected)
                    
                    print(splitChoices)
                     */
                    
                    // selected in an int representing the selction from the 'array' in choicenames.
                default:
                    print("Unknown type value provided: \(type)")
                }
                
                index += 1
            }
            
            return customConfigMenu
        
        } else {
            print("No config menu provided")
            return nil
        }
    }
    
    /**
     
     */
    private func getCustomParamsConfig(for configType: Int) -> UnsafeMutablePointer<config_item>? {
        let winTitle = UnsafeMutablePointer<UnsafeMutablePointer<CChar>?>.allocate(capacity: 1) // Puzzles will fill this in with a window title. We don't need it, but it's a required field.
        // Get the config object. Passing "CFG_SETTINGS" indicates we're asking for game settings - the enum comes from puzzles.h
        let config = midend_get_config(midendPointer, Int32(configType), winTitle)
        
        winTitle.deallocate()
        return config
        
        
    }
    
    private func processChoiceMenu(_ configItem: config_item, title: String, index: Int) -> CustomMenuItem2 {
        var choices = [ChoiceMenuOptionS]()
        
        // Choice Names is a non-null delimited string. For example, :Foo:Bar:Baz gives three options.
        let choicesString = String(cString: configItem.u.choices.choicenames)
        let splitChoices = choicesString.split(separator: choicesString.first!)
        
        for i in 0..<splitChoices.count {
            //let choice: ChoiceMenuOption = (id: i, name: String(splitChoices[i]))
            let choice = ChoiceMenuOptionS(id: i, name: String(splitChoices[i]))
            choices.append(choice)
        }
        
        //return ChoiceMenuItem(title: String(cString: configItem.name), choices: choices, selection: Int(configItem.u.choices.selected), index: index)
        return CustomMenuItem2(index: index, type: .CHOICE, title: title, choiceIndex: Int(configItem.u.choices.selected), choices: choices)
    }
    
    private func setPuzzleConfig(choices: [CustomMenuItem2], for configType: Int) -> String? {
        
        let configObject = getCustomParamsConfig(for: configType)
        
        guard let config = configObject else {
            print("Count not retrieve config object; cannot set parameters")
            return "Internal error occurred when setting puzzle configuration"
        }
            
        //Iterating over the object, we apply the choices the user made into the original C object.
        // Sicne our choices menu was created from the original config object, we can relatively safely trust the indexes, rather than try to decode the object again.
        // The index from the user selection choice (previously stored) is used vs the enumerated index, as items may occasionally be filtered out (keyboard-based settings, etc).
        for (_, userSelection) in choices.enumerated() {
            //var currentItem = config[index]
            
            //print(currentItem)
            
            switch userSelection.type {
            case .BOOLEAN:
                //print("\(userSelection.title) Bool == \(userSelection.boolValue)")
                config[userSelection.index].u.boolean.bval = userSelection.boolValue
            case .INT:
                //print("\(userSelection.title) Int == \(userSelection.intValue)")
                let pointer = PuzzleUtils.stringToPointer(String(userSelection.intValue))
                config[userSelection.index].u.string.sval = pointer
            case .STRING:
                //print("\(userSelection.title) String == \(userSelection.stringValue)")
                let pointer = PuzzleUtils.stringToPointer(userSelection.stringValue)
                config[userSelection.index].u.string.sval = pointer
            case .CHOICE:
                //print("\(userSelection.title) Choice == \(userSelection.choiceIndex)")
                config[userSelection.index].u.choices.selected = Int32(userSelection.choiceIndex)
            }
            
            //print(currentItem)
            
            
            
        }
        
        //midend_get_config(midendPointer, Int32(CFG_SETTINGS), winTitle)
        let result = midend_set_config(midendPointer, Int32(configType), config)
        
        if let unwrappedResult = result {
            let error = String(cString: unwrappedResult)
            print(error)
            return error
        } else {
            // Success case! The midend did not return an error
            return nil
        }
    }
    
}

enum CustomMenuType {
    case INT, STRING, BOOLEAN, CHOICE
}

struct CustomMenuItem2 {
    var index: Int
    var type: CustomMenuType
    var title: String
    
    var intValue : Int
    
    var stringValue: String
    
    var boolValue: Bool
    
    var choiceIndex: Int
    var choices: [ChoiceMenuOptionS]
    
    init(index: Int, type: CustomMenuType, title: String, intValue: Int = -1, stringValue: String = "", boolValue: Bool = false, choiceIndex: Int = -1, choices: [ChoiceMenuOptionS] = []) {
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

class CustomConfigMenu {
    var configItem: config_item? // The original config item that must be submitted back to the midend.
    var menu: [CustomMenuItem2] // A list of cleaned up & processed items for display by swift. Each
    
    init(configItem: config_item?, menu: [CustomMenuItem2] = []) {
        self.configItem = configItem
        self.menu = menu
    }
    
    func addMenuItem(_ newItem: CustomMenuItem2) {
        menu.append(newItem)
    }
    
    func addIntMenuItem(index: Int, title: String, currentValue: Int) {
        menu.append(CustomMenuItem2(index: index, type: .INT, title: title, intValue: currentValue))
    }
    
    func addStringMenuItem(index: Int, title: String, currentValue: String) {
        menu.append(CustomMenuItem2(index: index, type: .STRING, title: title, stringValue: currentValue))
    }
    
    func addBooleanMenuItem(index: Int, title: String, currentValue: Bool) {
        menu.append(CustomMenuItem2(index: index, type: .BOOLEAN, title: title, boolValue: currentValue))
    }
}

struct ChoiceMenuOptionS {
    let id: Int
    let name: String
}

