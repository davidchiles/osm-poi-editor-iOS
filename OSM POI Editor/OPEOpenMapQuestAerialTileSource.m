//
//  OPEOpenMapQuestAerialTileSource.m
//  OSM POI Editor
//
//  Created by David on 11/27/12.
//
//

#import "OPEOpenMapQuestAerialTileSource.h"

@implementation OPEOpenMapQuestAerialTileSource


-(id) init
{
    if (!(self = [super init]))
        return nil;
    
    self.minZoom = 1;
    self.maxZoom = 18;
    
	return self;
}

@end
