//
//  OSMData.h
//  OSM POI Editor
//
//  Created by David Chiles on 2/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OPEOSMData : NSObject

@property double bboxleft;
@property double bboxbottom;
@property double bboxright;
@property double bboxtop;
@property (retain) NSMutableDictionary * allNodes;

-(id) initWithLeft:(double) lef bottom: (double) bot right: (double) rig top: (double) to;
-(void) getData;

@end
