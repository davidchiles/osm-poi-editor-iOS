//
//  OPENode.h
//  OSM POI Editor
//
//  Created by David Chiles on 2/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "OPEPoint.h"

@interface OPENode : NSObject <OPEPoint>

-(id) initWithId: (int) i coordinate: (CLLocationCoordinate2D) coordinate keyValues: (NSMutableDictionary *) tag;
-(id) initWithId:(int)i latitude:(double) la longitude:(double) lo;
-(id) initWithId:(int)i latitude:(double) la longitude:(double) lo version:(int) ve;
-(id) initWithNode: (OPENode *) node;
-(BOOL)onlyTagCreatedBy;
-(BOOL)hasNoTags;

+ (id) createPointWithXML:(TBXMLElement *)xml;


@end
