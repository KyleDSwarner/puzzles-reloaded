//
//  GameListConfig.swift
//  Puzzles
//
//  Created by Kyle Swarner on 2/23/24.
//  Copyright © 2024 Kyle Swarner. All rights reserved.
//

import Foundation
import SwiftData

typealias GameUserSettings = UserSettingsSchemaV1.GameUserSettings

enum GameCategory: Codable {
    case none, favorite, hidden
}
