//
//  GestureTransformView.swift
//  Puzzles
//
//  Created by Kyle Swarner on 3/8/24.
//  Copyright © 2024 Kyle Swarner. All rights reserved.
//

import SwiftUI

struct GestureBoundaries {
    static let minimumZoom = 1.0
    static let maximumZoom = 5.0
    static let maximumOverscrollFactorX = 0.5
    static let maximumOverscrollFactorY = 0.5
}

#if os(iOS)
extension UIView {
    var globalPoint :CGPoint? {
        return self.superview?.convert(self.frame.origin, to: nil)
    }
    
    var globalFrame :CGRect? {
        return self.superview?.convert(self.frame, to: nil)
    }
}

extension PuzzleInteractionsView {
    class Coordinator: NSObject, UIGestureRecognizerDelegate {
        var parent: PuzzleInteractionsView
        var view: UIView?
        var zoomRecognizer: UIPinchGestureRecognizer?
        var panRecognizer: UIPanGestureRecognizer?
        
        var panGestureActive = false
        var zoomGestureActive = false
        
        var lastValidPanRequest: CGPoint = .zero
        
        var startTransform: CGAffineTransform = .identity
        var anchor: CGPoint = .zero
        
        var activeXTranslation: CGFloat = .zero
        var activeYTranslation: CGFloat = .zero
        var activeZoomScale: CGFloat = 1.0
        
        var xBoundsReached = false
        var xPanAllowed = false
        var yBoundsReached = false
        var yPanAllowed = false
        
        var xPrevRequest: CGFloat = .zero
        var yPrevRequest = CGFloat.zero
        
        
        init(_ parent: PuzzleInteractionsView) {
            self.parent = parent

        }
        
        func setupOrientationNotifications() {
            // NotificationCenter.default.addObserver(self, selector: #selector(self.rotated), name: UIDevice.orientationDidChangeNotification, object: nil)
        }
        
        /*
        @objc func rotated() {
            if UIDevice.current.orientation.isLandscape {
                print("Landscape")
            }

            if UIDevice.current.orientation.isPortrait {
                print("Portrait")
            }
            
            //print("midX: \(frame.midX) midY: \(frame.midY)")
            
            print("Transform: \(parent.transform.tx) Y: \(parent.transform.ty)")
            print("Transform: \(-parent.transform.tx * parent.transform.a) Y: \(-parent.transform.ty * parent.transform.a)")
            
            // I'm questioning if a orientation reset is really needed!
            
            // On orientation change, reset the puzzle image to center
            //parent.transform = parent.transform.scaledBy(x: (1 - parent.transform.a), y: (1 - parent.transform.a))
            //parent.transform.scaledAndPanned(by: (1 - parent.transform.a), with: .init(x: 0.5, y: 0.5), translatedX: -parent.transform.tx, translatedY: -parent.transform.ty)
            //parent.transform = parent.transform.translatedBy(x: -parent.transform.tx * parent.transform.a, y: .zero)
        }
         */
        
        func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
            return true
        }
        
        func setGestureStart(_ gesture: UIGestureRecognizer) {
            if !panGestureActive && !zoomGestureActive {
                startTransform = parent.transform
                anchor = gesture.location(in: gesture.view)
            }
        }
        
