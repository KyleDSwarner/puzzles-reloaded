//
//  GestureTransformView.swift
//  Puzzles
//
//  Created by Kyle Swarner on 3/8/24.
//  Copyright © 2024 Kyle Swarner. All rights reserved.
//
import SwiftUI

/// Our UIKit to SwiftUI wrapper view
struct PuzzleInteractionsView: UIViewRepresentable {
    
    // Pan & Zoom transform bound to the puzzle image
    @Binding var transform: CGAffineTransform
    @Binding var anchor: CGPoint
    
    var puzzleFrontend: Frontend
    
    // Whether touch information should continue after the user's finger has left the view
    var limitToBounds = true
    
    var allowSingleFingerPanning: Bool
    var puzzleTilesize: Int // TODO: Remove these two values? May not be needed.
    var adjustTapsToTilesize: Bool


    // A closure to call when touch data has arrived
    var onUpdate: (CGPoint) -> Void

    // The list of touch types to be notified of
    //var types = TouchType.all



    func makeUIView(context: Context) -> PuzzleTapView {
        // Create the underlying UIView, passing in our configuration
        let view = PuzzleTapView()
        
        let zoomRecognizer = UIPinchGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.zoom(_:)))
        
        let panRecognizer = UIPanGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.pan(_:)))
        
        panRecognizer.minimumNumberOfTouches = allowSingleFingerPanning ? 1 : 2 // Require a two finger touch to prevent conlifct with single taps in the puzzles
        
        zoomRecognizer.delegate = context.coordinator
        panRecognizer.delegate = context.coordinator
        view.addGestureRecognizer(zoomRecognizer)
        view.addGestureRecognizer(panRecognizer)
        context.coordinator.zoomRecognizer = zoomRecognizer
        context.coordinator.panRecognizer = panRecognizer
        context.coordinator.view = view
        
        view.onUpdate = onUpdate
        view.frontend = puzzleFrontend
        //view.touchTypes = types
        view.limitToBounds = limitToBounds
        view.isSingleFingerNavEnabled = allowSingleFingerPanning
        
        return view
    }
    
    func makeCoordinator() -> Coordinator {
        let coordinator = Coordinator(self)
        coordinator.setupOrientationNotifications()
        return coordinator
            
    }

    func updateUIView(_ uiView: PuzzleTapView, context: Context) {
    }

    
}

// A custom SwiftUI view modifier that overlays a view with our UIView subclass.
/*
struct TouchLocater: ViewModifier {
    var type: TouchLocatingView.TouchType = .all
    var limitToBounds = true
    let perform: (CGPoint) -> Void

    func body(content: Content) -> some View {
        content
            .overlay(
                TouchLocatingView(onUpdate: perform, types: type, limitToBounds: limitToBounds)
            )
    }
}
 */

/*
// A new method on View that makes it easier to apply our touch locater view.
extension View {
    func onTouch(type: TouchLocatingView.TouchType = .all, limitToBounds: Bool = true, perform: @escaping (CGPoint) -> Void) -> some View {
        self.modifier(TouchLocater(type: type, limitToBounds: limitToBounds, perform: perform))
    }
}
 */

// Finally, here's some example code you can try out.
/*
 struct testtappyview: View {
 var body: some View {
 VStack {
 Text("This will track all touches, inside bounds only.")
 .padding()
 .background(.red)
 .onTouch(perform: updateLocation)
 
 Text("This will track all touches, ignoring bounds – you can start a touch inside, then carry on moving it outside.")
 .padding()
 .background(.blue)
 .onTouch(limitToBounds: false, perform: updateLocation)
 
 Text("This will track only starting touches, inside bounds only.")
 .padding()
 .background(.green)
 .onTouch(type: .started, perform: updateLocation)
 }
 }
 
 func updateLocation(_ location: CGPoint) {
 print(location)
 }
 }
 */
