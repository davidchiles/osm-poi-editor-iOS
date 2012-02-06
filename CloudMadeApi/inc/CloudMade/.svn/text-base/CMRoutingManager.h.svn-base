//
//  CMRoutingManager.h
//  Routing
//
//  Created by Dmytro Golub on 12/7/09.
//  Copyright 2009 CloudMade. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <UIKit/UIKit.h>
#import "CMRouteDetails.h"

@class CMRoute;
@class CMRouteSummary;
@class RMMapView;
@class TokenManager;


/** \file CMRoutingManager.h 
 \brief A file with classes for routing  
 */

//! Enumeration which describes available vehicles for routing 
typedef enum _CMRoutingVehicle
{
	CMVehicleCar, /**< car route*/
	CMVehicleBike,/**< bicycle route*/
	CMVehicleWalking/**<  feet route*/
} CMRoutingVehicle;

//! Enumeration for start and end point of the route 
typedef enum _CMRoutePoint
{
	CMRouteStartPoint, /**< start point*/
	CMRouteFinishPoint,/**< end point*/
} CMRoutePoint;

enum 
{
	CMNavigationMeasureKilometers,
	CMNavigationMeasureMiles
};

typedef NSUInteger CMNavigationMeasureUnit;


//! Delegate for the CMRoutingManager \sa CMRoutingManager
@protocol CMRoutingManagerDelegate 
/**
 *  Called when route is found
 *  @param route built route \sa CMRoute
 *  @param routeSummary route summary \sa CMRouteSammury  
 */
-(void) routeDidFind:(CMRoute*) route summary:(CMRouteSummary*) routeSummary;  
@optional
/**
 *  Called when route is not found
 *  @param desc error description
 */
-(void) routeNotFound:(NSString*) desc;
/**
 *  Called when route is found
 *  @param details route details
 */
-(void) routeDidFind:(CMRouteDetails*) details;  
/**
 *  Called before route search starts
 */
-(void) routeSearchWillStarted;
@end

//! Class which builds route 
@interface CMRoutingManager : NSObject
{
	RMMapView* _mapView;
	id<CMRoutingManagerDelegate> delegate;
	CMRoute* _route;
	CMRouteSummary* _routeSammury;
//	NSArray* _routeInstructions;
	CLLocationCoordinate2D _startRoutePoint;
	CLLocationCoordinate2D _endRoutePoint;	
	UIImage* _startRoutePointImage;
	UIImage* _endRoutePointImage;
	TokenManager* _tokenManager;
	BOOL _simplifyRoute;
	float _distance;
	CMNavigationMeasureUnit _measureUnit;
	NSString* _language; 
	BOOL _isActive;
	NSArray* routeData;
}
//! delegate \sa  CMRoutingManagerDelegate
@property (nonatomic,retain) id<CMRoutingManagerDelegate> delegate;
//! if the property is set to YES a route will be simplified
@property (readwrite) BOOL simplifyRoute;
@property (readwrite) float distance;
//! measure units for distance calculation (km or miles). Default - CMNavigationMeasureKilometers \sa CMNavigationMeasureUnit
@property (readwrite) CMNavigationMeasureUnit measureUnit;
//! ISO 3166-1 2 character code for language of the route instructions, if missing taken from the Accept-Language header, default is "en". Possible values are: de, en, es, fr, hu, it, nl, ro, ru, se, vi, zh. It is also possible to add a new translation for a different language - find out more <a href="http://developers.cloudmade.com/wiki/routing-http-api/Routing_translation">here</a> 
@property (nonatomic,retain) NSString* language;

/**
 *  Initializes class
 *  @param mapView map where route will be drawn
 */
-(id) initWithMapView:(RMMapView*) mapView tokenManager:(TokenManager*) tokenManager;
/**
 *  searches for route 
 *  @param from start point of the route
 *  @param to end point of the route
 *  @param vehicle route type \sa CMRoutingVehicle
 */
-(void) findRouteFrom:(CLLocationCoordinate2D) from to:(CLLocationCoordinate2D) to onVehicle:(CMRoutingVehicle) vehicle; 
/**
 *  searches for route 
 *  @param from start point of the route
 *  @param to end point of the route
 *  @param transitPoints an array of transit points. Coordinate should be packed to NSValue object
 \code
	CLLocationCoordinate2D node0 = {51.44,-0.96};
	CLLocationCoordinate2D node1 = {51.41,-1.51};
	CLLocationCoordinate2D node2 = {51.55,-1.78};
 
	NSValue *nodeCoord0 = [NSValue value:&node0 withObjCType:@encode(CLLocationCoordinate2D)];
	NSValue *nodeCoord1 = [NSValue value:&node1 withObjCType:@encode(CLLocationCoordinate2D)];
	NSValue *nodeCoord2 = [NSValue value:&node2 withObjCType:@encode(CLLocationCoordinate2D)];
 
	NSArray* transitPoints = [NSArray arrayWithObjects:nodeCoord0,nodeCoord1,nodeCoord2,nil];
 \endcode
 *  @param vehicle route type \sa CMRoutingVehicle
 */
-(void) findRouteFrom:(CLLocationCoordinate2D) from to:(CLLocationCoordinate2D) to withTransitPoints:(NSArray*) transitPoints 
			onVehicle:(CMRoutingVehicle) vehicle; 


/**
 *  searches for route 
 *  @param vehicle rebuild build for the given vehicle \sa CMRoutingVehicle
 */
-(void) reloadRouteWithVehicle:(CMRoutingVehicle) vehicle;
/**
 *  remove route from the map 
 */
-(void) removeRouteFromMap;
/**
 *  returns route summary \sa  CMRouteSammury
 */
-(CMRouteSummary*) routeSummary;
///**
// *  returns route instructions \sa  RouteInstruction
// */
//-(NSArray*) routeInstructions;
///**
// * Returns route instructions. In case route simplifycation - without locations.
// */  
-(NSArray*) routeInstructions;
/**
 * Sets image for route points
 * @param image point image
 * @param point point specification \sa CMRoutePoint
 */ 
-(void) image:(UIImage*) image forPoint:(CMRoutePoint) point;  
@end
