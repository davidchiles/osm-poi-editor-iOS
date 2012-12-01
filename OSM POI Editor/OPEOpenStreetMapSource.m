//
//  OPEOpenStreetMapSource.m
//  OSM POI Editor
//
//  Created by David on 11/30/12.
//
//

#import "OPEOpenStreetMapSource.h"

@implementation OPEOpenStreetMapSource


-(id) init
{
    if (!(self = [super init]))
        return nil;
    
    self.minZoom = 1;
    self.maxZoom = 19;
    
	return self;
}

@end