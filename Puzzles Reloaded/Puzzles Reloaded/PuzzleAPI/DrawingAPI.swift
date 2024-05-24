//
//  DrawingAPI.swift
//  Puzzles
//
//  Created by Kyle Swarner on 4/18/24.
//  Copyright © 2024 Kyle Swarner. All rights reserved.
//

import Foundation
import CoreGraphics

enum TextHorizontalAlignment {
    case LEFT, CENTER, RIGHT
}

enum TextVerticalAlignment {
    case BASELINE, CENTER
}


// Puzzles defines an opaque `blitter` type; it is provided here.
class Blitter {
    let w: Int
    let h: Int
    var x: Int
    var y: Int
    var ox: Int // ???
    var oy: Int // ???
    var img: CGImage?
    
    init(w: Int32, h: Int32) {
        self.w = Int(w)
        self.h = Int(h)
        self.x = 42
        self.y = 42
        self.ox = -1
        self.oy = -1
        self.img = nil
    }
}

class DrawingAPI {
    
    private init() {
        
    }
    
    static func constructAPI() -> drawing_api {
        return drawing_api(
            draw_text: drawTextWrapper,
            draw_rect: drawRect,
            draw_line: drawLine,
            draw_polygon: drawPolygon,
            draw_circle: drawCircle,
            draw_update: drawUpdate,
            clip: clip,
            unclip: unclip, 
            start_draw: startDraw,
            end_draw: endDraw,
            status_bar: statusBar,
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
            //draw_thick_line: drawThickLine
        )
    }
    
    static func asPointer() -> UnsafeMutablePointer<drawing_api> {
        let drawingApiPointer = UnsafeMutablePointer<drawing_api>.allocate(capacity: 1)
        drawingApiPointer.pointee = constructAPI()
        return drawingApiPointer
    }
    
}

// These dimension variables are mutable & set globally to make it easy for the C & Swift code to interact better with each other.
var puzzleDimensionsX: Int = 512
var puzzleDimensionsY: Int = 512

//MARK: Helpers for the drawing functions
// Functions that help clean up boilerplate in the drawing functions - mostly extracting things from pointers

func retrieveFrontendFromPointer(_ fePointer: UnsafeMutableRawPointer?) -> Frontend {
    let pointer = fePointer?.bindMemory(to: Frontend.self, capacity: 1)
    return pointer!.pointee // Note: Force unwrapping the value here. Frontend _shouldn't_ ever be null, but there's really not much we can do if it isn't! TODO: Add some messaging to trace if/when this situation occurs.
}

func getImageManager(frontend: UnsafeMutableRawPointer?) -> PuzzleImageManager {
    return retrieveFrontendFromPointer(frontend).imageManager! // TODO: Force unwrap, can this be better?
}

func getColorByIndex(frontend: UnsafeMutableRawPointer?, colorIndex: Int32) -> CGColor {
    
    let frontend = retrieveFrontendFromPointer(frontend)
    let colorIndexInt = Int(colorIndex)
    
    // The puzzles app will send a -1 when there should be no color. This happens for some shapes when an outline is needed but no fill color.
    guard colorIndex > -1 else {
        fatalError("A negative color index has not been accounted for in code.")
    }
    
    guard colorIndexInt <= frontend.numColors else {
        print("Color Error: Request color index that does not exist")
        return CGColor(red: 0, green: 0, blue: 0, alpha: 1) // Return black as a default color
    }
    
    return frontend.colors[colorIndexInt]
}

/**
 The puzzles app treats the top left corner of the image as (0,0), while core graphics uses the bottom left corner. Essentially this means that all puzzles get drawn upside-down.
 This function flips Y based on the known requested image size to ensure everything renders in the correct direction. (And it goes ahead and casts to an int, for good measure)
 */
func adjustedY(_ y: Int32, height: Int32 = 0) -> Int {
    // print("Y was \(Int(y)), adjusting to \(PuzzleSettings.puzzleSize - Int(y))")
    return puzzleDimensionsY - Int(y) - Int(height)
}

func adjustedYAsFloat(_ y: Float) -> Int {
    return puzzleDimensionsY - Int(y)
}

//MARK: Global drawing functions
// These functions must be global in order to be referenced via C pointers (as required by the puzzle API)