        func applyPan(_ gesture: UIPanGestureRecognizer) {
            guard let translation = panRecognizer?.translation(in: view) else {
                return
            }
            guard let globalFrame = view?.globalFrame else {
                print("Err: Global frame not provided")
                return
            }
            guard let superviewFrame = view?.superview?.superview?.globalFrame else {
                print("superview err")
                return
            }
            
            //pivot = gesture.location(in: gesture.view)
            
            var transformX: CGFloat = lastValidPanRequest.x
            var transformY: CGFloat = lastValidPanRequest.y
            
            // globalFrame.mixX shouldn't be more than some percentage of the total frame size?
            //print("X Bounds: \(minX) \(globalFrame.maxX) \(width * maximumOverscrollFactorX)")
            
            /*
            if globalFrame.minX > (width * maximumOverscrollFactorX) {
                print("X BOUNDS LEFT FAIL !!")
            }
            if globalFrame.maxX < (width * (1 - maximumOverscrollFactorX)) {
                print("X BOUNDS Right FAIL !!")
            }
            
            if globalFrame.minY > (height * maximumOverscrollFactorY) {
                print("Y BOUNDS TOP FAIL !!")
            }
            
            if globalFrame.maxY < (height * maximumOverscrollFactorY) {
                print("Y BOUNDS BOTTOM FAIL !!")
            }
             */
            
            let xDiff = translation.x - xPrevRequest
            let yDiff = translation.y - yPrevRequest
            
            // print("X Scroll Diff: \(xDiff)")
            
            // MARK: X Pan Translation
            if globalFrame.minX >= (superviewFrame.width * GestureBoundaries.maximumOverscrollFactorX) {
                print("X At Max")
                
                if xDiff < 0 {
                    print("But we're decreasing, so let it through anyway \(parent.transform.tx) \(xDiff)")
                    transformX = lastValidPanRequest.x + xDiff
                    xBoundsReached = true
                    xPanAllowed = true
                } else {
                    xBoundsReached = true
                }
                //print("X Positive Translation Reached, prevent panning further")
                //print(String(format: "X POS- %.2f %.2f %.2f", parent.transform.tx, translation.x, parent.transform.tx + translation.x))
            } else if globalFrame.maxX <= (superviewFrame.width * (1 - GestureBoundaries.maximumOverscrollFactorX)) {
                print("X at Min")
                if xDiff > 0 {
                    print("But we're increasing, so let it through anyway \(parent.transform.tx) \(xDiff)")
                    transformX = lastValidPanRequest.x + xDiff
                    xBoundsReached = true
                    xPanAllowed = true
                } else {
                    xBoundsReached = true
                }
            }
            else {
                //print(String(format: "X OK- %.2f %.2f %.2f", parent.transform.tx, translation.x, parent.transform.tx + translation.x))
                xBoundsReached = false
                xPanAllowed = true
                transformX = lastValidPanRequest.x + xDiff
                

                //transformX = translation.x // Bounds succeeded, apply the x transformation
            }
            
            // X Overscroll Detection
            //Overscroll Detection

            
            //print("maxYMaxOverscroll: \(height * maximumOverscrollFactorY), maxY: \(globalFrame.maxY) pct: \((height * maximumOverscrollFactorY) / globalFrame.maxY) yDiff: \(yDiff)")

            // MARK: Y Pan Translation
            if globalFrame.minY > (superviewFrame.height * GestureBoundaries.maximumOverscrollFactorY) {
                print("Y Positive Translation Reached, prevent panning further")
                
                if yDiff < 0 {
                    print("But we're decreasing, so let it through anyway current: \(parent.transform.ty) value: \(lastValidPanRequest.y) diff: \(yDiff)")
                    transformY = lastValidPanRequest.y + yDiff
                    yBoundsReached = true
                    yPanAllowed = true
                } else {
                    yBoundsReached = true
                    yPanAllowed = false
                }
            } else if globalFrame.maxY < (superviewFrame.height * GestureBoundaries.maximumOverscrollFactorY) {
                print("Y Negative Translation Reached, prevent panning further")
                if yDiff > 0 {
                    print("But we're increasing, so let it through anyway \(parent.transform.ty) value: \(lastValidPanRequest.y) diff: \(yDiff)")
                    transformY = lastValidPanRequest.y + yDiff
                    yBoundsReached = true
                    yPanAllowed = true
                } else {
                    yBoundsReached = true
                }
            } else {
                //print(String(format: "X OK- %.2f %.2f %.2f", parent.transform.tx, translation.x, parent.transform.tx + translation.x))
                yBoundsReached = false
                yPanAllowed = true
                transformY = lastValidPanRequest.y + yDiff
                
                //transformX = translation.x // Bounds succeeded, apply the x transformation
            }
            
            // MARK: Wrap Up and Resetting Pan Values
            if xPanAllowed {
                // X Overscroll Detection
                //transformX = adjustForOverscroll(lowPosition: globalFrame.minX, highPosition: globalFrame.maxY, newPosition: transformX, diff: xDiff, lowerBoundary: (width * (1 - maximumOverscrollFactorX)), upperBoundary: (width * maximumOverscrollFactorX))
                
                if !xBoundsReached {
                    if globalFrame.minX + xDiff > (superviewFrame.width * GestureBoundaries.maximumOverscrollFactorX) {
                        let overage = (globalFrame.minX + xDiff) - (superviewFrame.width * GestureBoundaries.maximumOverscrollFactorX)
                        transformX = transformX - overage
                        
                        
                    }
                    
                    if globalFrame.maxX + xDiff < (superviewFrame.width * (1 - GestureBoundaries.maximumOverscrollFactorX)) {
                        let overage = (globalFrame.maxX + xDiff) - (superviewFrame.width * (1 - GestureBoundaries.maximumOverscrollFactorX))
                        transformX = transformX - overage
                    }
                }
                
                
                lastValidPanRequest.x = transformX
                activeXTranslation = transformX
            }
            
            if yPanAllowed {
                
                if !yBoundsReached {
                    if globalFrame.minY + yDiff > (superviewFrame.height * GestureBoundaries.maximumOverscrollFactorY) {
                        let overage = (globalFrame.minY + yDiff) - (superviewFrame.height * GestureBoundaries.maximumOverscrollFactorY)
                        transformY = transformY - overage
                    }
                    
                    if globalFrame.maxY + yDiff < (superviewFrame.height * GestureBoundaries.maximumOverscrollFactorY) {
                        let overage = (globalFrame.maxY + yDiff) - (superviewFrame.height * GestureBoundaries.maximumOverscrollFactorY)
                        transformY = transformY - overage
                    }
                }
                
                lastValidPanRequest.y = transformY
                activeYTranslation = transformY
            }
            
            // Always set these values to properly compute diffs between requests
            xPrevRequest = translation.x
            yPrevRequest = translation.y
            
            if(yPanAllowed || xPanAllowed) {
                applyTransformation()
            }
            
            //previousPanRequest = translation
            
        }
    
