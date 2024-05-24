//
//  SettingsModel.swift
//  Puzzles
//
//  Created by Kyle Swarner on 3/1/24.
//  Copyright © 2024 Kyle Swarner. All rights reserved.
//

import SwiftData



// Deprecated - this doesn't seem to make sense for the context.
@Model
class AppSettingseeeeee {
    var enableBackGestures: Bool = false
    var enableHaptics: Bool = true
    var enableSounds: Bool = true
    var showExperimentalGames: Bool
    var appTheme: AppTheme = AppTheme.auto
    
    init(enableBackGestures: Bool, enableHaptics: Bool, enableSounds: Bool, showExperimentalGames: Bool, appTheme: AppTheme) {
        self.enableBackGestures = enableBackGestures
        self.enableHaptics = enableHaptics
        self.enableSounds = enableSounds
        self.showExperimentalGames = showExperimentalGames
        self.appTheme = appTheme
    }
    
    // Default Init - used on First Launch
    init() {
        self.enableBackGestures = false
        self.enableHaptics = true
        self.enableSounds = true
        self.showExperimentalGames = false
        self.appTheme = .auto
    }
    
    

}
