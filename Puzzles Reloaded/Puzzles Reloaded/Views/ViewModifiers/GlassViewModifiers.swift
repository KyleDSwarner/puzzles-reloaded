//
//  glassViewModifiers.swift
//  Puzzles Reloaded
//
//  Created by Kyle Swarner on 8/15/25.
//  Copyright © 2025 Kyle Swarner. All rights reserved.
//

import SwiftUI

// Apply the glass effect for platforms that support it, otherwise fall back to the old background design
struct ButtonDesigner: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            content
                .buttonStyle(.glass)
        } else {
            content.background(.thickMaterial, in: RoundedRectangle(cornerRadius: 5.0))
        }
    }
}

struct ButtonTextColor: ViewModifier {
    
    @Environment(\.colorScheme) var colorScheme
    
    func body(content: Content) -> some View {
        if #available(iOS 26.0, *) { // Trigger black/white test to match liquid glass design on 26+
            content.foregroundStyle(colorScheme == .dark ? .white : .black)
        } else {
            content // No change!
        }
    }
}
