//
//  SettingsView.swift
//  Puzzles
//
//  Created by Kyle Swarner on 2/26/24.
//  Copyright © 2024 Kyle Swarner. All rights reserved.
//

import SwiftUI
import SwiftData

struct SettingsView: View {

    @Environment(\.dismiss) var dismiss
    
    // The settings page doesn't use the UserPreferences shared class to avoid an odd bug where the settings buttons didn't work correctly on first press
    @AppStorage(AppSettings.key) var appSettings: CodableWrapper<AppSettings> = AppSettings.initialStorage()
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    if HapticEffects.deviceSupportsHaptics() {
                        Toggle("Enable Haptic Feedback", isOn: $appSettings.value.enableHaptics)
                    }
                    Toggle("Sounds", isOn: $appSettings.value.enableSounds)
                    
                }
                Section {
                    
                    Picker("Theme", selection: $appSettings.value.appTheme) {
                        Text("Auto (Follow Device)").tag(AppTheme.auto)
                        Text("Light").tag(AppTheme.light)
                        Text("Dark").tag(AppTheme.dark)
                    }
                    
                }
                Section {
                    Toggle("Experimental Games", isOn: $appSettings.value.showExperimentalGames)
                } footer: {
                    Text("Enable games that may be incomplete or broken")
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Text("Done")
                    }
                }
                
            }
        }
    }
}

#Preview {
    SettingsView()
}