        // MARK: Apply Transformation
        func applyTransformation() {
            parent.anchor = anchor
            parent.transform = startTransform.translatedBy(x: anchor.x, y: anchor.y)
                .scaledBy(x: activeZoomScale, y: activeZoomScale)
                .translatedBy(x: activeXTranslation - anchor.x, y: activeYTranslation - anchor.y)
        }
        
        // MARK: Pinch to Zoom
        func applyZoom(_ gesture: UIPinchGestureRecognizer) {
            
            var validZoomRequest = false
            let gestureScale = zoomRecognizer?.scale ?? 1
            
            //pivot = gesture.location(in: gesture.view)
            
            // Reading the scale's x value. The x and y values (read from .d) are in sync with pinch gestures.
            let currentZoomScale = parent.transform.a
            
            
            // Store the difference in zoom scale compared to the previous zoom request - use this to determine if we're increasing or decreasing.
            let zoomDiff = gestureScale - activeZoomScale
            
            //Enforce min/max zoom checks:
            // If the current scale from the parent has hit the bounds and we're still increasing/decreasing, do not apply the transform.
            // Gesture scale is a % : greater than 1 is increasing/pinch in, less than 1 is decreasing/pinch out
            if currentZoomScale > GestureBoundaries.maximumZoom {
                if zoomDiff < 0 {
                    print("Allow Zoom Request Because the diff is negative \(zoomDiff)")
                    validZoomRequest = true
                }
            }
            else if currentZoomScale < GestureBoundaries.minimumZoom {
                if zoomDiff > 0 {
                    print("Allow Zoom Request Because the diff is positive \(zoomDiff)")
                    validZoomRequest = true
                }
                //return
            } else {
                validZoomRequest = true
                //activeZoomScale = lastValidGestureRequest + zoomDiff
                //lastValidGestureRequest = gestureScale
            }
            
            if validZoomRequest {
                //print ("Valid, Applying")
                activeZoomScale = activeZoomScale + zoomDiff
                applyTransformation()
                
                //print("adjusting X translation: \(activeXTranslation) Y \(activeYTranslation)")
                //activeXTranslation = activeXTranslation * ( activeZoomScale)
                //activeYTranslation = activeYTranslation * (activeZoomScale)
            }
            
            
        }
        
        func finalizeGesture() {
            if !panGestureActive && !zoomGestureActive {
                print("Gestures Complete! Reset")
                print("--------------------------")
                //reset everything once both gestures are completed
                startTransform = parent.transform
                
                zoomRecognizer?.scale = 1
                activeZoomScale = 1
                anchor = .zero
                
                lastValidPanRequest = .zero
                activeXTranslation = .zero
                activeYTranslation = .zero
                
                xPrevRequest = .zero
                yPrevRequest = .zero
                
                
            }
        }
        
        
        
        @objc func zoom(_ gesture: UIPinchGestureRecognizer) {
            switch gesture.state {
            case .began:
                setGestureStart(gesture)
                anchor = gesture.location(in: gesture.view)
                zoomGestureActive = true
                break
            case .changed:
                //print("ZOOOOOOOOOM")
                applyZoom(gesture)
                break
            case .ended:
                zoomGestureActive = false
                //applyZoom(gesture)
                finalizeGesture()
                break
            default:
                break
            }
        }
        
        @objc func pan(_ gesture: UIPanGestureRecognizer) {
            
            switch gesture.state {
            case .began:
                setGestureStart(gesture)
                panGestureActive = true
                break
            case .changed:
                // Only allow two finger gestures
                //guard gesture.numberOfTouches > 1 else {
                //    return
                //}
                //print("PAN PAN")
                applyPan(gesture)
                break
            case .ended:
                //applyPan()
                panGestureActive = false
                finalizeGesture()
                break
            default:
                break
            }
        }
    }
}
#endif
