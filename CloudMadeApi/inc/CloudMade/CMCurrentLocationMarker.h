//
//  CMCurrentLocationMarker.h
//  Routing
//
//  Created by user on 12/15/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import "RMPath.h"
#import "RMMapLayer.h"

@class RMMapContents;



typedef struct _CurrentLocationProperties *CurrentLocationPropertiesPrt;

//! Shows a user location on the map 
@interface CMCurrentLocationMarker : RMMapLayer <RMMovingMapLayer>
{
	RMMapContents* _contents;
	float _initialRatio;
	float renderedScale;
	CurrentLocationPropertiesPrt currentLocationProperties;
	float radius;
	float _accurancy;
	NSTimer* updateTimer;
	UIImage* centerImage;
    BOOL enableDragging;
	BOOL enableRotation;
    RMProjectedPoint projectedLocation;	
}

@property (assign, nonatomic) RMProjectedPoint projectedLocation;
@property (assign) BOOL enableDragging;
@property (assign) BOOL enableRotation;

/**
 *  Returns an initialized CMCurrentLocationMarker object  
 *  @param aContents map contents object
 *  @param accurancy the current accurancy of the user's position
 */
- (id) initWithContents: (RMMapContents*)aContents accurancy:(float) accurancy;
/**
 *  Updates the user's position with given coordinates and accurancy
 *  @param coordinate a user's coordinates
 *  @param accurancy  GPS accurancy for the user's location  
 */ 
- (void) updatePosition:(CLLocationCoordinate2D) coordinate withAccurnacy:(float) accurancy; 
/**
 *  Removes the user's location marker from the map 
 */ 
- (void) removeFromMap;

@end
