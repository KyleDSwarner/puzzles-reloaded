//
//  LazyGameControlsView.swift
//  Puzzles
//
//  Created by Kyle Swarner on 5/1/24.
//  Copyright © 2024 Kyle Swarner. All rights reserved.
//

import SwiftUI

struct ButtonLabel: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    let control: ControlConfig
    var largeButtons: Bool = false
    
    var labelStyle: any LabelStyle {
        if control.imageName.isEmpty {
            return TitleOnlyLabelStyle.titleOnly
        }
        else if control.displayTextWithIcon {
            return TitleAndIconLabelStyle.titleAndIcon
        }
        return IconOnlyLabelStyle.iconOnly
                    
    
    }
    
    var body: some View {
        if control.imageName.isEmpty {
            Text(control.label)
                //.foregroundStyle(colorScheme == .dark ? .white : .black)
        }
        else if control.displayTextWithIcon {
            Label {
                Text(control.label)
            } icon: {
                buildImage()
                    .resizable()
                    .scaledToFit()
                    .frame(height: largeButtons ? 30 : 15)
                    .id(control.imageName)
            }
            
        } else {
            buildImage()
                .resizable()
                .scaledToFit()
                //.foregroundStyle(control.imageColor, control.imageColor)
                .frame(height: largeButtons ? 30 : 15)
                .accessibilityLabel(control.label)
                .id(control.imageName)
        }
    }
    
    func buildImage() -> Image {
        guard !control.imageName.isEmpty else {
            // This _shouldn't_ happen based on config, but let's return a placeholder image.
            return Image(systemName: "exclamationmark.triangle.fill")
        }
        
        if(control.isSystemImage) {
            return Image(systemName: control.imageName)
        } else {
            return Image(control.imageName)
        }
    }
}

struct LazyGameControlsView: View, Equatable {
    
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Binding private var controlOption: ControlConfig
    @State private var totalHeight: CGFloat = 30
    var buttonPressEmitter: FireButtonFunction
    
    var gameId: String
    
    var touchControls: [ControlConfig]
    var buttonControls: [ControlConfig]
    var numberRowCount: Int = 0
    var numericButtonsWorker: NumButtonsFunction
    
    var filteredTouchControls: [ControlConfig] {
        touchControls.filter { control in
            return control.displayCondition(gameId)
        }
    }
    
    var filteredButtonControls: [ControlConfig] {
        buttonControls.filter { control in
            control.displayCondition(gameId)
        }
    }
    
    var numericButtons: [ControlConfig] {
        return numericButtonsWorker(gameId)
    }
    
    var totalObjectCount: Int {
        numberRowCount + touchControls.count + buttonControls.count
    }
    
    // Grid Sizing Values
    let gridItemMinimumSize: CGFloat = 30
    let gridItemMaximumSize: CGFloat = 50
    let gridSpacing: CGFloat = 5
    
    init(controlOption: Binding<ControlConfig>, touchControls: [ControlConfig] = [], buttonControls: [ControlConfig] = [], numberRowCount: Int = 0, numericButtonsFunction: @escaping NumButtonsFunction = { _ in []}, gameId: String = "", buttonPressFunction: @escaping FireButtonFunction) {
        self._controlOption = controlOption
        self.touchControls = touchControls
        self.buttonControls = buttonControls
        self.numberRowCount = numberRowCount
        self.gameId = gameId
        self.numericButtonsWorker = numericButtonsFunction
        self.buttonPressEmitter = buttonPressFunction
    }
    
    /*
     The EquatableView function prevents redrawing of the view when the new view is equivalent.
     This prevents the controls from being redrawn every time the user interacts with the puzzle.
     (Note that `init` is still run`
     */
    static func == (lhs: LazyGameControlsView, rhs: LazyGameControlsView) -> Bool {
        lhs.gameId == rhs.gameId
    }
    
    var body: some View {
        
        HStack {
            Spacer()
            if(touchControls.count > 0) {
                Picker("Selector", selection: $controlOption) {
                    ForEach(0..<filteredTouchControls.count, id:\.self) { index in
                        ButtonLabel(control: filteredTouchControls[index])
                        //.frame(maxHeight: 30)
                            .tag(touchControls[index])
                            .frame(minWidth: 40, minHeight: 40)
                            .padding(30)
                    }
                }
                .pickerStyle(.segmented)
                //.fixedSize()
                .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 5.0))
            }
            
