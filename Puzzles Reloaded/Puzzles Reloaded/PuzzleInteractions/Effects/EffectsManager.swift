//
//  EffectsManager.swift
//  Puzzles Reloaded
//
//  Created by Kyle Swarner on 7/10/24.
//  Copyright © 2024 Kyle Swarner. All rights reserved.
//

import Foundation
import SwiftUI

class EffectsManager {
    
    @AppStorage(AppSettings.key) var settings: CodableWrapper<AppSettings> = AppSettings.initialStorage()
    
    private var hapticEffects: HapticEffects
    private var soundEffects: SoundEffects
    
    init() {
        self.hapticEffects = HapticEffects()
        self.soundEffects = SoundEffects()
    }
    
    func triggerShortPressEffects() {
        hapticEffects.playShortPressHaptic()
        soundEffects.playSoundEffect()
    }
    
    func triggerLongPressEffects() {
        hapticEffects.playLongPressHaptic()
        soundEffects.playSoundEffect()
    }
    
}
