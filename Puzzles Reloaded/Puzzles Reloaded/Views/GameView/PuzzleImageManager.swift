//
//  PuzzleImageManager.swift
//  Puzzles
//
//  Created by Kyle Swarner on 4/16/24.
//  Copyright © 2024 Kyle Swarner. All rights reserved.
//

import SwiftUI
import CoreGraphics

@Observable
class PuzzleImageManager {
    
    var bitmap: CGContext
    var clipping = false
    var defaultColor = CGColor(red: 0, green: 1, blue: 0, alpha: 1)
    
    var cachedBitmap: CGContext?
    var displayedImage: CGImage?
    var debugImage: CGImage?
    
    var initialDrawDone = false
    
    init(width: Int, height: Int) {
        bitmap = PuzzleImageManager.createContextManager(width: width, height: height)
        bitmap.setAllowsAntialiasing(true)
        bitmap.interpolationQuality = .high
        
        // Create a 2nd bitmap. After drawing, we'll copy updated segments into this context.
        cachedBitmap = PuzzleImageManager.createContextManager(width: width, height: height)
        //bitmap.setShouldAntialias(false)
        //bitmap.setAllowsAntialiasing(false)
        
        // The puzzle drawing APIa doesn't always fill in 100% of the space - init the bitmap with a rect matching the standard background color.
        //let backgroundColor = CGColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1)
        //drawRectangle(x: 0, y: 0, width: width, height: height, fillColor: backgroundColor)
        //cachedBitmap = bitmap
    }
    
    static func createContextManager(width: Int, height: Int) -> CGContext { //Should W & H be the same? Any non-square puzzles?
        let newBitmap = CGContext(data: nil, width: width, height: height, bitsPerComponent: 8, bytesPerRow: width * 4, space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue)
        
        guard let unwrappedBitmap = newBitmap else {
            fatalError("Error creating bitmap - cannot continue OH NOES")
        }
        
        return unwrappedBitmap
    }
    
    func toImage() -> CGImage? {
        return self.bitmap.makeImage()
    }
    
    func debug(_ message: String) {
        #if targetEnvironment(simulator)
            print("\(Date.now) \(message)")
        #endif
    }
    
    func drawText(text: String, x: Int, y: Int, fontsize: Int, horizontalAlignment: TextHorizontalAlignment, verticalAlignment: TextVerticalAlignment, color: CGColor) {
        debug("Draw Text: Printing '\(text)' at \(x)x\(y)")
        
        
        var xPosition = CGFloat(x)
        var yPosition = CGFloat(y)
        
        let font = CTFontCreateWithName("Helvetica" as CFString, CGFloat(fontsize), nil)
        
        let dictionary = [
            kCTFontAttributeName : font,
            kCTForegroundColorAttributeName : color
        ] as CFDictionary
        
        guard let attributedString = CFAttributedStringCreate(nil, text as CFString, dictionary) else {
            print("Error creating attributed string ??")
            return
        }
        
        // Here's the actual line of text we will draw onto the bitmap
        let line = CTLineCreateWithAttributedString(attributedString)
        
        // Perform horizontal alignments when needed
        if horizontalAlignment == .CENTER || horizontalAlignment == .RIGHT {
            // Comput the total width of the string - We'll use this for horizontal positioning
            let textWidth = CTLineGetOffsetForStringIndex(line, CFAttributedStringGetLength(attributedString), nil)
            
            if horizontalAlignment == .CENTER {
                xPosition -= textWidth / 2 // To center text, modify the x placement by half of the total width
            } else if horizontalAlignment == .RIGHT {
                xPosition -= textWidth
            }
        }
        
        if verticalAlignment == .CENTER {
            // To center align, we adjust the y position down based on the provided font size.
            // This isn't super precise, but 0.3 looks to work pretty well.
            yPosition -= Double(fontsize) * 0.3
        }
        
        
        bitmap.textPosition = CGPoint(x: xPosition, y: yPosition)
        CTLineDraw(line, bitmap)
    }
    
    func drawLine(from point1: CGPoint, to point2: CGPoint, color: CGColor, thickness: Float = 1.0) {
        debug("Drawing Line from \(point1.x)x\(point1.y) to \(point2.x)x\(point2.y) of thickness \(thickness)")
            
        bitmap.setStrokeColor(color)
        bitmap.setLineWidth(CGFloat(thickness))
        
        //bitmap.move(to: point1)
        //bitmap.addLine(to: point2)
        
        bitmap.strokeLineSegments(between: [point1, point2])
        //bitmap.strokePath()
        //bitmap.strokeLineSegments(between: [point1, point2])
        bitmap.setBlendMode(.normal)
    }
    
