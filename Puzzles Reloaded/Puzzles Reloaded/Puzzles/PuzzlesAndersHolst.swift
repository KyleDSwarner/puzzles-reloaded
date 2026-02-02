//
//  PuzzlesAndersHolst.swift
//  Puzzles Reloaded
//
//  Created by Kyle Swarner on 2/2/26.
//  Copyright © 2026 Kyle Swarner. All rights reserved.
//

import Foundation

extension Puzzles {
    
    static var puzzlesAndersHolst: [GameConfig] {[
        puzzle_alphacrypt,
        puzzle_factorcross,
        puzzle_identifier,
        puzzle_kakuro,
        puzzle_supermaze
    ]}
    
    // MARK: Alphacrypt
    static let puzzle_alphacrypt = GameConfig(
        identifier: "alphacrypt",
        internalGame: alphacrypt,
        isExperimental: true
    )
    .numericButtonsBuilder({ gameId in
        // Filling always displays all 10 number buttons as any number can be used at any size.
        // Example Game ID: 26D2:A=I-Z,B=P*E,C=22,D=X-C,E=W-C,F=Q-H,G=S+L,H=N-M,I=X+E,J=K-F,K=E+R,L=P+F,M=S*F,N=B*F,O=A+F,P=D+E,Q=U*F,R=X-L,S=K/P,T=A-M,U=N/E,V=I/F,W=P+O,X=A+P,Y=A-P,Z=V-L.
        return Puzzles.createButtonControls(10)
    })
    
    static let puzzle_factorcross = GameConfig(
        identifier: "factorcross",
        internalGame: factorcross,
        isExperimental: true
    )
    
    static let puzzle_identifier = GameConfig(
        identifier: "identifier",
        internalGame: identifier,
        isExperimental: true
    )
    
    static let puzzle_kakuro = GameConfig(
        identifier: "kakuro",
        internalGame: kakuro,
        isExperimental: true
    )
        .numericButtonsBuilder({ gameId in
            // Filling always displays all 10 number buttons as any number can be used at any size.
            // Example Game ID: 7,9D3:XXV4XXV3XV30XV17aB8.16bV19aH17cB16.9cXaB10.9bB7.30bXV13aB29.17dH24cB10.4bV3XaH24eH3bH8bXa
            return Puzzles.createButtonControls(10)
        })
    
    static let puzzle_supermaze = GameConfig(
        identifier: "supermaze",
        internalGame: supermaze,
        isExperimental: true
    )
        .addSearchTerms(["Maze"])
    // Basic: 10NE:701BFB20A4267D343FC13DEEB6C6217BFF68C7C89FD5E
    // Tandem: 4TE:318807,E50424,43C12B,915821,34B683,39E027,3C6887,7C892E,656565,D3D18C,B1DA4C,1608A3,BD2106,359600,B98E01,2C1A23,440B00
    // 3D: 4DE:2195B9D6442C204BE1B5E9C9,00010101010000000001010000010000000202020300010000020300010300010000000002010200000103010302000300000000000200000002020202000002
    
    
}
