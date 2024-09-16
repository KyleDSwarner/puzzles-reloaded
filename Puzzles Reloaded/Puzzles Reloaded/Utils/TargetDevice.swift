//
//  TargetDevice.swift
//  Puzzles Reloaded
//
//  Created by Kyle Swarner on 8/29/24.
//  Copyright © 2024 Kyle Swarner. All rights reserved.
//

import Foundation
import UIKit

enum TargetDevice {
    case nativeMac
    case iPad
    case iPhone
    case iWatch
    
    @MainActor public static var currentDevice: Self {
        var currentDeviceModel = UIDevice.current.model
        #if targetEnvironment(macCatalyst)
        currentDeviceModel = "nativeMac"
        #elseif os(watchOS)
        currentDeviceModel = "watchOS"
        #endif
        
        if currentDeviceModel.starts(with: "iPhone") {
            return .iPhone
        }
        if currentDeviceModel.starts(with: "iPad") {
            return .iPad
        }
        if currentDeviceModel.starts(with: "watchOS") {
            return .iWatch
        }
        return .nativeMac
    }
}
