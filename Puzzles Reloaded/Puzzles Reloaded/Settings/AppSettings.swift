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
    var showExperimentalGames: Bool = false // Deprecated
    var disableGameStatusbar: Bool = false
    var showFirstRunMessage: Bool = true
    var enableSwipeBack: Bool = false
    var enableStatistics: Bool = true
    var displayCustomLoadMenu: Bool = false
    var displayShareMenu: Bool = true
    var gameListView: GameListViewSetting = GameListViewSetting.listView
    var appTheme: AppTheme = AppTheme.auto
    
    var longPressTime: Double = 500.0 // in ms
    
    mutating func toggleGameListView() {
        self.gameListView = self.gameListView == .listView ? .gridView : .listView
    }
    
    init() {
        // Take Default Values
    }
    
    enum CodingsKeys: String, CodingKey {
        case enableHaptics, enableSounds, showExperimentalGames, disableGameStatusbar, showFirstRunMessage, enableSwipeBack, enableStatistics, gameListView, appTheme, longPressTime, displayCustomLoadMenu, displayShareMenu
    }
    
    /**
        Custom decoder method allows for smooth migrations when we add or remove fields, otherwise data will be lost when the decoder can't create the new model.
     */
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        showFirstRunMessage = try values.decodeIfPresent(Bool.self, forKey: .showFirstRunMessage) ?? true
        enableHaptics = try values.decodeIfPresent(Bool.self, forKey: .enableHaptics) ?? true
        enableSounds = try values.decodeIfPresent(Bool.self, forKey: .enableSounds) ?? true
        // showExperimentalGames = try values.decodeIfPresent(Bool.self, forKey: .showExperimentalGames) ??
        enableSwipeBack = try values.decodeIfPresent(Bool.self, forKey: .enableSwipeBack) ?? false
        enableStatistics = try values.decodeIfPresent(Bool.self, forKey: .enableStatistics) ?? true
        gameListView = try values.decodeIfPresent(GameListViewSetting.self, forKey: .gameListView) ?? GameListViewSetting.listView
        longPressTime = try values.decodeIfPresent(Double.self, forKey: .longPressTime) ?? 500.0
        
        appTheme = try values.decodeIfPresent(AppTheme.self, forKey: .appTheme) ?? AppTheme.auto
        disableGameStatusbar = try values.decodeIfPresent(Bool.self, forKey: .disableGameStatusbar) ?? false
        displayCustomLoadMenu = try values.decodeIfPresent(Bool.self, forKey: .displayCustomLoadMenu) ?? false
        displayShareMenu = try values.decodeIfPresent(Bool.self, forKey: .displayShareMenu) ?? true
        
    }
}

extension AppSettings {
    static func initialStorage() -> CodableWrapper<AppSettings> {
        CodableWrapper.init(value: AppSettings())
    }
}
