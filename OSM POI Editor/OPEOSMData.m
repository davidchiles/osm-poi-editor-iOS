//
//  OSMData.m
//  OSM POI Editor
//
//  Created by David Chiles on 2/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "OPEOSMData.h"

@implementation OPEOSMData

@synthesize bboxleft, bboxbottom, bboxright, bboxtop, allNodes;


-(id) initWithLeft:(double) lef bottom: (double) bot right: (double) rig top: (double) to
{
    
    self = [super init];
    if(self)
    {
        bboxleft = lef;
        bboxbottom = bot;
        bboxright = rig;
        bboxtop = to;
    }
    return self;
}

-(void) getData
{
    NSURL* url = [NSURL URLWithString: [NSString stringWithFormat:@"http://www.overpass-api.de/api/xapi?node[bbox=%d,%d,%d,%d]",bboxleft,bboxbottom,bboxright,bboxtop]];
    NSLog(@"url: %@",[url relativeString]);
    
    
    
}



@end
