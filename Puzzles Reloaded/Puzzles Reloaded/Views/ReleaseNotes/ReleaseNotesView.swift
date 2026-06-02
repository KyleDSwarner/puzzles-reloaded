//
//  ReleaseNotesView.swift
//  Puzzles Reloaded
//
//  Created on 6/2/26.
//  Copyright © 2026 Kyle Swarner. All rights reserved.
//

import SwiftUI

struct ReleaseNotesView: View {
    
    @Environment(GameManager.self) var gameManager: GameManager
    @AppStorage(AppSettings.key) var appSettings: CodableWrapper<AppSettings> = AppSettings.initialStorage()
    
    @Binding var navPath: NavigationPath
    @Environment(\.dismiss) var dismiss
    
    /// Whether this was triggered automatically on launch (vs manually from Settings).
    /// When auto-triggered, dismissing marks the version as seen.
    let isFromSettingsMenu: Bool
    
    
    private var latestReleaseNotes: WhatsNewRelease {
        ReleaseNotesStore.latest
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    // Header
                    headerSection
                    
                    releaseSection(latestReleaseNotes)
                    
                    Spacer(minLength: 20)
                }
                .padding()
            }
            .navigationTitle("What's New")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if !isFromSettingsMenu {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Dismiss") {
                            // Set the latest version into settings so it doesn't show up in the future
                            appSettings.value.lastSeenReleaseNotesVersion = latestReleaseNotes.buildNumber
                            dismiss()
                        }
                        .modifier(ButtonTextColor())
                    }
                }
            }
        }
    }
    
    // MARK: - Header
    
    var headerSection: some View {
        VStack(alignment: .center, spacing: 8) {
            Image("PuzzlesReloaded-Icon-Light")
                .resizable()
                .frame(width: 60, height: 60)
            
            Text("Puzzles Reloaded \(latestReleaseNotes.version)")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Here's what's new!")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.bottom, 20)
    }
    
    // MARK: - Release Section
    
    func releaseSection(_ release: WhatsNewRelease) -> some View {
        VStack(alignment: .leading, spacing: 0) {
             
            // Iterate over the release note entries and display the relevant view
            ForEach(release.entries) { entry in
                if let gameIdentifier = entry.gameIdentifier {
                    gameEntryRow(entry, gameIdentifier: gameIdentifier)
                } else {
                    infoEntryRow(entry)
                }
            }
        }
    }
    
    // MARK: - Game Entry (tappable card)
    
    func gameEntryRow(_ entry: WhatsNewEntry, gameIdentifier: String) -> some View {
        Button {
            // Can't easily navigate to a game from the settings menu - make button no-op
            if !isFromSettingsMenu {
                navigateToGame(identifier: gameIdentifier)
            }
        } label: {
            HStack(alignment: .top, spacing: 12) {
                // Game thumbnail
                if let game = gameManager.gameModel.first(where: { $0.gameConfig.savegameIdentifier == gameIdentifier || $0.gameConfig.identifier == gameIdentifier }) {
                    Image(game.gameConfig.imageName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 60, height: 60)
                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                } else {
                    // Fallback if game not found
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(.quaternary)
                        .frame(width: 60, height: 60)
                        .overlay {
                            Image(systemName: "puzzlepiece")
                                .foregroundStyle(.secondary)
                        }
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(entry.title)
                        .font(.body)
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary)
                    
                    Text(entry.description)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(5)
                    
                    if !isFromSettingsMenu {
                        Text("Tap to play →")
                            .font(.caption)
                            .foregroundStyle(.blue)
                    }
                }
                
                Spacer()
            }
            .padding(12)
            .disabled(isFromSettingsMenu)
            .background(.background)
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .stroke(.quaternary, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .padding(.bottom, 8)
    }
    
    // MARK: - Info Entry (icon + text)
    
    func infoEntryRow(_ entry: WhatsNewEntry) -> some View {
        HStack(alignment: .top, spacing: 12) {
            if let icon = entry.icon {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundStyle(.blue)
                    .frame(width: 30)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(entry.title)
                    .font(.body)
                    .fontWeight(.semibold)
                
                Text(entry.description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
        }
        .padding(.vertical, 6)
        .padding(.bottom, 8)
    }
    
    // MARK: - Navigation
    
    private func navigateToGame(identifier: String) {
        guard let game = gameManager.gameModel.first(where: {
            $0.gameConfig.savegameIdentifier == identifier || $0.gameConfig.identifier == identifier
        }) else {
            return
        }
        
        // Dismiss the sheet, then navigate to the game
        dismiss()
        navPath.append(game)
        
        
        // Small delay to let the sheet dismiss before pushing navigation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            
        }
    }
}

// MARK: - Previews

#Preview("Auto Show") {
    @Previewable @State var navPath = NavigationPath()
    ReleaseNotesView(navPath: $navPath, isFromSettingsMenu: false)
        .environment(GameManager())
}

#Preview("From Settings") {
    @Previewable @State var navPath = NavigationPath()
    ReleaseNotesView(navPath: $navPath, isFromSettingsMenu: true)
        .environment(GameManager())
}
