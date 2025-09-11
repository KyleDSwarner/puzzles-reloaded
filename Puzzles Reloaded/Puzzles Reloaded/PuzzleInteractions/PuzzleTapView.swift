//
//  PuzzleTapView.swift
//  Puzzles
//
//  Created by Kyle Swarner on 4/18/24.
//  Copyright © 2024 Kyle Swarner. All rights reserved.
//

import SwiftUI

// UIView responsible for catching taps, long presses, atznd drags on the main puzzle.
// This view is attaches to the main puzzle image as an overlay, via PuzzleInteractionsView
// (The pan & zoom interactions are also attached there)
#if os(iOS)
class PuzzleTapView: UIView {
    
    @AppStorage(AppSettings.key) var appSettings: CodableWrapper<AppSettings> = AppSettings.initialStorage()
    
    var frontend: Frontend?
    var isSingleFingerNavEnabled = false
    
    private var effectsManager = EffectsManager()

    private var longPressTimer = Timer()
    
    private var isLongPress = false
    private var isDragging = false
    private var dragDeadzoneExceeded = false
    private var initialTouchLocation: CGPoint = .zero
    private var arrowKeyTapLocation: CGPoint = .zero
    private var mouseLeftClick = false
    private var mouseEventHandled = false
    
    // Our main initializer, making sure interaction is enabled.
    override init(frame: CGRect) {
        super.init(frame: frame)
        isUserInteractionEnabled = true
    }

