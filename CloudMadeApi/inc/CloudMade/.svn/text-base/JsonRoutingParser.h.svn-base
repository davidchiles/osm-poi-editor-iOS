//
//  JsonRoutingParser.h
//  NavigationView
//
//  Created by Dmytro Golub on 2/10/09.
//  Copyright 2009 Cloudmade. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RouteSummary.h"
#import "RouteInstruction.h"


struct bounds
{
	float minLat,maxLat,minLng,maxLng;
};
//! Routing server response parser \sa http://developers.cloudmade.com/wiki/routing-http-api/Response_structure  
@interface JsonRoutingParser : NSObject
{
@private	
	struct bounds _routeBounds;
}
/**
 *  returns route
 *  @param json server response
 */
-(NSArray*) route:(NSString*) json;
/**
 *  returns route summary
 *  @param json server response
 */
-(RouteSummary*) routeSummury:(NSString*) json;
/**
 *  returns route instruction
 *  @param json server response
 */
-(NSArray*) routeInstructions:(NSString*) json;
/**
 *  returns routing server response status
 *  @param json server response
 */
-(BOOL) responceStatus:(NSString*) json;
/**
 *  returns error message if any
 *  @param json server response
 */
-(NSString*) errMsg:(NSString*) json;
/**
 *  returns route bounds
 */
-(struct bounds) routeBounds;
@end
