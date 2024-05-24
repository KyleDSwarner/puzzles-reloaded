//
//  GameControls.swift
//  Puzzles
//
//  Created by Kyle Swarner on 4/26/24.
//  Copyright © 2024 Kyle Swarner. All rights reserved.
//

import SwiftUI

struct GameControlsView: View, Equatable {
    
    @Binding private var controlOption: ControlConfig
    
    var touchControls: [ControlConfig]
    var buttonControls: [ControlConfig]
    var numberRowCount: Int = 0
    
    init(controlOption: Binding<ControlConfig>, touchControls: [ControlConfig] = [], buttonControls: [ControlConfig] = [], numberRowCount: Int = 0) {
        self._controlOption = controlOption
        self.touchControls = touchControls
        self.buttonControls = buttonControls
        self.numberRowCount = numberRowCount
    }
    
    /*
     The EquatableView function prevents redrawing of the view when the new view is equivalent.
     This prevents the controls from being redrawn every time the user interacts with the puzzle.
     (Note that `init` is still run`
     */
    static func == (lhs: GameControlsView, rhs: GameControlsView) -> Bool {
        lhs.touchControls.count == rhs.touchControls.count &&
        lhs.buttonControls.count == rhs.buttonControls.count
    }
    
    var body: some View {
        HStack(alignment: .center) {

            
            Picker("Selector", selection: $controlOption) {
                ForEach(0..<touchControls.count, id:\.self) { index in
                    if touchControls[index].hasImage() {
                        touchControls[index].buildImage()
                            //.foregroundStyle(.black, .black)
                            .tag(touchControls[index])
                            .frame(minWidth: 40, minHeight: 40)
                            .padding(10)
                    } else {
                        Text(touchControls[index].label)
                            .tag(touchControls[index])
                            .padding(5)
                    }
                }
            }
            .pickerStyle(.segmented)
            .fixedSize()
            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 5.0))
            
            ForEach(0..<numberRowCount, id:\.self) { index in
                Button() {
                    // Do The Thing
                } label : {
                    Text("\((index + 1) % 10)")
                }
                .frame(minWidth: 30, minHeight: 30)
                .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 5.0))
            }
            
            ForEach(0..<buttonControls.count, id:\.self) { index in
                Button() {
                    // Do Thing
                } label: {
                    if(buttonControls[index].hasImage()) {
                        buttonControls[index].buildImage()
                            .resizable()
                            .frame(maxWidth: 20, maxHeight: 20)
                            //.foregroundStyle(game.game.buttonControls[index].imageColor)
                            .padding(5)
                    } else {
                        Text(buttonControls[index].label)
                    }
                }
                .padding(5)
                .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 5.0))
            }
            
        }
    }
}

/*
 #Preview {
 
 struct Preview: View {
 
 
 let netTouchControls: [ControlConfig] = [
 ControlConfig(label: "Clockwise", shortPress: .rightClick, longPress: .middleClick, imageName: "arrow.clockwise"), // Left/Right is reversed intentionally to make clockwise the 'default' option
 ControlConfig(label: "Counter-Clockwise", shortPress: .leftClick, longPress: .middleClick, imageName: "arrow.counterclockwise"),
 ControlConfig(label: "Lock", shortPress: .middleClick, longPress: .none, imageName: "lock"),
 ControlConfig(label: "Center", shortPress: .net_center, longPress: .none),
 ControlConfig(label: "Shift", shortPress: .net_center, longPress: .none)
 ]
 let netButtonControls: [ControlConfig] = [ControlConfig(label: "Shuffle", shortPress: .net_jumble, imageName: "shuffle")]
 let markControl: [ControlConfig] = [ControlConfig(label: "Mark", shortPress: .net_jumble)]
 
 @State var controlConfig: ControlConfig = ControlConfig(label: "Clockwise", shortPress: .rightClick, longPress: .middleClick, imageName: "arrow.clockwise")
 
 var body: some View {
 VStack {
 GameControlsView(controlOption: $controlConfig, touchControls: netTouchControls, buttonControls: netButtonControls).equatable()
 GameControlsView(controlOption: $controlConfig, numberRowCount: 5)
 GameControlsView(controlOption: $controlConfig, numberRowCount: 10)
 GameControlsView(controlOption: $controlConfig, buttonControls: markControl, numberRowCount: 6)
 GameControlsView(controlOption: $controlConfig, touchControls: Puzzles.puzzle_unruly.touchControls).equatable()
 GameControlsView(controlOption: $controlConfig, buttonControls: Puzzles.puzzle_undead.buttonControls).equatable()
 GameControlsView(controlOption: $controlConfig, buttonControls: Puzzles.game_towers.buttonControls, numberRowCount: 9).equatable()
 }
 
 }
 }
 
 return Preview()
 }
 */