    // Just in case you're using storyboards!
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        isUserInteractionEnabled = true
    }
    
    // MARK: Tap Scale Adjustment Functions
    
    /*
        Determine the current scaling factor of the image on the screen compared to the requested puzzle size.
     */
    func scaleFactorX() -> CGFloat {
        return self.frame.width / CGFloat(puzzleDimensionsX)
    }
    
    func scaleFactorY() -> CGFloat {
        return self.frame.height / CGFloat(puzzleDimensionsY)
    }
    
    func adjustedTapLocation(point: CGPoint) -> CGPoint {
        
        
        let adjustedPoint = CGPoint(x: point.x / scaleFactorX(), y: point.y / scaleFactorY())
        
        //
        // let tilesize = frontend?.puzzleTilesize ?? 0
        
        //print("Scale: \(Float(scaleFactor)) old X: \(point.x) new X: \(adjustedPoint.x)")
        return adjustedPoint
    }

    // MARK: Touch Started
    // Triggered when a touch starts.
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        
        // Ensure the image hasn't been disabled (during loading states)
        guard frontend?.currentGameInvalidated == false else {
            return
        }
        
        let location = touch.location(in: self)
        
        let adjustedLocation = adjustedTapLocation(point: location)
        
        // Store the initial location for later use
        initialTouchLocation = adjustedLocation
        
        /*
         This code is unused as no games set `useArrowKeys` - but keeping for posterity in case it's needed later.
        if let mouseCommand = frontend?.controlOption.shortPress {
            if mouseCommand.useArrowKeys == true {
                arrowKeyTapLocation = adjustedLocation
                    // Register the current location for reference when dragging
                    // We'll fire a command for every _tilesize_ pixels we move in any direction
            }
        }
        */
        
        // MARK: Secondary / Right Click Detection
        // If this is a right click from a mouse AND the setting is enabled, we go straight to the long press handler
        let isRightClick = touch.type == .indirectPointer && event?.buttonMask == .secondary && appSettings.value.enableRightClick
        
        // MARK: Long Press Trigger
        // If there's no long press configured, don't start the timer!
        if frontend?.controlOption.longPress != nil {
            // Skip straight to the long press handling if this is a right click shortcut
            if isRightClick {
                // If this is a secondary click, ALWAYS consider it a long press.
                startLongPress(at: location)
                return
            } else {
                // Long press timer is based on user settings & defaults to 500ms. `withTimeInterval` is in seconds, so this value is divided by 1000.
                longPressTimer = Timer.scheduledTimer(withTimeInterval: appSettings.value.longPressTime / 1000, repeats: false) {_ in
                    Task { @MainActor in
                        self.startLongPress(at: location)
                    }
                }
            }
        }
    
    }
    
    func startLongPress(at location: CGPoint)  {
        isLongPress = true
        self.triggerLongPressEffects()
        self.sendKeyDown(at: location) // We send the original location, not the adjusted one, because `sendKeyDown` already adjusts.
    }

    // MARK: Touch Dragging
    // Triggered when an existing touch moves.
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        
        // Ensure the image hasn't been disabled (during loading states)
        guard frontend?.currentGameInvalidated == false else {
            return
        }
        
        guard isSingleFingerNavEnabled == false else {
            print("Ignoring movement - single finger nav is enabled")
            return
        }
        
        // Ignore multi-touch - this will always be navigation panning
        guard touches.count == 1 else {
            // print("Ignoring movement - two touches")
            return
        }
        
        let location = touch.location(in: self)
        
        let adjustedLocation = adjustedTapLocation(point: location)
        
        //let isDirectTouch = touch.type == .direct // .pencil, .indirect, or .indirectPointer
        
        let deadzoneValue = touch.type == .direct ? PuzzleConstants.DirectTouchDragzone : PuzzleConstants.PencilDragDeadzone
        
        /*
         MARK: Apple Pencil & Mouse Dragzone Logic
         Pencils detect very small movement and trigger this movement function, making is very difficult to hold steady to trigger long press functions.
         When long press logic is present, compare the current location to the pencil drag deadzone, and only continue once the pencil exceeds that distance.
         */
        if !dragDeadzoneExceeded && frontend?.controlOption.longPress != nil  {
            let xOffsetFromOrigin = abs(adjustedLocation.x - initialTouchLocation.x)
            let yOffsetFromOrigin = abs(adjustedLocation.y - initialTouchLocation.y)
            
            if xOffsetFromOrigin > deadzoneValue || yOffsetFromOrigin > deadzoneValue {
                // print("Deadzone Exceeded")
                dragDeadzoneExceeded = true
                // Continue on and short-circuit this logic from occurring again
            } else {
                // Ignore this input
                return
            }
        }
        
        // End the long press timer if it isn't already
        longPressTimer.invalidate()
        
        let command = isLongPress ? self.frontend?.controlOption.longPress : self.frontend?.controlOption.shortPress
        
        // If this is a mouse, override the command layer to always stick to the left/right mouse button
        /*
        if touch.type == .indirectPointer {
            command = PuzzleKeycodes.leftKeypress
        }
         */
        
        
        // For arrow key-based commands, compare the current position to the initial postion (stored in `touchesStart`), and move the cursor when the distance is greater than the tile size.
        if command?.useArrowKeys == true, let tilesizeInt = frontend?.puzzleTilesize {
            // MARK: Arrow Key Dragging Logic
            let tilesize = CGFloat(tilesizeInt)
            
            // Some commands need to be reversed to feel 'right' when using touchscreens vs. arrow keys.
            let reverseArrowDirections = command?.reverseArrowDirections == true
            
            let xPosition = adjustedLocation.x
            let yPosition = adjustedLocation.y
            
            var xDiff = xPosition - arrowKeyTapLocation.x
            var yDiff = yPosition - arrowKeyTapLocation.y
            
            // These loops see if the difference from the previous postion is greater than (or equal to) the tilesize. Then so, it fires a command to move in the correct cursor direction & resets values to adjust the tap position to current.
            
            while(xDiff >= tilesize) {
                let cursorDirection = reverseArrowDirections ? PuzzleKeycodes.CursorLeft : PuzzleKeycodes.CursorRight
                sendArrowKeyCommand(command: cursorDirection, modifier: command?.arrowKeyModifier)
                xDiff -= tilesize
                arrowKeyTapLocation.x += tilesize
            }
            
            while(xDiff <= -tilesize) {
                let cursorDirection = reverseArrowDirections ? PuzzleKeycodes.CursorRight : PuzzleKeycodes.CursorLeft
                sendArrowKeyCommand(command: cursorDirection, modifier: command?.arrowKeyModifier)
                xDiff += tilesize
                arrowKeyTapLocation.x -= tilesize
            }
            
            while(yDiff <= -tilesize) {
                let cursorDirection = reverseArrowDirections ? PuzzleKeycodes.CursorDown : PuzzleKeycodes.CursorUp
                sendArrowKeyCommand(command: cursorDirection, modifier: command?.arrowKeyModifier)
                yDiff += tilesize
                arrowKeyTapLocation.y -= tilesize
            }
            
            while(yDiff >= tilesize) {
                let cursorDirection = reverseArrowDirections ? PuzzleKeycodes.CursorUp : PuzzleKeycodes.CursorDown
                sendArrowKeyCommand(command: cursorDirection, modifier: command?.arrowKeyModifier)
                yDiff -= tilesize
                arrowKeyTapLocation.y += tilesize
            }            
            
        } else {
            // MARK: Usual Tap & Drag Commands Based on mouseclicks & drags
            if !isDragging && !isLongPress && !mouseLeftClick && command != nil {
                // We need to send the short press' keyDown command - but only the first time.
                sendKeypress(command: command!.down, location: location, physicalFeedbackType: .SHORT)
                //self.frontend?.midend.sendKeypress(x: Int(adjustedLocation.x), y: Int(adjustedLocation.y), keypress: command!.down)
                //self.triggerShortPressEffects()
            }
            
            isDragging = true
            
            // Then we need to send a DRAG command to the correct
            sendKeypress(command: command!.drag, location: location, physicalFeedbackType: .NONE)
            //self.frontend?.midend.sendKeypress(x: Int(adjustedLocation.x), y: Int(adjustedLocation.y), keypress: command!.drag)
        }
        
        //send(location, forEvent: .moved)
    }
    
    private func sendArrowKeyCommand(command: Int, modifier: Int?) {
        let mod: Int = modifier ?? 0
        sendKeypress(command: command | mod, physicalFeedbackType: .SHORT)
    }

    // MARK: Touch Finished
    // Triggered when the user lifts a finger.
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        guard let touch = touches.first else { return }
        
        // Ensure the image hasn't been disabled (during loading states)
        guard frontend?.currentGameInvalidated == false else {
            return
        }
        
        let location = touch.location(in: self)
        
        // Ignore multi-touch - this will always be navigation panning
        guard touches.count == 1 else {
            return
        }
        
        // If this is a long press or if we're dragging, we've already sent the 'down' command - we just need to fire up.
        let command = getCorrectCommand()
        
        // Double check this isn't an arrow key command - releasing tap should do nothing for arrow commands!
        if command != nil && command?.useArrowKeys == false {
            
            // If we haven't started a long press or started dragging, we need to send the keydown command
            if !isLongPress && !isDragging {
                // triggerShortPressEffects() // For short presses, play the haptic & sound effects (if enabled)
                sendKeypress(command: command?.down, location: location, physicalFeedbackType: .SHORT)
            }
            
            // And we always need to sent the keyup command
            sendKeypress(command: command?.up, location: location)
            
            frontend?.movesTakenInGame = true // This boolean lets us better know when we should/should not save the user's game
        }
        
        // Reset Values
        resetTouchInfo()
    }
    
    /**
     A helper method for sending the keydown for mouseclicks - this block is needed by all of the touch functions
     */
    func sendKeyDown(at location: CGPoint) {
        let command = self.isLongPress ? self.frontend?.controlOption.longPress : self.frontend?.controlOption.shortPress
        sendKeypress(command: command?.down, location: location)
    }
    
    func getCorrectCommand() -> MouseClick? {
        let command = self.isLongPress ? self.frontend?.controlOption.longPress : self.frontend?.controlOption.shortPress
        return command
    }
    
    func sendKeypress(command: Int?, location: CGPoint = CGPoint(x: -1, y: -1), physicalFeedbackType: FeedbackType = .NONE) {
        guard let unwrappedCommand = command else {
            return
        }
        
        var targetLocation = location
        
        // If a location is provided, adjust it to account for image scale.
        if targetLocation.x != -1 && targetLocation.y != -1 {
            targetLocation = adjustedTapLocation(point: targetLocation)
        }
        
        let keypressResponse = frontend?.midend.sendKeypress(x: Int(targetLocation.x), y: Int(targetLocation.y), keypress: unwrappedCommand)
        
        if keypressResponse == PuzzleInteractionResponse.someEffect {
            effectsManager.triggerEffect(feedbackType: physicalFeedbackType)
        }
    }

    // Triggered when the user's touch is interrupted, e.g. by a low battery alert.
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard touches.first != nil else { return }
        resetTouchInfo()
    }
    
    func resetTouchInfo() {
        isLongPress = false
        isDragging = false
        dragDeadzoneExceeded = false
        longPressTimer.invalidate()
        initialTouchLocation = .zero
        arrowKeyTapLocation = .zero
        mouseLeftClick = false
        mouseEventHandled = false
    }
    
    func triggerShortPressEffects() {
        effectsManager.triggerShortPressEffects()
    }
    
    func triggerLongPressEffects() {
        effectsManager.triggerLongPressEffects()
    }
}
#endif