func drawTextWrapper(frontend: UnsafeMutableRawPointer?, x: Int32, y: Int32, fontType: Int32, fontSize: Int32, align: Int32, color: Int32, textPointer: UnsafePointer<CChar>?) {
    
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
    
    getImageManager(frontend: frontend).drawText(
        text: String.init(cString: text),
        x: Int(x),
        y: adjustedY(y),
        fontsize: Int(fontSize),
        horizontalAlignment: horizontalAlignment,
        verticalAlignment: verticalAlignment,
        color: getColorByIndex(frontend: frontend, colorIndex: color))
}



//<#T##((UnsafeMutableRawPointer?, Int32, Int32, Int32, Int32, Int32) -> Void)!##((UnsafeMutableRawPointer?, Int32, Int32, Int32, Int32, Int32) -> Void)!##(UnsafeMutableRawPointer?, Int32, Int32, Int32, Int32, Int32) -> Void#>
// static void ios_draw_rect(void *handle, int x, int y, int w, int h, int colour)
func drawRect(frontend: UnsafeMutableRawPointer?, x: Int32, y: Int32, width: Int32, height: Int32, color: Int32) {
    let fillColor = getColorByIndex(frontend: frontend, colorIndex: color)
    
    getImageManager(frontend: frontend).drawRectangle(x: Int(x), y: adjustedY(y, height: height), width: Int(width), height: Int(height), fillColor: fillColor)
}
// <#T##((UnsafeMutableRawPointer?, Int32, Int32, Int32, Int32, Int32) -> Void)!##((UnsafeMutableRawPointer?, Int32, Int32, Int32, Int32, Int32) -> Void)!##(UnsafeMutableRawPointer?, Int32, Int32, Int32, Int32, Int32) -> Void#>
// static void ios_draw_line(void *handle, int x1, int y1, int x2, int y2, int colour)
func drawLine(frontend: UnsafeMutableRawPointer?, x1: Int32, y1: Int32, x2: Int32, y2: Int32, color: Int32) {
    // print("Draw Line: Called")
    
    getImageManager(frontend: frontend).drawLine(
        from: CGPoint(x: Int(x1), y: adjustedY(y1)),
        to: CGPoint(x: Int(x2), y: adjustedY(y2)),
        color: getColorByIndex(frontend: frontend, colorIndex: color),
        thickness: 1.0)
    
}

/**
 Draw a line of the provided thickness onto the bitmap
 */
func drawThickLine(frontend: UnsafeMutableRawPointer?, thickness: Float, x1: Float, y1: Float, x2: Float, y2: Float, color: Int32) {

    getImageManager(frontend: frontend).drawLine(
        from: CGPoint(x: Int(x1), y: adjustedYAsFloat(y1)),
        to: CGPoint(x: Int(x2), y: adjustedYAsFloat(y2)),
        color: getColorByIndex(frontend: frontend, colorIndex: color),
        thickness: thickness)
}

/*
 static void ios_draw_polygon(void *handle, int *coords, int npoints,
                              int fillcolour, int outlinecolour)
 <#T##((UnsafeMutableRawPointer?, UnsafePointer<Int32>?, Int32, Int32, Int32) -> Void)!##((UnsafeMutableRawPointer?, UnsafePointer<Int32>?, Int32, Int32, Int32) -> Void)!##(UnsafeMutableRawPointer?, UnsafePointer<Int32>?, Int32, Int32, Int32) -> Void#>
 */
