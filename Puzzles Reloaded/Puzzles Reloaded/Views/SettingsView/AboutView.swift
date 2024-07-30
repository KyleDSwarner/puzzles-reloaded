//
//  AboutView.swift
//  Puzzles Reloaded
//
//  Created by Kyle Swarner on 7/29/24.
//  Copyright © 2024 Kyle Swarner. All rights reserved.
//

import SwiftUI

struct AboutView: View {
    var body: some View {
        
        VStack(alignment: .leading) {
            Text("Issues or Questions?")
            Text("Submit issues to our issue board on GitHub")
            Link("Learn SwiftUI", destination: URL(string: "https://www.hackingwithswift.com/quick-start/swiftui")!)
            
            Text("Special Thanks")
            Text("Tatham, x-sheep, etc.")
            
            Text("License")
            Text("MIT Blah")
            

        }
        .navigationTitle("About")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        AboutView()
    }
}
