//
//  Midend-UserPreferences.swift
//  Puzzles Reloaded
//
//  Created by Kyle Swarner on 6/6/24.
//  Copyright © 2024 Kyle Swarner. All rights reserved.
//

import Foundation

class SaveContext {
    var position: Int = 0 // Since file reads occur in chunks, this keeps track of what has already been read.
    var prefData: NSMutableString = ""
    
    func saveToString() -> String? {
        return prefData as String
    }
    
    init() {
        self.prefData = ""
    }
    
    init(savegame: String?) {
        self.prefData = NSMutableString(string: savegame ?? "")
    }
}

func midend_getPrefContext(_ context: UnsafeMutableRawPointer?) -> SaveContext {
    let pointer = context?.bindMemory(to: SaveContext.self, capacity: 1)
    return pointer!.pointee // Note: Force unwrapping the value here. Frontend _shouldn't_ ever be null, but there's really not much we can do if it isn't! TODO: Add some messaging to trace if/when this situation occurs.
}

/**
 Global function used as part of writing preferences to a longer string.
 This will be called multiple times and build the final preference string over time.
 */
func midend_writeFile(context: UnsafeMutableRawPointer?, buffer: UnsafeRawPointer?, length: Int32) {
   
    let saveContext = midend_getPrefContext(context)
    
    guard let unwrappedBuffer = buffer else {
        return
    }
    
    let convertedstring = NSString(bytes: unwrappedBuffer, length: Int(length), encoding: NSUTF8StringEncoding)
    
    guard let fileString = convertedstring as? String else {
        return
    }
    
    saveContext.prefData.append(fileString)
}



func midend_writeSave(context: UnsafeMutableRawPointer, buffer: UnsafeRawPointer?, length: Int32) {
    
}

func midend_readFile(context: UnsafeMutableRawPointer?, buffer: UnsafeMutableRawPointer?, length: Int32) -> Bool {
    
    guard let unwrappedBuffer = buffer else {
        return false
    }
    
    let context = midend_getPrefContext(context)
    
    //let convertedstring = NSString(bytes: unwrappedBuffer, length: Int(length), encoding: NSUTF8StringEncoding)
    
    guard context.prefData.length > 0 else {
        return false
    }
    
    var usedBytes: Int = 0
    
    let someBytesCopied = context.prefData.getBytes(buffer, maxLength: Int(length), usedLength: &usedBytes, encoding: NSUTF8StringEncoding, range: NSMakeRange(context.position, context.prefData.length - context.position), remaining: nil)
    context.position += usedBytes
    
    return someBytesCopied
    
    /*
    NSUInteger used = 0;
    BOOL r = [save getBytes:buf maxLength:len usedLength:&used encoding:NSUTF8StringEncoding options:0 range:NSMakeRange(srctx->pos, save.length-srctx->pos) remainingRange:NULL];
    srctx->pos += used;
    return r;
     */
}

extension Midend {
    
    /**
     Saves user-configured game settings to a string
     */
    func saveUserPrefs() -> String? {
        var newSave = SaveContext() // Test...
        //midend_save_prefs(midendPointer, midend_writeFile, newSave)
        
        withUnsafePointer(to: newSave) { savePointer in
            midend_save_prefs(midendPointer, midend_writeFile, UnsafeMutableRawPointer(mutating: savePointer))
        }
        
        return newSave.saveToString()
    }
    
    func loadUserPrefs(preferences: String?) {
        
        guard preferences != nil else {
            print("No user preferences provided")
            return
        }
        
        let wrappedPrefs = SaveContext(savegame: preferences)
        
        withUnsafePointer(to: wrappedPrefs) { pointer in
            let error = midend_load_prefs(midendPointer, midend_readFile, UnsafeMutableRawPointer(mutating: pointer))
            
            if error != nil {
                let errString = String(cString: error!)
                print(errString)
            }
            
        }
    }
    
    func saveInProgressGame() -> SaveContext? {
        print("Attempting to Save Game")
        // Verify we should save a game - if we're at the beginning or end of a game, we shouldn't!
        let shouldSave = midend_can_undo(midendPointer) && self.getPuzzleStatus() == .INPROGRESS
        
        if !shouldSave {
            print("Game Not In Progress, closing")
            return nil
        }
        
        // We shouldn't actually use this object, I'm guessing. doot doot doot
        var newSave = SaveContext() // Test...
        
        withUnsafePointer(to: &newSave) { savePointer in
            midend_serialise(midendPointer, midend_writeFile, UnsafeMutableRawPointer(mutating: savePointer))
        }
        
        return newSave
    }
    
    func readSave(_ savegame: SaveContext?) {
        
        guard var save = savegame else {
            return
        }
        
        withUnsafePointer(to: save) { savePointer in
            let result = midend_deserialise(midendPointer, midend_readFile, UnsafeMutableRawPointer(mutating: savePointer))
        }
    }
    

    
    /*

     static void saveGameWrite(void *ctx, void *buf, int len)
     {
         NSMutableString *save = (__bridge NSMutableString *)(ctx);
         [save appendString:[[NSString alloc] initWithBytes:buf length:len encoding:NSUTF8StringEncoding]];
     }

     - (NSString *)saveGameState_inprogress:(BOOL *)inprogress
     {
         if (me == NULL) {
             return nil;
         }
         *inprogress = midend_can_undo(me) && midend_status(me) == 0;
         NSMutableString *save = [[NSMutableString alloc] init];
         // midend_serialise(me, saveGameWrite, (__bridge void *)(save));
         return save;
     }

     struct StringReadContext {
         void *save;
         int pos;
     };

     static int saveGameRead(void *ctx, void *buf, int len)
     {
         struct StringReadContext *srctx = (struct StringReadContext *)ctx;
         NSString *save = (__bridge NSString *)(srctx->save);
         NSUInteger used = 0;
         BOOL r = [save getBytes:buf maxLength:len usedLength:&used encoding:NSUTF8StringEncoding options:0 range:NSMakeRange(srctx->pos, save.length-srctx->pos) remainingRange:NULL];
         srctx->pos += used;
         return r;
     }

     - (void)loadPrefs
     {
         NSString *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
         NSString *prefs = [NSString stringWithContentsOfFile:[NSString stringWithFormat:@"%@/%s.prefs", path, ourgame->name] encoding:NSUTF8StringEncoding error:NULL];
         if (prefs != nil) {
             struct StringReadContext srctx;
             srctx.save = (__bridge void *)(prefs);
             srctx.pos = 0;
             //midend_load_prefs(me, saveGameRead, &srctx);
         }
     }

     // Saves preferences to a local file, based on the name. Then we read it back out later.
     - (void)savePrefs
     {
         NSString *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
         NSMutableString *prefs = [[NSMutableString alloc] init];
         //midend_save_prefs(me, saveGameWrite, (__bridge void *)(prefs));
         [prefs writeToFile:[NSString stringWithFormat:@"%@/%s.prefs", path, ourgame->name] atomically:YES encoding:NSUTF8StringEncoding error:NULL];
         midend_force_redraw(me);
     }
     */
}


