//
//  DrawingAPI.swift
//  Puzzles
//
//  Created by Kyle Swarner on 4/18/24.
//  Copyright © 2024 Kyle Swarner. All rights reserved.
//

import Foundation
import CoreGraphics

/**
 Enums used as part of text drawing to simplify the drawing interface (instead of Int32 values)
 */
enum TextHorizontalAlignment {
    case LEFT, CENTER, RIGHT
}

enum TextVerticalAlignment {
    case BASELINE, CENTER
}


/**
 Our implementation for a Blitter type - this is used as part of new/save/load/free blitter, which is used to store & redraw sections of the puzzle.
 */
class Blitter {
    let w: Int
    let h: Int
    var x: Int
    var y: Int
    var xAdjustment: Int
    var yAdjustment: Int
    var widthAdjusted: Int
    var heightAdjusted: Int
    var img: CGImage?
    
    init(w: Int32, h: Int32) {
        self.w = Int(w)
        self.h = Int(h)
        self.x = 0
        self.y = 0
        self.xAdjustment = 0
        self.yAdjustment = 0
        self.widthAdjusted = 0
        self.heightAdjusted = 0
        self.img = nil
    }
}

class DrawingAPI {
    
    private init() {
        
    }
    
    /**
     Builds the drawing API that is passed to the puzzles app via the midend.
     Note that the methods referenced below are all set globally - this is needed as a swift limitation for our interactions with the C code.
     */
    static func constructAPI() -> drawing_api {
        return drawing_api(
            version: 1,
            draw_text: drawText,
            draw_rect: drawRect,
            draw_line: drawLine,
            draw_polygon: drawPolygon,
            draw_circle: drawCircle,
            draw_update: drawUpdate,
            clip: clipSegment,
            unclip: unclipSegment,
            start_draw: startDraw,
            end_draw: endDraw,
            status_bar: updateStatusBar,
            blitter_new: newBlitter,
            blitter_free: freeBlitter,
            blitter_save: saveBlitter,
            blitter_load: loadBlitter,
            begin_doc: nil, // These undefined methods are used by the puzzle app's printing capability, which is not provided by this app.
            begin_page: nil,
            begin_puzzle: nil,
            end_puzzle: nil,
            end_page: nil,
            end_doc: nil,
            line_width: nil,
            line_dotted: nil,
            text_fallback: textFallback,
            draw_thick_line: nil // Using drawThickLine directly seems to introduce bugs in a few game. Removing it forces games to fall back on drawPolygon, which seems to work pretty consistently.
            
           )
    }
    
    /**
     Wrap the above drawing API as a pointer, as needed for the midend construction interface.
     */
    static func asPointer() -> UnsafeMutablePointer<drawing_api> {
        let drawingApiPointer = UnsafeMutablePointer<drawing_api>.allocate(capacity: 1)
        drawingApiPointer.pointee = constructAPI()
        return drawingApiPointer
    }
    
}

//MARK: Helpers for the drawing functions
// Functions that help clean up boilerplate in the drawing functions - mostly extracting things from pointers

/**
 Retrieves the `Frontend` from a pointer to a `drawing` object
 */
func retrieveFrontendFromDrawing(_ drawing: UnsafeMutablePointer<drawing>?) -> Frontend {
    let pointer = drawing?.pointee.handle.bindMemory(to: Frontend.self, capacity: 1)
    
    guard let pointer = pointer else {
        //aw shoot
        fatalError("Drawing object was not available while drawing API within code. Cannot continue.")
    }
    
    return pointer.pointee
}

/**
 Retrieves the `Frontend` from an untyped pointer. Used from `GlobalFunctions` in additiona to this class
 */
func retrieveFrontendFromPointer(_ fePointer: UnsafeMutableRawPointer?) -> Frontend {
    let pointer = fePointer?.bindMemory(to: Frontend.self, capacity: 1)
    
    guard let pointer = pointer else {
        fatalError("Frontend could not be obtained from pointer. Critical internal error")
    }
    
    return pointer.pointee
}