func drawPolygon(frontend: UnsafeMutableRawPointer?, coordinates: UnsafePointer<Int32>?, nPoints: Int32, fillColor: Int32, outlineColor: Int32) {
    //print("Draw Polygon Called, outlineColor: \(Int(outlineColor)), fill Color: \(Int(fillColor))")
    
    let numPoints = Int(nPoints)
    
    var points: [CGPoint] = []
    
    // SUPPOSEDLY, we can `advance` the pointer to get at the list of objects. The pointer SHOULD know the size to advance by because it is scoped to the object type already.
    for i in 0..<numPoints {
        let newPoint = CGPoint(x: Int(coordinates?[i*2] ?? 0), y: adjustedY(coordinates?[i*2+1] ?? 0))
        points.append(newPoint)
        //print("Point \(i), x at [\(i*2)): \(coordinates?[i*2]), y at [\(i*2 + 1)]: \(coordinates?[i*2+1]))")
        //let objPointer = coordinates.unsafelyUnwrapped.advanced(by: i)
        //let object = objPointer.pointee // Access the object at the current pointer position
        
    }
    
    let outlineColor = getColorByIndex(frontend: frontend, colorIndex: outlineColor)
    let fillColor: CGColor? = fillColor != -1 ? getColorByIndex(frontend: frontend, colorIndex: fillColor) : nil // The fill color will occasionally come back as -1, indicating there should be no fill.
    
    getImageManager(frontend: frontend).drawPolygon(coordinates: points, outlineColor: outlineColor, fillColor: fillColor)
    //let imageManager = retrieveFrontendFromPointer(frontend).gameView.imageManager
    //imageManager.drawPolygon(coordinates: points2)
    //print(points)
}

func unwrapPointerToArray<T>(pointer: UnsafePointer<T>, numObjects: Int32) -> [T] {
    var returnArray: [T] = []
    
    for i in 0..<Int(numObjects) {
        let objPointer = pointer.advanced(by: i) // Should we unwrap the pointer for us here?
        let object = objPointer.pointee // Access the object at the current pointer position
        print(object)
        returnArray.append(object)
    }
            
    return returnArray
            
}

func drawCircle(frontend: UnsafeMutableRawPointer?, cx: Int32, cy: Int32, radius: Int32, fillColor: Int32, outlineColor: Int32) {
    //print("Called: Draw Circle")
    
    getImageManager(frontend: frontend).drawCircle(x: Int(cx), y: adjustedY(cy), radius: Int(radius),
        outlineColor: getColorByIndex(frontend: frontend, colorIndex: outlineColor),
        fillColor: fillColor != -1 ? getColorByIndex(frontend: frontend, colorIndex: fillColor) : nil)
}

func drawUpdate(frontend: UnsafeMutableRawPointer?, x: Int32, y: Int32, w: Int32, h: Int32) {
    // This function informs the frontend what sections have been updated in order to run a targeted refresh of the UI.
    // I don't like this process as it's more CPU intensive to do so - but seems to fix some bugs in some potentially "poorly optimized" games (looking at you, tents!)
    
    //print("!!! Called: Draw Update: x:\(Int(x)) y:\(Int(y)) size \(Int(w))x\(Int(h))")
    getImageManager(frontend: frontend).updateRect(x: Int(x), y: adjustedY(y, height: h), width: Int(w), height: Int(h))
    retrieveFrontendFromPointer(frontend).refreshImage() // Unsure which way will work best!
    ///TODO Is there a way to get CGContext & Image to honor updating just the provided area?
}

func clip(frontendPointer: UnsafeMutableRawPointer?, x: Int32, y: Int32, width: Int32, height: Int32) {
    //print("Called: Clip")
    
    getImageManager(frontend: frontendPointer).clipArea(x: Int(x), y: adjustedY(y, height: height), width: Int(width), height: Int(height))
}

func unclip(frontend: UnsafeMutableRawPointer?) {
    getImageManager(frontend: frontend).unclip()
}

func startDraw(frontend: UnsafeMutableRawPointer?) {
        //print("Called: Start Draw")
}

func endDraw(frontend: UnsafeMutableRawPointer?) {
        //print("Called: End Draw")
}

func statusBar(frontend: UnsafeMutableRawPointer?, text: UnsafePointer<CChar>?) {
    
    guard let unwrappedText = text else {
        print("Statusbar error: text pointer undefined")
        return
    }
    
    let unwrappedFrontend = retrieveFrontendFromPointer(frontend)
    
    
    let statusText = String(cString: unwrappedText)
    unwrappedFrontend.statusbarText = statusText
}


/**
    newBlitter creates an object intended to store a fragment of the generated image in memory. This object can be used to periodically save the state of the image to 'replay' it, often during animations, to prevent artifacting.
    This function is typically called _before the image is drawn_ and establishes the width & height of the image that will be needed.
 */
