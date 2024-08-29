//
//  WelcomeView.swift
//  Puzzles Reloaded
//
//  Created by Kyle Swarner on 8/29/24.
//  Copyright © 2024 Kyle Swarner. All rights reserved.
//

import SwiftUI

struct WelcomeMessageView: View {
    var body: some View {
        Text("Welcome!").font(.title).padding(.bottom, 5)
        Text("This is a collection of \(Puzzles.allPuzzles.count) puzzles with infinite generation. You'll never fail to find a new challenge!")
            .fixedSize(horizontal: false, vertical: true)
        
        Text("""
Choose a game from the list below and start playing! If you're unsure how to play, the help button on the top right will lead you in the right direction.
""", comment: "Welcome Message, Chunk 2")
        .fixedSize(horizontal: false, vertical: true)
                .padding([.top, .bottom], 5)
        
        Text("""
Different difficulty settings for each game can be found on the bottom right of each puzzle and allows for infinite adjustment of each game to your preferences.
""", comment: "Welcome Message, Chunk 3")
        .fixedSize(horizontal: false, vertical: true)
                .padding([.top, .bottom], 5)
        
        Text("This game will always be totally free and will never have ads. Enjoy!").padding([.top, .bottom], 5)
    }
}

#Preview {
    WelcomeMessageView()
}
