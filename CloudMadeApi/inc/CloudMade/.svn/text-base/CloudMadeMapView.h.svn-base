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
#import <CoreLocation/CoreLocation.h>
#import "bbox.h"

extern CGPoint gfRealMapCenter;

 //! Struct keeps map and user settings
struct MapSettings
{
	const char* baseUrl;
	const char* apiKey; /**< key to access map. Has to  be obtained from http://cloudmade.com/developers */
	int styleID;        /**< map's stileID*/
	int tileSize;       /**< tile's size*/
	int Zoom;           /**< map's zoom*/
	BOOL bUseGPS;       /**< use GPS or not */
	float Latitude;     /**< latitude where map will be centered*/
	float Longitude;    /**< longitude where map will be centered*/
	const char* rootDomain; /**< URL for tile server */
	const char* subDomain;  /**< subdomains names */
	int width;
	int height;
};

//! View which delivers map to end user.Inherited from UIWebView.Implements UIWebViewDelegate protocol for handling errors and informational messages
@interface CloudMadeMapView : UIWebView <UIWebViewDelegate,CLLocationManagerDelegate> {
	CLLocationManager* locationManager;
	struct MapSettings mapSettings;
	CGPoint* arrayOfDistances;		
}
- (void) setCenterWithPixel:(float)dx :(float)dy; 
/**
   * Initializes map by MapSettings structure
   * @param mapsettings Initialized map with given parameters \sa  MapSettings
 */
- (void) initializeMap:(struct MapSettings)mapsettings;
/**
  * Zooms out map
*/ 
- (void) zoomOut;
/**
  * Zooms in map
 */ 
- (void) zoomIn;
/**
 * Moves center of the map to given point 
 * @param lat Latitude
 * @param lon Longitude
*/
- (void) setCenter:(float)lat:(float)lon :(int) zoom; 
/**
 * Changes map style
 * @param styleID style's ID 
 * @param rootUrl URL for tiles
 * @param subDomains sub-domains for tiles server
 * @param tileSize tile's size
 * @param apiKey key for accessing map. Has to  be obtained on http://cloudmade.com/developers
 */
- (void) changeMapStyle:(int)styleID :(const char*)rootUrl :(const char*)subDomains :(int)tileSize :(const char*)apiKey;
/**
 * Returns bound box of current screen
 * @return bound box in CGRect class 
 */
-(CGRect) getBoundBox:(CGSize) size; 
/**
 * Transform latitude and longitude to screen coordinate
 * @param lat Latitude
 * @param lng Longitude
 * @return screen coordinates
 * \sa transformPointToLatLng
 */
-(CGPoint) transformLatLngToPoint:(float) lat :(float) lng;
/**
 * Transform screen coordinate to latitude and longitude
 * @param x X coordinate of the point
 * @param y Y coordinate of thr point
 * @return latitude and longitude
 * \sa transformLatLngToPoint
 */
-(CGPoint) transformPointToLatLng:(float) x :(float) y;
/**
 *  Returns center of the map 
 *  @return latitude and longitude 
 */
-(CGPoint) getMapCenter;  
/**
 * return map's resolution (is used for zoom calculation)
 */
-(float) getResolution:(int) zoom;
/**
 * Mercator's transformation (latitude and longitude)
 * @param lat_ latitude
 * @param lng_ longitude
 * @return tranformad point
 * \sa fromMercator
 */
-(CGPoint) toMercator:(float) lat_ :(float) lng_;
/**
 * Mercator's transformation (latitude and longitude)
 * @param lat_ latitude
 * @param lng_ longitude
 * @return tranformad point
 * \sa toMercator
 */
-(CGPoint) fromMercator:(float) lat_ :(float) lng_;
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
 * Handle device rotation's 
 * @param orientation current device's orientation
 */
-(void) manageRotation:(UIInterfaceOrientation) orientation;
/**
 * Returns current map's zoom 
 */
-(int)getZoom;
/**
 * Renders route on the screen
 * @param route array of the route coordinates
 */
-(void) putRouteToTheMap:(NSArray*) route;
/**
 * Deletes route from the screen
 */
-(void) clearRoute;
/**
 * Returns appropriate zoom level for given bounding box
 * @param bounds bounding box
 */
-(int) getBoundsZoomLevel:(BBox*) bounds;
@end
