//
//  GameView-Statusbar.swift
//  Puzzles Reloaded
//
//  Created by Kyle Swarner on 8/12/25.
//  Copyright © 2025 Kyle Swarner. All rights reserved.
//

import SwiftUI

struct GameViewStatusbar: View {
    
    @State private var displayNewGameButton = false
    @State private var displayRestartButton = false
    
    var frontend: Frontend
    var newGame: () -> Void
    var restartGame: () -> Void
    var currentGeometry: CGSize
    
    var body: some View {
        
        // Prefer a single row when everything fits; otherwise flow into two rows (status text on top, buttons below).
        // `.fixedSize` on the single-row candidate reports its ideal (unwrapped) width so ViewThatFits can't be fooled
        // by the text quietly wrapping to multiple lines inside the HStack.
        ViewThatFits(in: .horizontal) {
            HStack {
                statusbarText
                statusbarButtons
            }
            .fixedSize(horizontal: true, vertical: false)

            VStack(alignment: .center, spacing: 6) {
                statusbarText
                statusbarButtons
            }
        }
        // MARK: New Game & Restart Button Popup Config
        .onChange(of: frontend.puzzleStatus) { old, new in
            // When the game is solved, animate the appearance of the new game button
            if(new == .SOLVED || new == .UNSOLVABLE) {
                withAnimation(.smooth(duration: 0.5)) {
                    self.displayNewGameButton = true
                    
                    if new == .UNSOLVABLE {
                        self.displayRestartButton = true
                    }
                }
            }
            else {
                // New games shouldn't animate the disappearance
                self.displayNewGameButton = false
                self.displayRestartButton = false
            }
        }
        
    }
    
    @ViewBuilder
    private var statusbarText: some View {
        if(frontend.gameHasStatusbar && !frontend.statusbarText.isEmpty) {
            Text(frontend.statusbarText)
                .padding(8)
                .modifier(StatusbarDesigner())
                .modifier(ButtonTextColor())
        }
    }
    
    private var statusbarButtons: some View {
        HStack {
            if displayNewGameButton {
                Button {
                    newGame()
                } label: {
                    Label("New Game", systemImage: "plus.circle")
                        .modifier(StatusbarOptionalPaddingDesigner())
                }
                .modifier(ButtonDesigner())
                .modifier(ButtonTextColor())
            }
            
            if displayRestartButton {
                Button {
                    frontend.midend.restartGame()
                } label: {
                    Label("Restart", systemImage: "arrow.circlepath")
                        .modifier(StatusbarOptionalPaddingDesigner())
                }
                .modifier(ButtonDesigner())
                .modifier(ButtonTextColor())
            }
        }
    }
}

/*
struct StatusbarButtons: View {
    var body: some View {
        if displayNewGameButton {
            Button("New Game") {
                newGame()
            }
            .padding(5)
            .modifier(ButtonDesigner())
            //.modifier(ButtonTextColor())
            //.background(.thinMaterial, in: RoundedRectangle(cornerRadius: 5.0))
            
            //.transition(AnyTransition.opacity.combined(with: .slide))
        }
        
        if displayRestartButton {
            Button("Restart") {
                frontend.midend.restartGame()
            }
            .padding(5)
            .modifier(ButtonDesigner())
            .modifier(ButtonTextColor())
            //.transition(AnyTransition.opacity.combined(with: .slide))
        }
    }
}
 */

// Apply the glass effect for platforms that support it, otherwise fall back to the old background design
struct StatusbarDesigner: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            content.glassEffect(.regular, in: RoundedRectangle(cornerRadius: 5.0))
        } else {
            content.background(.thinMaterial, in: RoundedRectangle(cornerRadius: 5.0))
        }
    }
}

struct StatusbarOptionalPaddingDesigner: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            content
        } else {
            content
                .padding(5) //This padding is bascially the one difference between this and other button designs
        }
    }
}

struct StatusbarTextColor: ViewModifier {
    
    @Environment(\.colorScheme) var colorScheme
    
    func body(content: Content) -> some View {
        if #available(iOS 26.0, *) { // Trigger black/white test to match liquid glass design on 26+
            content.foregroundStyle(colorScheme == .dark ? .white : .black)
        } else {
            content // No change!
        }
    }
}
