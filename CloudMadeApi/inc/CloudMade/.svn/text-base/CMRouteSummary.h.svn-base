//
//  CRouteSummary.h
//  Routing
//
//  Created by Dmytro Golub on 12/11/09.
//  Copyright 2009 CloudMade. All rights reserved.
//

#import <Foundation/Foundation.h>

//! Class describes built route 
@interface CMRouteSummary : NSObject
{
	NSString* _startPoint;
	NSString* _endPoint;
	NSUInteger _totalDistance;
	NSUInteger _totalTime;
}
//! name of the start point  the route (e.g street name)
@property(nonatomic,retain) NSString* startPoint;
//! name of the end point of the route (e.g street name)
@property(nonatomic,retain) NSString* endPoint;
//! route length 
@property(readwrite) NSUInteger totalDistance;
//! route time 
@property(readwrite) NSUInteger totalTime;

/**
 *  Initializes class
 *  @param properties row route summaries 
 */ 
-(id) initWithDictionary:(NSDictionary*) properties;



@end