func getImageManager(drawing: UnsafeMutablePointer<drawing>?) -> PuzzleImageManager {
    return retrieveFrontendFromDrawing(drawing).imageManager! // TODO: Force unwrap, can this be better?
}

func getColorByIndex(drawing: UnsafeMutablePointer<drawing>?, colorIndex: Int32) -> CGColor {
    
    let frontend = retrieveFrontendFromDrawing(drawing)
    let colorIndexInt = Int(colorIndex)
    
    // The puzzles app will send a -1 when there should be no color. This happens for some shapes when an outline is needed but no fill color.
    guard colorIndex > -1 else {
        fatalError("A negative color index has not been accounted for in code.")
    }
    
    guard colorIndexInt <= frontend.numColors else {
        print("Color Error: Request color index that does not exist")
        return CGColor(red: 0, green: 0, blue: 0, alpha: 1) // Return black as a default color
    }
    
    // If dark mode is enabled, this frontend method will perform inplace color replacements for us
    return frontend.getColor(colorIndexInt)
}

/**
 The puzzles app treats the top left corner of the image as (0,0), while core graphics uses the bottom left corner. Essentially this means that all puzzles get drawn upside-down.
 This function flips Y based on the known requested image size to ensure everything renders in the correct direction. (And it goes ahead and casts to an int, for good measure)
 */
func adjustedY(_ y: Int32, height: Int32 = 0) -> Int {
    return puzzleDimensionsY - Int(y) - Int(height)
}

func adjustedYAsFloat(_ y: Float) -> Int {
    return puzzleDimensionsY - Int(y)
}

// These functions must be global in order to be referenced via C pointers (as required by the puzzle API)

// MARK: Text Drawing Methods

func drawText(drawing: UnsafeMutablePointer<drawing>?, x: Int32, y: Int32, fontType: Int32, fontSize: Int32, align: Int32, color: Int32, textPointer: UnsafePointer<CChar>?) {
    debug("Draw Text Called")
    
    guard let text = textPointer else {
        return
    }
    
    var verticalAlignment: TextVerticalAlignment = .BASELINE
    var horizontalAlignment: TextHorizontalAlignment = .LEFT
    
    /*
     The alignment variable is a bitwise OR indicating both horizontal & vertical alignment
     
     ALIGN_VNORMAL
        Indicates that y is aligned with the baseline of the text.
     ALIGN_VCENTRE
        Indicates that y is aligned with the vertical centre of the text. (In fact, it's aligned with the vertical centre of normal capitalised text: displaying two pieces of text with ALIGN_VCENTRE at the same y-coordinate will cause their baselines to be aligned with one another, even if one is an ascender and the other a descender.)
     ALIGN_HLEFT
        Indicates that x is aligned with the left-hand end of the text.
     ALIGN_HCENTRE
        Indicates that x is aligned with the horizontal centre of the text.
     ALIGN_HRIGHT
        Indicates that x is aligned with the right-hand end of the text.
     */
    
    switch (align & (ALIGN_HLEFT | ALIGN_HCENTRE | ALIGN_HRIGHT)) {
    case ALIGN_HCENTRE:
        horizontalAlignment = .CENTER
    case ALIGN_HRIGHT:
        horizontalAlignment = .RIGHT
    default: // ALIGN_LEFT
        horizontalAlignment = .LEFT
    }
    
    switch (align & (ALIGN_VNORMAL | ALIGN_VCENTRE)) {
    case ALIGN_VCENTRE:
        verticalAlignment = .CENTER
    default: // ALIGN_VNORMAL
        verticalAlignment = .BASELINE
    }
    
    getImageManager(drawing: drawing).drawText(
        text: String.init(cString: text),
        x: Int(x),
        y: adjustedY(y),
        fontsize: Int(fontSize),
        horizontalAlignment: horizontalAlignment,
        verticalAlignment: verticalAlignment,
        color: getColorByIndex(drawing: drawing, colorIndex: color))
    
    // Force update resolves issues seen in Unequal where the image was being updated before new text was drawn, but not after.
    forceImageUpdate(drawing: drawing)
}

/**
 Text fallback is used to handle UTF-8 strings that may not be handled by some platforms. It typically returns two values, the UTF-8 one and a fallback ASCII value.
 iOS can handle the UTF-8 values just fine - so we should be able to just grab the first item.
 */
