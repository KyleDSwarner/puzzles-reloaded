//
//  HapticEffects.swift
//  Puzzles
//
//  Created by Kyle Swarner on 5/15/24.
//  Copyright © 2024 Kyle Swarner. All rights reserved.
//

import Foundation
import CoreHaptics
import SwiftUI
import AudioToolbox



class HapticEffects {
    
    @AppStorage(AppSettings.key) var settings: CodableWrapper<AppSettings> = AppSettings.initialStorage()
    
    var supportsHaptics: Bool = false
    var engine: CHHapticEngine!

    init() {
        supportsHaptics = HapticEffects.deviceSupportsHaptics()
        
        if supportsHaptics == true {
            do {
                engine = try CHHapticEngine()
            } catch let error {
                fatalError("Engine Creation Error: \(error)")
            }
        }
    }
    
    static func deviceSupportsHaptics() -> Bool {
        // Check if the device supports haptics.
        let hapticCapability = CHHapticEngine.capabilitiesForHardware()
        return hapticCapability.supportsHaptics
    }
    
    func playLongPressHaptic() -> Void {
        
        //AudioServicesPlaySystemSound(0x450);
        
        // Ensure haptics is supported (not on iPads!) and that the haptic option is enabled in user's settings.
        guard supportsHaptics == true && settings.value.enableHaptics == true else {
            return
        }
        
        var events = [CHHapticEvent]()
        
        let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 1)
        let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 1)
        let event = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpness], relativeTime: 0)
        
        events.append(event)
            
        do {
            let pattern = try CHHapticPattern(events: events, parameters: [])
            let player = try engine.makePlayer(with: pattern)
            
            // Stop the engine after it completes the playback.
            engine.notifyWhenPlayersFinished { error in
                return .stopEngine
            }
            
            try engine.start()
            try player.start(atTime: 0)
        } catch {
            print("Error in haptic engine, failing silently")
        }
    }
    
}



