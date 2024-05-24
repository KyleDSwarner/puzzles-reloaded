//
//  UserPreferences.swift
//  Puzzles
//
//  Created by Kyle Swarner on 5/15/24.
//  Copyright © 2024 Kyle Swarner. All rights reserved.
//

import Foundation
import SwiftUI

class UserPreferences {
    
    @AppStorage(AppSettings.key) var appSettings: CodableWrapper<AppSettings> = AppSettings.initialStorage()
    
    static let shared = UserPreferences()
    
    private init() {
    }
}