func textFallback(drawing: UnsafeMutablePointer<drawing>?, strings: UnsafePointer<UnsafePointer<CChar>?>?, numStrings: Int32) -> UnsafeMutablePointer<CChar>? {
    
    guard let unwrappedStrings = strings else {
        return nil
    }
    
    guard numStrings > 0 else {
        return nil
    }
    
    // We should always be able to grab the first object in the list..
    // However, Swift will automatically deallocate the provided pointers; We can't use them directly as this causes issues when the puzzles code tries to free the memory itself.
    // This creates our own copy of the string & provides it as a self-allocated pointer that swift won't automatically free up.
    let string = String(cString: unwrappedStrings[0]!)
    
    // Convert the Swift String to a null-terminated C string
    let cString = string.cString(using: .utf8)!

    // Allocate memory for the C string and copy the contents
    let pointer = UnsafeMutablePointer<CChar>.allocate(capacity: cString.count)
    
    // Loop over the cString array and allocate the pointer with the bytes of the UTF-8 String
    for index in 0..<cString.count {
        pointer[index] = cString[index]
    }

    return pointer
}

// MARK: Lines & Shapes Drawing Methods

/**
 Draw a rectangle on the image with the provided size, position, and color
 */
func drawRect(drawing: UnsafeMutablePointer<drawing>?, x: Int32, y: Int32, width: Int32, height: Int32, color: Int32) {
    let fillColor = getColorByIndex(drawing: drawing, colorIndex: color)
    
    getImageManager(drawing: drawing).drawRectangle(x: Int(x), y: adjustedY(y, height: height), width: Int(width), height: Int(height), fillColor: fillColor)
    
    // Palisade doesn't send image updates after drawing rectangles, so this is required here
    forceImageUpdate(drawing: drawing)
}

/**
 Draw a line on the puzzle image given two points and color. The thickness of this line is always consistent.
 */
func drawLine(drawing: UnsafeMutablePointer<drawing>?, x1: Int32, y1: Int32, x2: Int32, y2: Int32, color: Int32) {
    debug("Draw Line: Called")
    
    getImageManager(drawing: drawing).drawLine(
        from: CGPoint(x: Int(x1), y: adjustedY(y1)),
        to: CGPoint(x: Int(x2), y: adjustedY(y2)),
        color: getColorByIndex(drawing: drawing, colorIndex: color),
        thickness: 1.0)
    
}

/**
 Draw a line of the provided thickness onto the bitmap
 */
func drawThickLine(drawing: UnsafeMutablePointer<drawing>?, thickness: Float, x1: Float, y1: Float, x2: Float, y2: Float, color: Int32) {

    getImageManager(drawing: drawing).drawLine(
        from: CGPoint(x: Int(x1), y: adjustedYAsFloat(y1)),
        to: CGPoint(x: Int(x2), y: adjustedYAsFloat(y2)),
        color: getColorByIndex(drawing: drawing, colorIndex: color),
        thickness: thickness)
}

/**
 Draw a polygon shape using an array of points and the outline color. A fill color can optionally be provided.
 */
func drawPolygon(drawing: UnsafeMutablePointer<drawing>?, coordinates: UnsafePointer<Int32>?, nPoints: Int32, fillColor: Int32, outlineColor: Int32) {
    debug("Draw Polygon Called, outlineColor: \(Int(outlineColor)), fill Color: \(Int(fillColor))")
    
    let numPoints = Int(nPoints)
    
    var points: [CGPoint] = []
    
    // Iterate over the array of values to construct an array of CGPoints
    for i in 0..<numPoints {
        let newPoint = CGPoint(x: Int(coordinates?[i*2] ?? 0), y: adjustedY(coordinates?[i*2+1] ?? 0))
        points.append(newPoint)
    }
    
    let outlineColor = getColorByIndex(drawing: drawing, colorIndex: outlineColor)
    let fillColor: CGColor? = fillColor != -1 ? getColorByIndex(drawing: drawing, colorIndex: fillColor) : nil // The fill color will occasionally come back as -1, indicating there should be no fill.
    
    getImageManager(drawing: drawing).drawPolygon(coordinates: points, outlineColor: outlineColor, fillColor: fillColor)
    
    // force update resolves some images with drawing polygons during drag events, such as the arrow movements in signpost.
    forceImageUpdate(drawing: drawing)
}

