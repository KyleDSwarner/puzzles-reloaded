//
//  UserPreferences.swift
//  Puzzles
//
//  Created by Kyle Swarner on 5/15/24.
//  Copyright © 2024 Kyle Swarner. All rights reserved.
//

import Foundation
import SwiftUI

struct UserPreferences: Codable {
    static let key = "UserPreferences"
    
    private var gameData: [UserGameData] = []
    
    func dataExists(for gameName: String) -> Bool {
        return gameData.contains(where: { $0.gameName == gameName })
    }
    
    mutating func userData(for gameName: String) -> UserGameData {
        let data = gameData.first(where: { $0.gameName == gameName })
        
        if let unwrappedData = data {
            return unwrappedData
        } else {
            let newData = UserGameData(gameName: gameName)
            gameData.append(newData)
            return newData
        }
    }
    
    mutating func addGameData(_ data: UserGameData) {
        gameData.append(data)
    }
    
}



extension UserPreferences {
    static func initialStorage() -> CodableWrapper<UserPreferences> {
        CodableWrapper.init(value: UserPreferences())
    }
}
