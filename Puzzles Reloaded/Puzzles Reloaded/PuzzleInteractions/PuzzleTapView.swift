//
//  PuzzleTapView.swift
//  Puzzles
//
//  Created by Kyle Swarner on 4/18/24.
//  Copyright © 2024 Kyle Swarner. All rights reserved.
//

import SwiftUI

// The types of touches users want to be notified about
struct TouchType: OptionSet {
    let rawValue: Int

    static let started = TouchType(rawValue: 1 << 0)
    static let moved = TouchType(rawValue: 1 << 1)
    static let ended = TouchType(rawValue: 1 << 2)
    static let all: TouchType = [.started, .moved, .ended]
}

// UIView responsible for catching taps, long presses, atznd drags on the main puzzle.
// This view is attaches to the main puzzle image as an overlay, via PuzzleInteractionsView
// (The pan & zoom interactions are also attached there)
class PuzzleTapView: UIView {
    
    @AppStorage(AppSettings.key) var settings: CodableWrapper<AppSettings> = AppSettings.initialStorage()
    
    //var touchTypes: PuzzleInteractionsView.TouchType = .all
    var limitToBounds = true
    var frontend: Frontend?
    var isSingleFingerNavEnabled = false
    
    private var hapticsEngine = HapticEffects()
    private var soundEffectsEngine = SoundEffects()

    private var longPressTimer = Timer()
    
    private var isLongPress = false
    private var isDragging = false
    
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
        let tilesize = frontend?.puzzleTilesize ?? 0
        
        //print("Scale: \(Float(scaleFactor)) old X: \(point.x) new X: \(adjustedPoint.x)")
        return adjustedPoint
    }
    
    func fireKeypress(keycode: MouseClick) {
        
    }
    
    // MARK: Keypresses
    override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        // TODO - manage keyboard commands. WASD, Ctrl+S, etc
        let keycode = PuzzleKeycodes.SOLVE
        
        
    }

    // MARK: Touch Started
    // Triggered when a touch starts.
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        // let adjustedLocation = adjustedTapLocation(point: location)
        
        // send(location, forEvent: .started)
        
        // MARK: Long Press Trigger
        // If there's no long press configured, don't start the timer!
        if frontend?.controlOption.longPress != nil {
            
            // Long press timer is based on user settings & defaults to 500ms. `withTimeInterval` is in seconds, so this value is divided by 1000.
            longPressTimer = Timer.scheduledTimer(withTimeInterval: settings.value.longPressTime / 1000, repeats: false) {_ in
                self.isLongPress = true
                
                self.hapticsEngine.playLongPressHaptic()
                self.soundEffectsEngine.playSoundEffect()
                // Long Press Trigger? (Swap left & right click in Frontend?)
                // Haptic Feedback?
                // Sound Effect?
                self.sendKeyDown(at: location)
            }
            
            
        }
        
        // Store the location for future use
        
        // If 'net center mode', then process a specific key (0x03)
        /*
         if (self.net_centre_mode) {
             midend_process_key(me, touchXpixels, touchYpixels, 0x03);
         }
         */
    }

    // MARK: Touch Dragging
    // Triggered when an existing touch moves.
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        
        // End the long press timer if it isn't already
        longPressTimer.invalidate()
        
        guard isSingleFingerNavEnabled == false else {
            // print("Ignoring movement - single finger nav is enabled")
            return
        }
        
        // Ignore multi-touch - this will always be navigation panning
        guard touches.count == 1 else { 
            // print("Ignoring movement - two touches")
            return
        }
        
        let location = touch.location(in: self)
        
        // TODO: Ignore if out of bounds
        
        let adjustedLocation = adjustedTapLocation(point: location)
        
        let command = isLongPress ? self.frontend?.controlOption.longPress : self.frontend?.controlOption.shortPress
        
        if !isDragging && !isLongPress && command != nil {
            // We need to send the short press' keyDown command - but only the first time.
            self.frontend?.midend.sendKeypress(x: Int(adjustedLocation.x), y: Int(adjustedLocation.y), keypress: command!.down)
        }
        
        isDragging = true
        
        // Then we need to send a DRAG command to the correct
        self.frontend?.midend.sendKeypress(x: Int(adjustedLocation.x), y: Int(adjustedLocation.y), keypress: command!.drag)
        
        
        //send(location, forEvent: .moved)
    }

    // MARK: Touch Finished
    // Triggered when the user lifts a finger.
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        // Ignore multi-touch - this will always be navigation panning
        guard touches.count == 1 else {
            // print("Ignoring multi-touch gesture")
            return
        }
        
        // print("Touch Ended! This was a \(isLongPress ? "Long" : "Short") press \(isDragging ? "with a drag " : "")")
        
        // TODO: some games will want to execute long presses immediately when the timer expires- it's going to depend on the game! We can add a gameConfig and hopefully find a clean_ish way to account for the weird differences.
        
        // In its simplest form, let's just send LEFT or RIGHT depending on if this was a short or long press
        //let keysToFire = isLongPress ? frontend?.controlOption.longPress: frontend?.controlOption.shortPress
        
        // If this is a long press or if we're dragging, we've already sent the 'down' command - we just need to fire up.
        let command = getCorrectCommand()
        
        // If we haven't started a long press or started dragging, we need to send the keydown command
        if !isLongPress && !isDragging {
            sendKeypress(command: command?.down, location: location)
        }
        
        // And we always need to sent the keyup command
        sendKeypress(command: command?.up, location: location)
        
        // Reset Values
        resetTouchInfo()
        
        //send(location, forEvent: .ended)
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
    
    func sendKeypress(command: Int?, location: CGPoint) {
        
        guard let unwrappedCommand = command else {
            return
        }
        
        let adjustedLocation = adjustedTapLocation(point: location)
        
        frontend?.midend.sendKeypress(x: Int(adjustedLocation.x), y: Int(adjustedLocation.y), keypress: unwrappedCommand)
    }

    // Triggered when the user's touch is interrupted, e.g. by a low battery alert.
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        resetTouchInfo()
    }
    
    func resetTouchInfo() {
        isLongPress = false
        isDragging = false
        longPressTimer.invalidate()
    }
    
    func adjustDragPosition(x: Int, y: Int) {
        //TODO, for Untangle?
    }
}