func drawCircle(drawing: UnsafeMutablePointer<drawing>?, cx: Int32, cy: Int32, radius: Int32, fillColor: Int32, outlineColor: Int32) {
    debug("Called: Draw Circle")
    
    getImageManager(drawing: drawing).drawCircle(x: Int(cx), y: adjustedY(cy), radius: Int(radius),
        outlineColor: getColorByIndex(drawing: drawing, colorIndex: outlineColor),
        fillColor: fillColor != -1 ? getColorByIndex(drawing: drawing, colorIndex: fillColor) : nil)
    
    forceImageUpdate(drawing: drawing)
}

// MARK: Drawing Update Methods

func drawUpdate(drawing: UnsafeMutablePointer<drawing>?, x: Int32, y: Int32, w: Int32, h: Int32) {
    
    // The intention of this function is to update only a section of the puzzle image based on need. However, iOS is pretty effecient in spitting out new bitmaps and splitting sections out would actually be _more_ intensive.
    // So instead, any update to the image forces a complete refresh of the image.
    
    debug("!!! Called: Draw Update: x:\(Int(x)) y:\(Int(y)) size \(Int(w))x\(Int(h))")
    //getImageManager(frontend: frontend).updateRect(x: Int(x), y: adjustedY(y, height: h), width: Int(w), height: Int(h))
    retrieveFrontendFromDrawing(drawing).refreshImage()
}

/**
 To resolve some bugs, it's occasionally needed to force a drawing update to ensure it renders correctly.
 */
func forceImageUpdate(drawing: UnsafeMutablePointer<drawing>?) {
    let frontend = retrieveFrontendFromDrawing(drawing)
    frontend.refreshImage()
}

// MARK: Clipping Methods

func clipSegment(drawing: UnsafeMutablePointer<drawing>?, x: Int32, y: Int32, width: Int32, height: Int32) {
    debug("Called: Clip")
    
    getImageManager(drawing: drawing).clipArea(x: Int(x), y: adjustedY(y, height: height), width: Int(width), height: Int(height))
}

func unclipSegment(drawing: UnsafeMutablePointer<drawing>?) {
    getImageManager(drawing: drawing).unclip()
}


// MARK: Status Bar Methods

/**
 Save & serve the updated text for the status bar.
 */
func updateStatusBar(drawing: UnsafeMutablePointer<drawing>?, text: UnsafePointer<CChar>?) {
    
    guard let unwrappedText = text else {
        print("Statusbar error: text pointer undefined")
        return
    }
    
    let unwrappedFrontend = retrieveFrontendFromDrawing(drawing)
    
    
    let statusText = String(cString: unwrappedText)
    unwrappedFrontend.statusbarText = statusText
}

// MARK: Blitter Functions

/**
    newBlitter creates an object intended to store a fragment of the generated image in memory. This object can be used to periodically save the state of the image to 'replay' it, often during animations, to prevent artifacting.
    This function is typically called _before the image is drawn_ and establishes the width & height of the image that will be needed.
 */
func newBlitter(drawing: UnsafeMutablePointer<drawing>?, w: Int32, h: Int32) -> OpaquePointer? {
    
    let blitter = Blitter(w: w, h: h)
    
    let pointer = UnsafeMutablePointer<Blitter>.allocate(capacity: 1)
    pointer.initialize(to: blitter)
    
    return OpaquePointer(pointer)
    
}

/**
    Deallocate a generated blitter.
 */
func freeBlitter(drawing: UnsafeMutablePointer<drawing>?, blitterPointer: OpaquePointer?) {
    
    let blitterRef = UnsafePointer<Blitter>(blitterPointer)
    
    if blitterRef?.pointee != nil {
        blitterRef?.deallocate()
    }
    
}

