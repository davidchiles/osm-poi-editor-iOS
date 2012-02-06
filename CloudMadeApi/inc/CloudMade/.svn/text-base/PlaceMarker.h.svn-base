//
//  PlaceMarker.h
//  CloudMadeApi
//
//  Created by Dmytro Golub on 1/26/10.
//  Copyright 2010 CloudMade. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Location.h"
#import "HelperConstant.h"

enum RoutingPoint
{
	UNDEFINED_POINT,
	DEPARTURE_POINT,
	ARRIVAL_POINT
};

//! Class for presentation location's marker
@interface PlaceMarker : UIImageView 
{
    CGPoint lastTouchLocation;          /**< point where last touch took place*/   
    CGFloat lastTouchSpacing;           /**< */    
    int     touchMovedEventCounter;	    /**< touch counter*/
    id<PlaceMarkerDelegate>  delegate;
    Location* location;	
    NSNumber* nID; 
	BOOL bDragable;
	float fLongitude;
	float fLatitude;
	enum RoutingPoint routingPoint;	
}
@property (nonatomic,readwrite) BOOL bDragable;
@property (nonatomic,readwrite) float fLongitude;
@property (nonatomic,readwrite) float fLatitude;
@property (nonatomic,readwrite) enum RoutingPoint routingPoint;	
//! PlaceMarkerDelegate delegate
@property (nonatomic, retain) id<PlaceMarkerDelegate>  delegate;
//! marker details \sa Location
@property (nonatomic, retain)    Location* location;	
//! Marker index in markers' array \sa CloudMadeView
@property (nonatomic,retain) NSNumber* nID;
/**
  * Sets image for marker
  *  @param image image
*/
-(void) setMarkerImage:(UIImage*) image;
-(void) setPanningModeWithLocation:(CGPoint)location;
/**
 * Puts marker in given place
 * @param x X-coordinate
 * @param y Y-coordinate
*/
-(void) setMarker:(float)x :(float) y; 
-(BOOL) isPanning;
-(void) reset;
@end
