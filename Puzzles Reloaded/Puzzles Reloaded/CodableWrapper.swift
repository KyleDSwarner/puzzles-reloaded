//
//  CodableWrapper.swift
//  Puzzles
//
//  Created by Kyle Swarner on 3/1/24.
//  Copyright © 2024 Kyle Swarner. All rights reserved.
//

import Foundation
import SwiftUI

// CodableWrapper introduces a wrapper for any Codable value that you want to encode & store as AppStorage.
// Using Codable and RawRepresentable together causes an infinite loop between the two (the RawRepresentable encoder using rawValue, which you're generated during encode, etc.)
struct CodableWrapper<Value: Codable> {
    var value: Value
}


extension CodableWrapper: RawRepresentable {
    
    typealias RawValue = String
        
    var rawValue: RawValue {
        guard
            let data = try? JSONEncoder().encode(value),
            let string = String(data: data, encoding: .utf8)
        else {
            // TODO: Track programmer error
            return ""
        }
        return string
    }

    init?(rawValue: RawValue) {
            guard
                let data = rawValue.data(using: .utf8),
                let decoded = try? JSONDecoder().decode(Value.self, from: data)
            else {
                // TODO: Track programmer error
                return nil
            }
            value = decoded
        }
}
