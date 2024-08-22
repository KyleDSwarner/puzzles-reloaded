//
//  AboutView.swift
//  Puzzles Reloaded
//
//  Created by Kyle Swarner on 7/29/24.
//  Copyright © 2024 Kyle Swarner. All rights reserved.
//

import SwiftUI

struct AboutView: View {
    
    let appVersion: String = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    let buildNumber: String = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    
    
    var body: some View {
        
        VStack(alignment: .center) {
            
            
            Form {
                Section {
                    VStack {
                        Text("Simon Tatham Puzzles Reloaded", comment: "App title on about page")
                            .fontWeight(.bold)
                        Text("Made with love by Kyle Swarner")
                        Text("Version \(appVersion), Build \(buildNumber)", comment: "Version and build information on about page")
                            .font(.subheadline)
                    }
                    .containerRelativeFrame(
                        [.horizontal]
                    )
                }
                
                Section {
                    Link("Submit An Issue", destination: URL(string: "https://github.com/KyleDSwarner/puzzles-reloaded/issues")!)
                    Link("Contribute Code", destination: URL(string: "https://github.com/KyleDSwarner/puzzles-reloaded")!)
                } header: {
                    Text("Get Involved", comment: "Heading on about page")
                }
                
                Section {
                    NavigationLink("License") {
                        LicenseView()
                    }
                    Link("Privacy Policy", destination: URL(string: "kyledswarner.github.io/puzzles/privacy")!)
                    
                }
                
                Section {
                    VStack(alignment: .leading) {
                        Text("Simon Tatham")
                        Text("Original developer of the puzzle collection")
                            .font(.caption)
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Greg Hewgill")
                        Text("Developer of first Simon Tatham collection for iOS, without which this app would not exist")
                            .font(.caption)
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Leonard Sprong")
                        Text("Contributor of 10 new puzzles to this collection")
                            .font(.caption)
                    }
                    
                } header: {
                    Text("Special Thanks", comment: "Heading on about page")
                }
            }
        }
        .navigationTitle("About")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }
}

#Preview {
    NavigationStack {
        AboutView()
    }
}
