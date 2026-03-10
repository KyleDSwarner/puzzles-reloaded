//
//  GameListSortOptionsView.swift
//  Puzzles Reloaded
//
//  Created by Kyle Swarner on 3/10/26.
//  Copyright © 2026 Kyle Swarner. All rights reserved.
//

import SwiftUI

struct GameListDisplayOptionsView: View {
    
    @Environment(\.dismiss) var dismiss
    @AppStorage(AppSettings.key) var appSettings: CodableWrapper<AppSettings> = AppSettings.initialStorage()
    

    var body: some View {
        NavigationStack {
            VStack {
                Form {
                    Picker("Layout", selection: $appSettings.value.gameListView) {
                        Text("List View").tag(GameListViewSetting.listView)
                        Text("Grid View").tag(GameListViewSetting.gridView)
                    }
                    Picker("Sort By", selection: $appSettings.value.gameListSortOrder) {
                        Text("Name (A-Z)").tag(GameListSortOrder.name)
                        Text("Name (Z-A)").tag(GameListSortOrder.nameReversed)
                        Text("Most Played").tag(GameListSortOrder.playCountHigh)
                        Text("Least Played").tag(GameListSortOrder.playCountLow)
                    }
                    Toggle("Display Hidden Games", isOn: $appSettings.value.gameListDisplayHidden)
                }
            }
            .navigationTitle("Game List Options")
            .presentationDetents([.medium])
            #if os(iOS)
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
            #endif
            
        }
    }
}

#Preview {
    GameListDisplayOptionsView()
}