            // Only use the grid if there are number buttons - otherwise just spit them out
            if numericButtons.count > 0 {
                GeometryReader { proxy in
                    // Since the number of buttons can vary wildly (Over 30 on the largest Solo boards), we use a grid to adapt
                    // The `computerGridColumns` function helps figure out how many columns we need & allow for center alignment.
                    LazyVGrid(columns: computeGridColumns(proxy: proxy, numButtons: numericButtons.count + buttonControls.count), spacing: gridSpacing) {
                        ForEach(0..<numericButtons.count, id:\.self) { index in
                            Button() {
                                buttonPressEmitter(numericButtons[index].buttonCommand)
                            } label : {
                                ButtonLabel(control: numericButtons[index])
                                    .frame(maxHeight: 30)
                            }
                            .frame(minWidth: 30, minHeight: 30)
                            .background(.thickMaterial, in: RoundedRectangle(cornerRadius: 5.0))
                        }
                        
                        ForEach(0..<buttonControls.count, id:\.self) { index in
                            Button() {
                                buttonPressEmitter(buttonControls[index].buttonCommand)
                            } label: {
                                ButtonLabel(control: buttonControls[index])
                                    .frame(maxHeight: 30)
                                /*
                                 if(buttonControls[index].hasImage()) {
                                 buttonControls[index].buildImage()
                                 .resizable()
                                 .frame(maxWidth: 20, maxHeight: 20)
                                 //.foregroundStyle(game.game.buttonControls[index].imageColor)
                                 .padding(5)
                                 } else {
                                 Text(buttonControls[index].label)
                                 }
                                 */
                            }
                            .frame(minWidth: 30, minHeight: 30)
                            .background(.thickMaterial, in: RoundedRectangle(cornerRadius: 5.0))
                        }
                        
                    }
                    .overlay() { GeometryReader { geom in
                        // This overlay gets the total height of the VStack, then stores the height
                        // We use this to set the height of the wrapping GeometryReader so it doesn't mess with the overall view.
                        let height = geom.size.height
                        Color.clear.task(id: height) {
                            self.totalHeight = height
                        }
                    }}
                }
                .frame(height: totalHeight) // <-- This is what keeps the geometry reader in check.
            }
            else {
                // No number buttons - just spit out button controls where present.
                // This lets the buttons be a little larger & use text when not bound to the grid.
                ForEach(0..<buttonControls.count, id:\.self) { index in
                    Button() {
                        buttonPressEmitter(buttonControls[index].buttonCommand)
                    } label: {
                        ButtonLabel(control: buttonControls[index], largeButtons: true)
                            .frame(maxHeight: 30)
                    }
                    .padding(10)
                    .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 5.0))
                }
            }
            Spacer()
            
        }
    }
    
    func computeGridColumns(proxy: GeometryProxy, numButtons: Int) -> [GridItem] {
        let minButtonWidth = self.horizontalSizeClass == .compact ? gridItemMinimumSize : gridItemMaximumSize + gridSpacing //button size + padding
        // Look at the MAXIMUM number of columns we can support. If the number of buttons we have is LESS that this, we must restrict the number of columns to allow them to be centered.
        //Otherwise, there's a bunch of extra space
        let numColumnsThatFit = Int((proxy.size.width - (minButtonWidth * 2)) / minButtonWidth)
        print("Columns: \(numColumnsThatFit) Width: \(Int(proxy.size.width)) buttonWidth: \(minButtonWidth)")
        
        //print("Column Info: Total Coluns that fit: \(numColumnsThatFit), fitting \(numButtons). SO, asking for \(numButtons < numColumnsThatFit ? numButtons : numColumnsThatFit) columns")
        let totalNumColumns = numButtons <= numColumnsThatFit ? numButtons : numColumnsThatFit
        
        guard totalNumColumns > 0 else {
            return [GridItem(.adaptive(minimum: 30, maximum: 30))]
        }
        
        return Array.init(repeating: GridItem(.flexible(minimum: gridItemMinimumSize, maximum: gridItemMaximumSize)), count: totalNumColumns)
            
    }
}

