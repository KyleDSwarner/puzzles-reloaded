//
//  ReleaseNotes.swift
//  Puzzles Reloaded
//
//  Created on 6/2/26.
//  Copyright © 2026 Kyle Swarner. All rights reserved.
//

import Foundation

// MARK: - Data Model

struct WhatsNewEntry: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let gameIdentifier: String? // Link to a GameConfig identifier for new/updated games
    let icon: String? // SF Symbol for non-game changes
}

struct WhatsNewRelease: Identifiable {
    let id = UUID()
    let version: String
    let buildNumber: Int
    let entries: [WhatsNewEntry]
}

// MARK: - Release Store

struct ReleaseNotesStore {

    /// All releases, newest first. Prepend new releases here when shipping a new version.
    static let releases: [WhatsNewRelease] = [
        releaseNotes111
    ]
    
    static let releaseNotes111 = WhatsNewRelease(
        version: "1.11",
        buildNumber: 111,
        entries: [
            WhatsNewEntry(
                title: "New Game: Walls",
                description: "Find a path through a maze of walls. Contributed by Steffen Bauer",
                gameIdentifier: "walls",
                icon: nil
            ),
            WhatsNewEntry(
                title: "New Game: Flow",
                description: "Find a path, matching the clues. Contributed by Steffen Bauer",
                gameIdentifier: "flow",
                icon: nil
            ),
            WhatsNewEntry(
                title: "New Game: Group",
                description: "Complete the grid to create a Cayley table",
                gameIdentifier: "group",
                icon: nil
            ),
            WhatsNewEntry(
                title: "New Feature: Double Tap for Short/Long press Actions",
                description: "Grid-Based games now support a new option to switch between short & long presses by tapping multiple times. Turn this on in settings for supported games!",
                gameIdentifier: nil,
                icon: "hand.tap"
            ),
            WhatsNewEntry(
                title: "Try it out!",
                description: "Enable the new control option in Solo to try it out!",
                gameIdentifier: "solo",
                icon: nil
            ),
        ]
    )

    /// The most recent release
    static var latest: WhatsNewRelease {
        releases[0]
    }
}