/**
 saveBlitter stores a fragment of the current puzzle image in memeory.
 The width and height were already provided during `newBlitter`, this function provides the x & y coordinates of where that section should be taken.
 */
func saveBlitter(drawing: UnsafeMutablePointer<drawing>?, blitterPointer: OpaquePointer?, x: Int32, y: Int32) {
    debug("--- Saving Blitter! X:\(Int(x)) Y:\(Int(y)) --- ")
    
    let intermediatePointer = UnsafePointer<Blitter>(blitterPointer)
    
    if let blitter = intermediatePointer?.pointee {
        
        // When a blitter is created near the edge of the puzzle screen, the sizing of the image and it's x/y position changes, causing visual issues
        // To resolve, we look for the intersection
        let puzzleRect = CGRect(x: 0, y: 0, width: puzzleDimensionsX, height: puzzleDimensionsY)
        let visibleArea = puzzleRect.intersection(CGRect(x: CGFloat(x), y: CGFloat(y), width: CGFloat(blitter.w), height: CGFloat(blitter.h)))
        
        guard !visibleArea.isNull else {
            // print("Blitter: No overlap, exiting")
            blitter.img = nil
            return
        }
        
        // Store the diff between the original values & actual
        let xAdjustment = Int(visibleArea.origin.x) - Int(x)
        let yAdjustment = Int(visibleArea.origin.y) - Int(y)
        
        
        // Note that unlike all other calls, the Y value here is NOT inverted. Image cropping appears to have an inverted Y axis vs. drawing methods, so we DO NOT invert here.
        // This uses the bounds and positioning of the intersection - most times, it will be the same, but on the edges they'll be slightly different.
        let image = getImageManager(drawing: drawing).getImageFragment(x: Int(visibleArea.origin.x), y: Int(visibleArea.origin.y), width: Int(visibleArea.width), height: Int(visibleArea.height))
        
        // Store the provided image for use later when loading!
        blitter.img = image
        
        // Save the info we used to obtain the image; This will all be needed later when reloading the image.
        //blitter.x = Int(x)
        //blitter.y = Int(y)
        blitter.widthAdjusted = Int(visibleArea.width)
        blitter.heightAdjusted = Int(visibleArea.height)
        blitter.xAdjustment = xAdjustment
        blitter.yAdjustment = yAdjustment
        
    }
    
    
}

/**
 Reload a fragment of the puzzle image to the provided coordinates.
 You'll see this called during animations of items sliding across the screen or in response to a drag event.
 */
func loadBlitter(drawing: UnsafeMutablePointer<drawing>?, blitterPointer: OpaquePointer?, x: Int32, y: Int32) {
    debug("-- Loading Blitter... --")
    let intermediatePointer = UnsafePointer<Blitter>(blitterPointer)
    
    if let blitter = intermediatePointer?.pointee {
        
        guard blitter.img != nil else {
            print("Loading Blitter: No image, exiting")
            return
        }
        
        var xPosition = Int(x)
        var yPosition = Int(y)
        
        // Apply the adjustments from above to account for out-of-bounds drawing.
        xPosition += blitter.xAdjustment
        yPosition += blitter.yAdjustment
        
        // You DO still need to invert y when placing the image back on the grid, as the drawing API uses bottom-left origin vs the crop's top-left.
        // Note: Very important that this only be done AFTER you apply the above adjustment.
        yPosition = adjustedY(Int32(yPosition), height: Int32(blitter.heightAdjusted))
        
        // Provide the stored image in the blitter for redraw to the main image
        getImageManager(drawing: drawing).placeImageFragment(image: blitter.img, x: xPosition, y: yPosition, width: blitter.widthAdjusted, height: blitter.heightAdjusted)
        
    }
}

func debug(_ message: String) {
    if DebugFlags.EnableDrawingDebugLogs {
        print("Drawing API: \(message)")
    }
}



// MARK: Unused Functions
// These functions aren't needed for our implementation, but they still need to be present for the puzzle code to function

func startDraw(drawing: UnsafeMutablePointer<drawing>?) {
        //print("Called: Start Draw")
}

func endDraw(drawing: UnsafeMutablePointer<drawing>?) {
        //print("Called: End Draw")
}
