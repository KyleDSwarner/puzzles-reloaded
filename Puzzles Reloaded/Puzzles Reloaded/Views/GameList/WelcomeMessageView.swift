//
//  WelcomeView.swift
//  Puzzles Reloaded
//
//  Created by Kyle Swarner on 8/29/24.
//  Copyright © 2024 Kyle Swarner. All rights reserved.
//

import SwiftUI

struct WelcomeMessageView: View {
    
    @AppStorage(AppSettings.key) var appSettings: CodableWrapper<AppSettings> = AppSettings.initialStorage()
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    headerSection
                    welcomeContent
                    Spacer(minLength: 20)
                    getStartedButton
                }
                .padding()
            }
            .navigationTitle("Welcome")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Dismiss") {
                        appSettings.value.showFirstRunMessage = false
                        dismiss()
                    }
                    .modifier(ButtonTextColor())
                }
            }
        }
    }
    
    var headerSection: some View {
        VStack(alignment: .center, spacing: 8) {
            Image("PuzzlesReloaded-Icon-Light")
                .resizable()
                .frame(width: 60, height: 60)
            Text("Welcome to Puzzles Reloaded")
                .font(.title2)
                .fontWeight(.bold)
            Text("A collection of \(Puzzles.allPuzzles.count) puzzles with infinite generation")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.bottom, 20)
    }
    
    var welcomeContent: some View {
        VStack(alignment: .leading, spacing: 12) {
            WelcomeContentRow(
                icon: "puzzlepiece",
                title: "Select a Puzzle",
                description: "Pick a puzzle from the list and start playing! If you're unsure how to play, the help button on the top right will lead you in the right direction."
            )
            
            WelcomeContentRow(
                icon: "slider.horizontal.3",
                title: "Customize Difficulty",
                description: "Different difficulty settings for each game can be found on the bottom right of each puzzle and allows for infinite adjustment to your preferences."
            )
            
            WelcomeContentRow(
                icon: "heart",
                title: "Free Forever",
                description: "This game will always be totally free and will never have ads. Enjoy!"
            )
        }
    }
    
    var getStartedButton: some View {
        Button {
            appSettings.value.showFirstRunMessage = false
            dismiss()
        } label: {
            Text("Get Started")
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
        }
        .modifier(ButtonTextColor())
        .buttonStyle(.borderedProminent)
        .padding(.top, 8)
    }
}

struct WelcomeContentRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(.blue)
                .frame(width: 30)
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.body)
                    .fontWeight(.semibold)
                Text(description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer()
        }
        .padding(.vertical, 6)
        .padding(.bottom, 8)
    }
}

#Preview {
    WelcomeMessageView()
}