func newBlitter(frontend: UnsafeMutableRawPointer?, w: Int32, h: Int32) -> OpaquePointer? {
    //Create & Return a new 'blitter'
    print("Creating Blitter w:\(Int(w)) h:\(Int(h))")
    
    let blitter = Blitter(w: w, h: h)
    
    let pointer = UnsafeMutablePointer<Blitter>.allocate(capacity: 1)
    pointer.initialize(to: blitter)
    
    return OpaquePointer(pointer)
    
}

/**
    Deallocate a generated blitter.
 */
func freeBlitter(fontend: UnsafeMutableRawPointer?, blitterPointer: OpaquePointer?) {
    print("Freeing Blitter")
    
    let blitterRef = UnsafePointer<Blitter>(blitterPointer)
    
    if blitterRef?.pointee != nil {
        blitterRef?.deallocate()
    }
    
}

/**
saveBlitter stores a fragment of the current puzzle image in memeory.
 The width and height were already provided during `newBlitter`, this function provides the x & y coordinates of where that section should be taken.
 */
func saveBlitter(frontend: UnsafeMutableRawPointer?, blitterPointer: OpaquePointer?, x: Int32, y: Int32) {
    print("BBBBBBB Saving Blitter! X:\(Int(x)) Y:\(Int(y))")
    
    //Unmanaged<Blitter>.fromOpaque(UnsafeRawPointer(b)).takeRetainedValue()
    
    
    let intermediatePointer = UnsafePointer<Blitter>(blitterPointer)
    
    if let blitter = intermediatePointer?.pointee {
        print ("Found Blitter: w:\(blitter.w) h:\(blitter.h) x:\(blitter.x) y:\(blitter.y)")
        
        
        // TODO: There are provisions in the puzzle documentation for when x y overflows from bounds. I haven't seen the need for it _yet_
        
        // Note that unlike all other calls, the Y value here is NOT inverted. Image cropping appears to have an inverted Y axis vs. drawing methods, so we DO NOT invert here.
        //
       let image = getImageManager(frontend: frontend).getImageFragment(x: Int(x), y: Int(y), width: blitter.w, height: blitter.h)
        blitter.img = image
        
        // Save the positions the image was retreived from in the blitter. These may be needed later!
        blitter.x = Int(x)
        blitter.y = Int(y)
    }
    
    
}

func loadBlitter(frontend: UnsafeMutableRawPointer?, blitterPointer: OpaquePointer?, x: Int32, y: Int32) {
    let intermediatePointer = UnsafePointer<Blitter>(blitterPointer)
    
    if let blitter = intermediatePointer?.pointee {
        print ("Redrawing Blitter: w:\(blitter.w) h:\(blitter.h) at x:\(Int(x)) y:\(Int(y))")
        
        if x == BLITTER_FROMSAVED {
            print("Drawing from SAVED VALUES")
        }
        
        // The x & y values either be placement positions OR the special value 'BLITTER_FROMSAVED'
        // When this occurs, restore the saved image to the location it was originally taken from.
        let xPosition = x == BLITTER_FROMSAVED ? blitter.x : Int(x)
        let yPosition = y == BLITTER_FROMSAVED ? blitter.y : adjustedY(y, height: Int32(blitter.h))
        
        
        // Provide the stored image in the blitter for redraw to the main image
        // you DO still need to invert y when placing the image back on the grid, as the drawing API uses bottom-left origin vs the crop's top-left.
        getImageManager(frontend: frontend).placeImageFragment(image: blitter.img, x: xPosition, y: yPosition, width: blitter.w, height: blitter.h)
        
    }
}

func textFallback(frontend: UnsafeMutableRawPointer?, strings: UnsafePointer<UnsafePointer<CChar>?>?, numStrings: Int32) -> UnsafeMutablePointer<CChar>? {
    
    guard let unwrappedStrings = strings else {
        return nil
    }
    
    guard numStrings > 0 else {
        return nil
    }
    
    // Text fallback is used to handle UTF-8 strings that may not be handled by some platforms. It typically returns two values, the UTF-8 one and a fallback ASCII value.
    // iOS can handle the UTF-8 values just fine - so we should be able to just grab the first item.
    
    // However, Swift will automatically deallocate the provided pointers; We can't use them directly as this causes issues when the puzzles code tries to free the memory itself.
    // This creates our own copy of the string & provides it as a self-allocated pointer that swift wonI't automatically free up.
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

