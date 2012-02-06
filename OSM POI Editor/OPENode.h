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
@property CLLocationCoordinate2D* coordinates;
@property (retain) NSMutableDictionary* tags;

-(id) initWithId: (int) i coordinates: (CLLocationCoordinate2D *) coordinate keyValues: (NSMutableDictionary *) tag;
-(void)addKey: (NSString*) key Value: (NSString*) val;
-(BOOL)onlyTagCreatedBy;

@end
