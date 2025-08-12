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
        
        VStack {
            Spacer()
            HStack {
                if(frontend.gameHasStatusbar) {
                    Text(frontend.statusbarText)
                        .padding(5)
                        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 5.0))
                }
                
                if displayNewGameButton {
                    Button("New Game") {
                        newGame()
                    }
                    .padding(5)
                    .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 5.0))
                    //.transition(AnyTransition.opacity.combined(with: .slide))
                }
                
                if displayRestartButton {
                    Button("Restart") {
                        frontend.midend.restartGame()
                    }
                    .padding(5)
                    .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 5.0))
                    //.transition(AnyTransition.opacity.combined(with: .slide))
                }
            }
        }
        .frame(height: currentGeometry.width < 600 ? 80 : 40) // <-- Keep a minimum height on this stack to prevent puzzle resizing when the new game button appears
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
}
