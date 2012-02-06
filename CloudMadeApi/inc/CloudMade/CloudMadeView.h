/*
 * Copyright 2009 CloudMade.
 *
 * Licensed under the GNU Lesser General Public License, Version 3.0;
 * You may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.gnu.org/licenses/lgpl-3.0.txt
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import <UIKit/UIKit.h>
#import "CloudMadeMapView.h"
#import "Location.h"
#import "HelperConstant.h"


/*! \mainpage iPhone Maps API
 * The iPhone Maps API makes it easy for developers to build rich, interactive mapping applications on the iPhone. With this API you can:
 * \li Build applications that give users a rich mapping experience on the iPhone
 * \li Benefit from our scalable tile servers which deliver mobile optimized maps to your users
 * \li Easily integrate with the iPhone's location API to show your user's position in real time
 *
 * Using this API you can integrate maps from our tile servers into your applications. Just like our other APIs, we don't want to restrict the uses of this API - you are free to create applications that use our maps in any way like, as long as they comply with the terms of the iPhone SDK agreement.
*/

/**
 Creates  MapSettings structure with given parameters.
 @param baseUrl locations ot the iPhone page
 @param apikey key to access map. Has to  be obtained from http://cloudmade.com/developers
 @param stileid map's stileID
 @param tilesize tile's size
 @param zoom map's zoom
 @param busegps use GPS or not
 @param latitude latitude where map will be centered
 @param longitude longitude where map will be centered
 @param rootDomain URL for tile server
 @param subdomain  names of the subdomains 
 @return filled MapSettings structure
*/
struct MapSettings CreateMapSettings(const char* baseUrl,const char* apikey,int stileid,int tilesize,int zoom,BOOL busegps,float latitude,float longitude,const char* rootDomain,const char* subdomain,int,int);


//! Protocol for implementation user actions
@protocol UserActions
  /**
   function is called when user touches event occured
   
   */
- (void) touchesBeginEvent:(NSSet*)touches withEvent:(UIEvent*)event;
/**
  function is called when user moved event occured
 */
- (void) tochesMovedEvent:(NSSet*)touches withEvent:(UIEvent*)event;
@optional - (void) moveMap:(float) x :(float) y;
@end

@protocol WhereAmI
- (void) FindMe;
@end

/// \deprecated subject to removal at any moment
//! Class is the top view class which has CloudMadeMapView as a child and handles all events from user
@interface CloudMadeView : UIView
{
@private	
    CloudMadeMapView* cloudMadeMapView; /**<  pointer to CloudMadeMapView object*/
	CGPoint lastTouchLocation;          /**< point where last touch took place*/   
    CGFloat lastTouchSpacing;           /**< */    
    int     touchMovedEventCounter;	    /**< touch counter*/
    id <UserActions> eventDelegate;	    /**< user action delegate */ 
	id <WhereAmI> whereAmI;             /**<  WhereAmI delegate \sa  WhereAmI */
	struct MapSettings mapSettings;     /**< map settings \sa MapSettings */
	UILabel* termOfUse;                 /**< term of use \sa http://www.cloudmade.com/faq */
	//NSMutableArray* arrayOfLocations;	/**< array of locations */
	NSMutableDictionary* arrayOfLocations;	/**< array of locations */	
	NSMutableArray* arrayOfDelegates;	/**< array of delegates */ 
	BOOL updateWithZoom;
}
@property (retain, getter = delegate) id <UserActions> eventDelegate;
@property (retain,getter = map) CloudMadeMapView* cloudMadeMapView;
@property (retain,readwrite, getter=whereAmIDelegate,setter=whereAmIDelegate:) id <WhereAmI> whereAmI;  
@property (retain, readonly) NSDictionary* arrayOfLocations;
/**
   Initializes map
   @param frame frame where map will be drawed
   @param mapsettings structure which has all initialization's parameters for map
   @return pointer to created CloudMadeView 
*/
-(id) InitWithMap:(CGRect)frame :(struct MapSettings)mapsettings;
/**
 Changes map's style
 @param styleID map's style
*/ 
-(void) changeMapStyle:(int) styleID :(int) tileSize;
/**
 Allows users to adjust term of use label. It could be useful in cese of add/remove navegation bar, etc
 @param center coordinate of the center
*/ 
-(void) adjustTermOfUse:(CGPoint) center; 
/**
 Allows to manage device's rotation 
 @param orientation current orientation of the device
*/
-(void) manageRotation:(UIInterfaceOrientation) orientation;
/**
 * Moves center of the map to given point 
 * @param x X-coordinate
 * @param y Y-coordinate
 */
