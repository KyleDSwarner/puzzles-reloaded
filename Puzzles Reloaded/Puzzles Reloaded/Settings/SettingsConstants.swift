//
//  SettingsConfig.swift
//  Puzzles
//
//  Created by Kyle Swarner on 3/1/24.
//  Copyright © 2024 Kyle Swarner. All rights reserved.
//

import Foundation

enum GameListViewSetting: Codable {
    case listView, gridView
}

enum AppTheme: Codable {
    case auto, light, dark
}


struct AppSettings: Codable {
    static let key = "AppSettings"
    
    var enableHaptics: Bool = true
    var enableSounds: Bool = true
    var showExperimentalGames: Bool = false
    var disableGameStatusbar: Bool = false
    var gameListView: GameListViewSetting = GameListViewSetting.listView
    var appTheme: AppTheme = AppTheme.auto
    
    var longPressTime = 500.0 // in ms
    
    mutating func toggleGameListView() {
        self.gameListView = self.gameListView == .listView ? .gridView : .listView
    }
}

extension AppSettings {
    static func initialStorage() -> CodableWrapper<AppSettings> {
        CodableWrapper.init(value: AppSettings())
    }
}