    func drawPolygon(coordinates: [CGPoint], outlineColor: CGColor, fillColor: CGColor?) {
        debug("Drawing Polygon")
        
        bitmap.beginPath()
        bitmap.move(to: coordinates[0])
        
        bitmap.setStrokeColor(outlineColor)
        
        coordinates.dropFirst().forEach { point in
            bitmap.addLine(to: point)
        }
        
        // Add final line back to the starting point to complete the polygon
        bitmap.addLine(to: coordinates[0])
        
        var drawingStyle = CGPathDrawingMode.stroke
        
        if fillColor != nil {
            bitmap.setFillColor(fillColor!) // Colors from frontend?
            drawingStyle = .fillStroke
        }
        
        bitmap.drawPath(using: drawingStyle)
    }
    
    func drawRectangle(x: Int, y: Int, width: Int, height: Int, fillColor: CGColor) {
        
        debug("Drawing Rectangle at \(x)x\(y) of size \(width)x\(height)")
        
        bitmap.setFillColor(fillColor)
        
        //bitmap?.addRect(CGRect(x: x, y: y, width: width, height: height))
        bitmap.fill([CGRect(x: x, y: y, width: width, height: height)])
    }
    
    func drawCircle(x: Int, y: Int, radius: Int, outlineColor: CGColor, fillColor: CGColor?) {
        debug("Drawing Circle at \(x)x\(y) of radius \(radius)")
        
        let rect = CGRect(
            x: CGFloat(x - radius), // Old app added 1 here
            y: CGFloat(y - radius),
            width: CGFloat(radius * 2), // Old app subtracted 1 here
            height: CGFloat(radius * 2)
        )
        
        if fillColor != nil {
            bitmap.setFillColor(fillColor!)
            bitmap.fillEllipse(in: rect)
        }
        
        bitmap.setStrokeColor(outlineColor)
        bitmap.strokeEllipse(in: rect)
        
        // Draw a circle of the provided radius + 1 to create the outline shape
        /*
        bitmap.setFillColor(outlineColor)
        bitmap.addArc(center: CGPoint(x: x, y: y), radius: CGFloat(radius + 10), startAngle: 0, endAngle: 360, clockwise: true)
        
        // Then, draw another circle with the fill color on top of it, with the requested radius
        if fillColor != nil {
            bitmap.setFillColor(fillColor!)
            bitmap.addArc(center: CGPoint(x: x, y: y), radius: CGFloat(radius + 10 - 1), startAngle: 0, endAngle: 360, clockwise: true)
        }
         */
    }
    
    func clipArea(x: Int, y: Int, width: Int, height: Int) {
        if(!clipping) {
            bitmap.saveGState()
        }
        
        bitmap.clip(to: CGRect(x: x, y: y, width: width, height: height))
        self.clipping = true
    }
    
    func unclip() {
        if(clipping) {
            bitmap.restoreGState()
        }
        self.clipping = false
    }
    
    func forceRefresh() {
        initialDrawDone = true // This is so hacky
        //bitmap.makeImage()
        //cachedBitmap!.draw(bitmap.makeImage()!, in: CGRect(x: 0, y: 0, width: puzzleDimensionsX, height: puzzleDimensionsY), byTiling: false)
        //displayedImage = cachedBitmap!.makeImage()
    }
    
    func updateRect(x: Int, y: Int, width: Int, height: Int) {
        // this is all commented out for now. Will have to investigate later.
        
        let rect = CGRect(x: x, y: y, width: width, height: height)
        
        // debugImage = bitmap.makeImage()?.cropping(to: rect)
        
        if(initialDrawDone) {
            // drawRectangle(x: x, y: y, width: width, height: height, fillColor: CGColor(red: 0, green: 1, blue: 1, alpha: 0.5))
        }
        
        let updatedImageChunk = bitmap.makeImage()?.cropping(to: rect)
        if updatedImageChunk != nil {
            // cachedBitmap?.draw(updatedImageChunk!, in: rect, byTiling: false)
            
            if(initialDrawDone) {
                cachedBitmap?.setFillColor(CGColor(red: 0, green: 1, blue: 1, alpha: 0.5))
                //bitmap?.addRect(CGRect(x: x, y: y, width: width, height: height))
                
                cachedBitmap?.fill([CGRect(x: x, y: y, width: width, height: height)])
            }
            
            // displayedImage = cachedBitmap!.makeImage()
        }
        
        
    }
    
}

extension PuzzleImageManager {
    
    func getImageFragment(x: Int, y: Int, width: Int, height: Int) -> CGImage? {
        
        let rect = CGRect(x: x, y: y, width: width, height: height)
        
        // Cropping images uses a top-left origin, rather than a bottom-left for drawing. The Y value here SHOULD NOT have been inverted.
        return bitmap.makeImage()?.cropping(to: rect)
    }
    
    func placeImageFragment(image: CGImage?, x: Int, y: Int, width: Int, height: Int) {
        
        guard let unwrappedImage = image else {
            print("No image provided when redrawing blitter")
            return
        }
        
        let rect = CGRect(x: x, y: y, width: width, height: height)
        
        bitmap.draw(unwrappedImage, in: rect, byTiling: false)
    }
    
}