-(void) setCenter:(float) x :(float) y :(int) zoom;
/**
 * Put locations on the map 
 * @param loc locations
 * @param del delegate \sa PlaceMarkerDelegate
 * @return marker \sa PlaceMarker
 */
-(id) markPlace:(Location*)loc :(id) del;
/**
 * Put locations on the map (for new locations)
 * @param lat latitude
 * @param lng longitude
 * @param del delegate \sa PlaceMarkerDelegate
 * @return marker \sa PlaceMarker
 */
-(id) markPlace:(float)lat :(float)lng :(id) del;
/**
 * Add delegate to be notified about map changing (zooming,map's tracking)   
 * @param id <UserActions> delegate \sa UserActions
 */
-(void) addDelegate:(id <UserActions>) delegate; 
/**
 * Returns map center
 * @return map's center
 */
-(CGPoint) getMapCenter;
/**
 * Transform screen coordinate to latitude and longitude
 * @param x X coordinate of the point
 * @param y Y coordinate of thr point
 * @return latitude and longitude
 * \sa transformLatLngToPoint
 */
-(CGPoint) transformPointToLatLng:(float) x :(float) y;
/**
 * Transform latitude and longitude to screen coordinate
 * @param lat Latitude
 * @param lng Longitude
 * @return screen coordinates
 * \sa transformPointToLatLng
 */
-(CGPoint) transformLatLngToPoint:(float) lat :(float) lng;
/**
 * Remove location from map
 * @param strID locations ID
 * @return TRUE if success
 */
-(BOOL) removeMarker:(NSString*) strID; 
/**
 * Remove location from map by index is used for locations which were not saved on server
 * @param nIdx locations index \sa arrayOfLocations
 * @return TRUE if success
 */
-(void) removeMarkerByIdx:(NSNumber*) nIdx;
/**
 * Sets server's ID for marker                        
 * @param nIdx marker index  \sa arrayOfLocations
 * @param locID 
 */
-(void) setMarkerID:(NSNumber*) nIdx :(int) locID;
/**
 * Update marker by index
 * @param nID marker index  \sa arrayOfLocations
 * @param loc location properties
 */
-(void) updateMarkerByIdx:(NSNumber*) nID :(Location*) loc ;
/**
 * Update marker
 * @param location properties
 */
-(BOOL) updateMarker:(Location*) location;
/**
 * Searches relevant zoom for given latitude and longitude
 * @param  latDiff latitude's length 
 * @param  lngDiff longitude's length  
 * @return zoom which should fit given conditions
 */
-(int) findRelevantZoom:(float) latDiff :(float) lngDiff;
/**
 * Sets map zoom
 * @param zoom map's zoom
 */
-(void) setMapZoom:(int) zoom;
/**
 * Returns bound box of current screen
 * @return bound box in CGRect class 
 */
-(CGRect) getBoundBox:(CGSize) size; 
/**
 * Returns current map's zoom
*/
-(int) getZoom;
/**
 * Removes all locations from array and deletes it from superview
*/
-(void) clearLocationsArray;
/**
 * Places array of locations on the map
 * @param locations array of PlaceMarker's \sa PlaceMarker
 * @param delegate \sa PlaceMarkerDelegate
 * @remarks function will find relevant zoom  if  locations don't fit current zoom
*/
-(void) placeMarkersOnMap:(NSArray*) locations withDelegate:(id<PlaceMarkerDelegate>) delegate;
-(void) deleteDelegate:(id) removingDelegate; 
/**
 * Renders route on the screen
 * @param route array of the route coordinates
 */
-(void) putRouteToTheMap:(NSArray*) route;
/**
 * Deletes route from the screen
 */
-(void) clearRoute;
-(id) findMarkerByIdx:(NSNumber*) nIdx;
/**
 * Returns appropriate zoom level for given bounding box
 * @param bounds bounding box
 */
-(int) getBoundsZoomLevel:(BBox*) bounds;
@end
