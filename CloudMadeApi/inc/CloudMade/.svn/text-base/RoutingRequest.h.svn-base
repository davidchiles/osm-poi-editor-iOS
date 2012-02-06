//
//  RoutingRequest.h
//  NavigationView
//
//  Created by Dmytro Golub on 2/9/09.
//  Copyright 2009 Cloudmade. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "ServiceRequest.h"
#import "GeoCoordinates.h"
//! Requests route from routing server  
@interface RoutingRequest : ServiceRequest
{
	NSString* apikey; /**< APIKEY  */
}
/**
 *  inits route request 
 *  @param apiKey APIKEY
 */
-(id) initWithApikey:(NSString*) apiKey;
/**
 *  search for route between given points
 *  @param from start point
 *  @param toPoint end point 
 *  @param object type of the route ("car", "foot", "bicycle")
 */
-(void) findRoute:(CLLocationCoordinate2D) from to:(CLLocationCoordinate2D) toPoint vehicle:(NSString*) object ;
@end
