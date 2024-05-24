//
//  Midend-GameConfig.swift
//  Puzzles
//
//  Created by Kyle Swarner on 5/3/24.
//  Copyright © 2024 Kyle Swarner. All rights reserved.
//

import Foundation

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
    
    public func selectPresetOption(option: Int) {
        // tell the game to persist these options. Then later start a new game?
    }
    
    public func submitCustomOption() {
        
        // Afterwards, FREE the memory from the config object???
    }
    
    public func getCustomGameSettingsMenu() {
        
        guard canConfigureGameParams() else {
            print("Err: Custom settings menu called when game does not support it")
            return
        }
        
        // Note: Game can send can_configure = false, which would disable this custom menu.
        
        // Get the config object. Passing "CFG_SETTINGS" indicates we're asking for game settings - the enum comes from puzzles.h
        let winTitle = UnsafeMutablePointer<UnsafeMutablePointer<CChar>?>.allocate(capacity: 1) // Puzzles will fill this in with a window title. We don't need it, but it's a required field.
        let config = midend_get_config(midendPointer, Int32(CFG_SETTINGS), winTitle)
        
        let windowTitle = String(cString: winTitle.pointee!)
        print("Window Title : \(windowTitle)")
        
        if let configMenu = config {

            
            var menuIsProcessing = true
            var index = 0
            
            while menuIsProcessing {
                let configItem = configMenu[index]
                
                
                let type = Int(configItem.type)
                
                if type == C_END {
                    print("END found")
                    menuIsProcessing = false // short circuit the while loop
                    break
                }
                
                let title = String(cString: configItem.name)
                
                // Type will be one of the following values that tell us how to process the data: C_STRING, C_CHOICES, C_BOOLEAN, C_END
                switch type {
                case C_STRING:
                    print("This is a string value: \(title)")
                    let newMenuItem = StringMenuItem(title: title, value: String(cString: configItem.u.string.sval))
                case C_BOOLEAN:
                    print("This is a Bool value: \(title)")
                    let newMenuItem = BooleanMenuItem(title: title, value: configItem.u.boolean.bval)
                case C_CHOICES:
                    print("This is a choice value: \(title)")
                    // Choice Names is a non-null delimited string. For example, :Foo:Bar:Baz gives three options.
                    let choices = String(cString: configItem.u.choices.choicenames)
                    let delimiter = choices.first
                    let splitChoices = choices.split(separator: delimiter!)
                    
                    
                    
                    let selection = Int(configItem.u.choices.selected)
                    
                    print(splitChoices)
                    
                    // selected in an int representing the selction from the 'array' in choicenames.
                default:
                    print("Unknown type value provided: \(type)")
                }
                
                index += 1
            }
            
            
            
            
            
        } else {
            print("No config menu provided")
        }
        
        //
    }
    
    func processChoiceMenu(_ configItem: config_item) -> ChoiceMenuItem {
        var choices = [ChoiceMenuOption]()
        
        // Choice Names is a non-null delimited string. For example, :Foo:Bar:Baz gives three options.
        let choicesString = String(cString: configItem.u.choices.choicenames)
        let splitChoices = choicesString.split(separator: choicesString.first!)
        
        for i in 0..<splitChoices.count {
            let choice: ChoiceMenuOption = (id: i, name: String(splitChoices[i]))
            choices.append(choice)
        }
        
        return ChoiceMenuItem(title: String(cString: configItem.name), choices: choices, selection: Int(configItem.u.choices.selected))
    }
    
}

class CustomConfigMenu {
    var configItem: config_item // The original config item that must be submitted back to the midend.
    var menu: [CustomMenuItem] // A list of cleaned up & processed items for display by swift. Each
    
    init(configItem: config_item, menu: [CustomMenuItem]) {
        self.configItem = configItem
        self.menu = menu
    }
}

protocol CustomMenuItem {
    var title: String { get set }
    //var configItem: config_item
}

class StringMenuItem: CustomMenuItem {
    var title: String
    var value: String
    
    init(title: String, value: String) {
        self.title = title
        self.value = value
    }
}

class BooleanMenuItem: CustomMenuItem {
    var title: String
    var value: Bool
    
    init(title: String, value: Bool) {
        self.title = title
        self.value = value
    }
}

typealias ChoiceMenuOption = (id: Int, name: String)

class ChoiceMenuItem: CustomMenuItem {
    var title: String
    var selection: Int
    var choices: [ChoiceMenuOption]
    
    init(title: String, choices: [ChoiceMenuOption], selection: Int) {
        self.title = title
        self.choices = choices
        self.selection = selection
    }
    
}
