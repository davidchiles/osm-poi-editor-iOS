//
//  CMGeosearchManager.h
//  
//
//  Created by user on 12/21/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CMSearchParameters.h"
#import "CMGeosearchRequestParams.h"

@class CMGeocoder;
@class TokenManager;

/**
* The CMGeocoderDelegate protocol defines the interface for receiving messages from an CMGeocoder object. You use this protocol to receive the array of CMLocation objects for
* the given user request or to retrieve any errors that occurred during the geocoding process. \sa CMLocation
* \since 0.2.7 
*/
@protocol CMGeocoderDelegate <NSObject>
/**
 * Tells the delegate that a geocoder successfully obtained an information for a user request. 
 *  @param geocoder  The geocoder object that completed request successfully.
 *  @param locations An array of the CMLocation objects.	
 */
-(void) geocoder:(CMGeocoder*) geocoder didFindLocations:(NSArray*) locations;
@optional
/**
 * Tells the delegate that the specified geocoder failed to obtain information. 
 *  @param geocoder The geocoder object that was unable to complete its request.
 *  @param error An error object indicating the reason the request did not succeed.	
 */
-(void) geocoder:(CMGeocoder*) geocoder didFailWithError:(NSError*) error;
@end


/**
* The CMGeocoder class provides services for geocode, reverse geocode and search through an extensive geographic database of countries, cities, roads, points of interest and 
* more. A geocoder object works with network-based services which allow you:
* \li Quickly and easily integrate geocoding, reverse-geocoding and geosearch into your existing web, mobile and desktop applications
* \li Build immersive applications for web and mobile that expose your users to a rich world of geodata
* \li Choose to return the full geometry of all objects - points, lines and polygons ranging from buildings to bridges, hotels to highways and parks to pizza parlors

* An iOS-based device must have access to the network in order for the geocoder object to return valid information. The geocoder returns information through its associated delegate object,
* which is an object that conforms to the CMGeocoderDelegate protocol. If the reverse geocoder is unable to retrieve the requested information, it similarly reports the error to 
* its delegate object. \sa CMGeocoderDelegate 
* \since 0.2.7 
*/
@interface CMGeocoder : NSObject  
{
	id<CMGeocoderDelegate> delegate;
	TokenManager* tokenManager;
	CMGeosearchRequestParams* requestParameters;
	NSMutableData* receivedData;	
	BOOL errorStatus;
	BoundingBox foundLocationsBBox;
}

///---------------------------------------------------------------------------------------
/// @name Properties
///---------------------------------------------------------------------------------------

@property (readwrite) BoundingBox foundLocationsBBox;
/** 
* The geocoder’s request options
* @discussion A geocoder object sends requests to the server. Use this property to adjust the request. 
* \sa CMGeosearchRequestParams
*/
@property (nonatomic, retain) CMGeosearchRequestParams *requestParameters;
/** 
* The geocoder’s delegate object.
* @discussion A geocoder object sends messages to its delegate regarding the successful 
* (or unsuccessful) acquisition of the data. You must provide a delegate object to receive this data.
* \sa CMGeocoderDelegate
*/
@property (nonatomic, retain) id<CMGeocoderDelegate> delegate;

///---------------------------------------------------------------------------------------
/// @name Creating and Initializing
///---------------------------------------------------------------------------------------


/**
* Initializes the geocoder with the specified apikey.
* @param apikey  Developer's apikey.
* @return A geocoder object.  
*/ 
-(id) initWithApikey:(NSString*) apikey;
/**
 * Returns a geocoder created and initialized with the given apikey.
 * @param apikey  Developer's apikey.
 * @return A geocoder object.
*/
+(id) geocoderWithApikey:(NSString*) apikey;


///---------------------------------------------------------------------------------------
/// @name Finding Locations and POIs
///---------------------------------------------------------------------------------------


/**
* Search for objects with the given parameters.
* @param parameters  search parameter options
* @discussion This method looks for a place with the given address (e.g house number,street,city,county,country). Please notice that some of those parameters might be nil.   
* \sa CMSearchParameters
*/
-(void) findWithGeosearchParamaters:(CMSearchParameters*) parameters;
/**
* Search for objects around the given location.
* @param objects  Object type. More details can be found here http://developers.cloudmade.com/wiki/geocoding-http-api/Object_Types  
* @param parameters Search around the following location
* @discussion This method looks for a place around the given address (e.g house number,street,city,county,country). Please notice that some of those parameters might be nil.   
* \sa CMSearchParameters
*/
-(void) find:(NSString*) objects around:(CMSearchParameters*) parameters;
/**
 * Search for objects around the given coordinate.
* @param objects  Object type. More details can be found here http://developers.cloudmade.com/wiki/geocoding-http-api/Object_Types  
* @param coordinate Search around the following coordinate
* @discussion This method looks for a place around the given coordinate.   
*/
-(void) findObjects:(NSString*) object aroundCoordinate:(CLLocationCoordinate2D) coordinate;
/**
* Geocodes address or a keyword whose name contains the keyword.
* @param query Specifies an address to geocode, or a keyword used to search for objects whose name contains the keyword (e.g \c Baker st,London,UK)  
* @discussion If the query represents an address, it can either be in free form format (for example, query=Oxford+st,+London,+UK), or specified as a set of address parts 
* separated by semicolon. The following address parts are recognized: poi, house, street, city, zipcode or postcode, county, country. 
* For example, query=street:Oxford street;city:London;country:UK.
* For queries representing a keyword, search is case-insensitive, matching whole words. Wildcards are not currently supported.   
*/
-(void) findWithQuery:(NSString *) query;
/**
* Search for objects with given type and name around the given location.
* @param name Specifies an object name
* @param objectType Specifies an object type
* @param parameters Specifies search location 
* \sa CMSearchParameters
*/
-(void) findObjectsWithName:(NSString*) name type:(NSString*) objectType around:(CMSearchParameters*) parameters;  
/**
* Search for objects with given type and name around the given coordinate.
* @param name Specifies an object name
* @param objectType Specifies an object type
* @param parameters Specifies search location 
*/
-(void) findObjectsWithName:(NSString*) name type:(NSString*) objectType aroundPoint:(CLLocationCoordinate2D) coordinate;


@end