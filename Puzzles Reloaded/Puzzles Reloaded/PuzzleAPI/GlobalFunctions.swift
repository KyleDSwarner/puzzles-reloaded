//
//  GlobalFunctions.swift
//  Puzzles
//
//  Created by Kyle Swarner on 4/18/24.
//  Copyright © 2024 Kyle Swarner. All rights reserved.
//

import Foundation

/**
 These functions are the puzzle mid-end to front-end calls that must be globally provided. The puzzle midend will call these functions as part
 of constructing puzzles.
 
 The somewhat-hacky use of @_cdecl allows a function to be made globally available to the c code run by the puzzle.
 
 https://www.chiark.greenend.org.uk/~sgtatham/puzzles/devel/midend.html#frontend-api
 */

@_cdecl("frontend_default_colour")
func frontend_default_colour(frontend: OpaquePointer, output: UnsafeMutablePointer<Float>) {
    print("Default Color")
    let defaultColor = Float(0.8)
    
    //Provide the RGB values of the default color background.
    // TODO: How can we support dark mode here? All of the colors will need to change.... :/
    output[0] = defaultColor
    output[1] = defaultColor
    output[2] = defaultColor
    // output[0] = output[1] = output[2] = 0.8f; ???
}

@_cdecl("get_random_seed")
func get_random_seed(randseed: UnsafeMutablePointer<UnsafeMutableRawPointer?>, randSeedSize: UnsafeMutablePointer<Int32>) {
    print("Requesting Random Seed")
    
    // Create our seed with the current time interval
    let seed = Int(Date.now.timeIntervalSince1970)
    let sizeOfSeed = MemoryLayout.size(ofValue: seed)
    
    let pointer = UnsafeMutablePointer<Int>.allocate(capacity: 1)
    pointer.pointee = seed
    
    randseed.pointee = UnsafeMutableRawPointer(pointer)
    randSeedSize.pointee = Int32(sizeOfSeed)
    
    /*
    var anotherPointer = UnsafeMutablePointer<UnsafeMutableRawPointer?>.allocate(capacity: 1)
    anotherPointer.pointee = UnsafeMutableRawPointer(pointer)
    
    
    var sizePointer = UnsafeMutablePointer<Int32>.allocate(capacity: 1)
    sizePointer.pointee = Int32(sizeOfSeed)
    print(pointer)
    print(sizeOfSeed)
    */
    
    /*
    time_t *tp = snew(time_t);
    time(tp);
    *randseed = (void *)tp;
    *randseedsize = sizeof(time_t);
     */
}

@_cdecl("activate_timer")
func activate_timer(frontend: OpaquePointer) {
    let convertedFrontendPointer = UnsafeMutableRawPointer(frontend)
    retrieveFrontendFromPointer(convertedFrontendPointer).startTimer()
}

@_cdecl("deactivate_timer")
func deactivate_timer(frontend: OpaquePointer) {
    let convertedFrontendPointer = UnsafeMutableRawPointer(frontend)
    retrieveFrontendFromPointer(convertedFrontendPointer).stopTimer()
}

@_cdecl("fatal")
func fatal(message: UnsafePointer<CChar>) {
    print("Un Oh Something Fatal Happened :(")
    //TODO get the message & print to console.
}
