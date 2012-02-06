//
//  CMRoute.h
//  Routing
//
//  Created by Dmytro Golub on 12/9/09.
//  Copyright 2009 CloudMade. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@class RMPath;
@class RMMapView;
//! class describes route
@interface CMRoute : NSObject
{
	NSMutableArray* _route;
	RMPath* _path;
	CLLocationCoordinate2D* _plainRoute;
}
//! route points
@property (nonatomic,assign) NSMutableArray* route; 
//! route nodes
@property (nonatomic,retain) RMPath* path; 
/**
 *  Initializes class
 *  @param nodes route nodes 
 *  @param mapView map view
 */ 
-(id) initWithNodes:(NSArray*) nodes forMap:(RMMapView*) mapView;
/**
 *  Returns array of route points
 */
-(NSArray*) routePoints;
@end
