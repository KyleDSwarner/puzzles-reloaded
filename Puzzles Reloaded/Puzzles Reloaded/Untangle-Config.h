//
//  Untangle-Config.h
//  Puzzles Reloaded
//
//  Created by Kyle Swarner on 5/28/24.
//  Copyright © 2024 Kyle Swarner. All rights reserved.
//

// This file is attached to untangle.c during compilation to modify definitions. This is needed to affect the presentation of dots to a reasonable size on touchscreens.

// NOTE: requires we modify untangle.c in order to allow these definitions to take effect. The push upstream is pending!


#ifndef Untangle_Config_h
#define Untangle_Config_h

#define CIRCLE_RADIUS (ds->tilesize/8)
#define DRAG_THRESHOLD (CIRCLE_RADIUS * 4)

#endif /* Untangle_Config_h */
