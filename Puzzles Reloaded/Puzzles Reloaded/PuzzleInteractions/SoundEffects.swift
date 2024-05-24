//
//  SoundEffects.swift
//  Puzzles
//
//  Created by Kyle Swarner on 5/23/24.
//  Copyright © 2024 Kyle Swarner. All rights reserved.
//

import Foundation
import SwiftUI
//import AVKit
import AudioToolbox



class SoundEffects {
    
    @AppStorage(AppSettings.key) var settings: CodableWrapper<AppSettings> = AppSettings.initialStorage()
    
    // var audioPlayer: AVAudioPlayer

    init() {
        /*
            do {
                
                let url = URL(fileURLWithPath: "/System/Library/Audio/UISounds/Tock.caf")
                audioPlayer = try AVAudioPlayer(contentsOf: url)
                audioPlayer.prepareToPlay()
                
                //audioPlayer.
                

            } catch let error {
                fatalError("Engine Creation Error: \(error)")
            }
         */
            

    }
    func playSoundEffect() -> Void {
        
        guard settings.value.enableSounds == true else {
            return
        }
        
        //audioPlayer.play()
        
        // This method of playing audio isn't ideal - it uses the ringer volume.
        // BUT, using an AVAudioPlayer tends to make the effect far too loud, and it interrupts existing audio.
        // Using this for now.
        
        //Plays "Tock.caf" from the system library - systemID 1104
        AudioServicesPlaySystemSound(1104);
    }
    
}



