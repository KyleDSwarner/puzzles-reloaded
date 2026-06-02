//
//  PuzzlesSteffenBauer.swift
//  Puzzles Reloaded
//
//  Created by Kyle Swarner on 6/2/26.
//  Copyright © 2026 Kyle Swarner. All rights reserved.
//

import Foundation

extension Puzzles {
    
    static var puzzlesSteffenBauer: [GameConfig] {[
        puzzle_flow,
        puzzle_walls
    ]}
    
    //MARK: Flow
    static let puzzle_flow = GameConfig(
        identifier: "flow",
        internalGame: flow,
    )
    .addSearchTerms(["Creek"])
    .setDarkModeColors([
        4: (Theming.veryDarkGray, "Grid"),
        5: (Theming.white, "Ink"),
        7: (Theming.darkGray, "Empty Square"),
        8: (Theming.black, "Black Square"),
        9: (Theming.lightGray, "White Square")
    ])
    
    //MARK: Walls
    static let puzzle_walls = GameConfig(
        identifier: "walls",
        internalGame: walls,
    )
    .addSearchTerms(["Alcazar"])
    .setDarkModeColors([
        //1: (Theming.white, "Grid"),
        1: (Theming.darkGray, "Grid"),
        2: (Theming.veryDarkGray, "Floor A"),
        3: (Theming.darkGray, "Floor B"),
        4: (Theming.midGray, "Fixed Wall"),
        5: (Theming.turboBlue, "Wall A"),
        6: (Theming.midGray, "Wall B"),
        7: (Theming.enteredTextBlue, "Path"),
        12: (Theming.midGray, "Win Flash")
    ])
    
    /*
     enum {
         COL_BACKGROUND,
         COL_GRID,
         COL_FLOOR_A,
         COL_FLOOR_B,
         COL_FIXED,
         COL_WALL_A,
         COL_WALL_B,
         COL_PATH,
         COL_DRAGON,
         COL_DRAGOFF,
         COL_ERROR,
         COL_CURSOR,
         COL_FLASH,
         NCOLOURS
     };to
     */
}