#Preview {
    
    struct Preview: View {
        
        
        @State var controlConfig: ControlConfig = ControlConfig(label: "Clockwise", shortPress: PuzzleKeycodes.leftKeypress, longPress: .none, imageName: "arrow.clockwise")
        
        var buttonPressFunction: FireButtonFunction = { button in
            if let unwrappedButton = button {
                print("pressed button for \(unwrappedButton.keycode)")
            } else {
                print("Err: No button command configured on a button")
            }
            
        }
        
        var body: some View {
            ScrollView {
                VStack(spacing: 30) {
                    Text("Net Segment Selector")
                    LazyGameControlsView(controlOption: $controlConfig, touchControls: Puzzles.puzzle_net.touchControls, buttonControls: Puzzles.puzzle_net.buttonControls, gameId: "5x5:89812e93b6e4dd9db75a22148", buttonPressFunction: buttonPressFunction).equatable()
                    
                    Divider()
                    
                    Text("Net Segment Selector with Shift")
                    LazyGameControlsView(controlOption: $controlConfig, touchControls: Puzzles.puzzle_net.touchControls, buttonControls: Puzzles.puzzle_net.buttonControls, gameId: "5x5w:28563856986235976", buttonPressFunction: buttonPressFunction).equatable()
                    
                    Divider()
                    
                    Text("Pattern Controls")
                    LazyGameControlsView(controlOption: $controlConfig, touchControls: Puzzles.puzzle_pattern.touchControls, buttonPressFunction: buttonPressFunction).equatable()
                    
                    Divider()
                    
                    Text("5 Numeric Buttons")
                    LazyGameControlsView(controlOption: $controlConfig, buttonControls: Puzzles.puzzle_towers.buttonControls, numericButtonsFunction: Puzzles.puzzle_towers.numericButtonsBuilder, gameId: "5:3/2/2/3/45/5/3/2/2//2/2", buttonPressFunction: buttonPressFunction).equatable()
                    Divider()
                    
                    Text("8 Numeric Buttons")
                    LazyGameControlsView(controlOption: $controlConfig, buttonControls: Puzzles.puzzle_towers.buttonControls, numericButtonsFunction: Puzzles.puzzle_towers.numericButtonsBuilder, gameId: "8:3/2/2/3/45/5/3/2/2//2/2", buttonPressFunction: buttonPressFunction).equatable()
                    Divider()
                    Text("9 Numeric Buttons")
                    LazyGameControlsView(controlOption: $controlConfig, buttonControls: Puzzles.puzzle_towers.buttonControls, numericButtonsFunction: Puzzles.puzzle_towers.numericButtonsBuilder, gameId: "9:3/2/2/3/45/5/3/2/2//2/2", buttonPressFunction: buttonPressFunction).equatable()
                    Divider()
                    Text("10 Numeric Buttons")
                    LazyGameControlsView(controlOption: $controlConfig, buttonControls: Puzzles.puzzle_towers.buttonControls, numericButtonsFunction: Puzzles.puzzle_towers.numericButtonsBuilder, gameId: "10:3/2/2/3/45/5/3/2/2//2/2", buttonPressFunction: buttonPressFunction).equatable()
                    Divider()
                    Text("16 Hex Buttons")
                    LazyGameControlsView(controlOption: $controlConfig, buttonControls: Puzzles.puzzle_solo.buttonControls, numericButtonsFunction: Puzzles.puzzle_solo.numericButtonsBuilder, gameId: "4x4:3/2/2/3/45/5/3/2/2//2/2", buttonPressFunction: buttonPressFunction).equatable()
                    Divider()
                    Text("25 Hex Buttons")
                    LazyGameControlsView(controlOption: $controlConfig, buttonControls: Puzzles.puzzle_solo.buttonControls, numericButtonsFunction: Puzzles.puzzle_solo.numericButtonsBuilder, gameId: "25j:3/2/2/3/45/5/3/2/2//2/2", buttonPressFunction: buttonPressFunction).equatable()
                    Divider()
                    Text("31 Hex Buttons")
                    LazyGameControlsView(controlOption: $controlConfig, buttonControls: Puzzles.puzzle_solo.buttonControls, numericButtonsFunction: Puzzles.puzzle_solo.numericButtonsBuilder, gameId: "31j:3/2/2/3/45/5/3/2/2//2/2", buttonPressFunction: buttonPressFunction).equatable()
                    Divider()
                    Text("35 Hex Buttons (Maximum)")
                    LazyGameControlsView(controlOption: $controlConfig, buttonControls: Puzzles.puzzle_solo.buttonControls, numericButtonsFunction: Puzzles.puzzle_solo.numericButtonsBuilder, gameId: "35j:3/2/2/3/45/5/3/2/2//2/2", buttonPressFunction: buttonPressFunction).equatable()
                    Divider()
                    Text("Unruly Controls")
                    LazyGameControlsView(controlOption: $controlConfig, touchControls: Puzzles.puzzle_unruly.touchControls, buttonPressFunction: buttonPressFunction).equatable()
                    Divider()
                    Text("Undead Controls")
                    LazyGameControlsView(controlOption: $controlConfig, buttonControls: Puzzles.puzzle_undead.buttonControls, buttonPressFunction: buttonPressFunction).equatable()
                    Divider()
                }
            }
            
        }
    }
    
    return Preview()
}
