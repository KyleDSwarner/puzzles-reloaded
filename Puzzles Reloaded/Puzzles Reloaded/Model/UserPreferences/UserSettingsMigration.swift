//
//  UserSettingsMigration.swift
//  Puzzles Reloaded
//
//  Created by Kyle Swarner on 11/24/24.
//  Copyright © 2024 Kyle Swarner. All rights reserved.
//

import Foundation
@preconcurrency import SwiftData

enum UserSettingsMigrationPlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] {
        [UserSettingsSchemaV1.self, UserSettingsSchemaV1_1.self, UserSettingsSchemaV2.self]
    }
    
    static var stages: [MigrationStage] {
        [migrateV1toV1_1, migrateV1_1toV2]
        //[V1_1Rollback]
    }
    
    // MARK: Migration Stages
    
    static let migrateV1toV1_1 = MigrationStage.custom(
        fromVersion: UserSettingsSchemaV1.self,
        toVersion: UserSettingsSchemaV1_1.self,
        willMigrate: nil,
        didMigrate: { context in
            let allGameSettings = try context.fetch(FetchDescriptor<UserSettingsSchemaV1_1.GameUserSettings>())
            
            print("Migrating User Settings to V1.1- Stats module migration")
            
            for gameSettings in allGameSettings {
                print("Migrating \(gameSettings.gameName) to V1_1")
                
                // Migrate stats into the new GameStatistics object
                let stats = gameSettings.stats
                gameSettings.gameStatistics = .init(gameName: gameSettings.gameName, gamesPlayed: stats.gamesPlayed, gamesWon: stats.gamesWon)
                    
            }
            
            try context.save()
        }
    )
    
    static let V1_1Rollback = MigrationStage.custom(
        fromVersion: UserSettingsSchemaV1_1.self,
        toVersion: UserSettingsSchemaV1.self,
        willMigrate: { context in
                print("Preparing to Rollback from v1.1 to v1")
        },
        didMigrate: { context in
            let allGameSettings = try context.fetch(FetchDescriptor<UserSettingsSchemaV1.GameUserSettings>())
            
            print("Migrating User Settings to V1.1- Stats module migration")
            
            for gameSettings in allGameSettings {
                print("Migrating \(gameSettings.gameName) to V1")
            }
            
            try context.save()
        }
    )
    
    static let migrateV1_1toV2 = MigrationStage.lightweight(fromVersion: UserSettingsSchemaV1_1.self, toVersion: UserSettingsSchemaV2.self)
}
