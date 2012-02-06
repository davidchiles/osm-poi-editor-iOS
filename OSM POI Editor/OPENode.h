//
//  OPENode.h
//  OSM POI Editor
//
//  Created by David Chiles on 2/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface OPENode : NSObject

@property int ident;
@property (retain) CLLocation* coordinates;
@property (retain) NSMutableDictionary* tags;

-(id) initWithId: (int) i coordinates: (CLLocation *) coordinate keyValues: (NSMutableDictionary *) tag;
-(id) initWithId:(int)i latitude:(double) la longitude:(double) lo;
-(void)addKey: (NSString*) key Value: (NSString*) val;
-(BOOL)onlyTagCreatedBy;

@end
