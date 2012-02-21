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
@property (nonatomic) CLLocationCoordinate2D coordinate;
@property (strong) NSMutableDictionary* tags;
@property int version; 

-(id) initWithId: (int) i coordinate: (CLLocationCoordinate2D) coordinate keyValues: (NSMutableDictionary *) tag;
-(id) initWithId:(int)i latitude:(double) la longitude:(double) lo;
-(id) initWithId:(int)i latitude:(double) la longitude:(double) lo version:(int) ve;
-(id) initWithNode: (OPENode *) node;
-(void)addKey: (NSString*) key Value: (NSString*) val;
-(BOOL)onlyTagCreatedBy;
-(NSString *)getName;

@end
