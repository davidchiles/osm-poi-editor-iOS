//
//  GeoCodingRequest.h
//  
//
//  Created by Dmytro Golub on 9/4/09.
//  Copyright 2009 CloudMade. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CMGeosearchOptionalParamaters.h"
#import "TokenManager.h"
#import <CoreLocation/CoreLocation.h>

@class GeoCoordinates;

@interface CMGeosearchURLBuilder :NSObject
{
	
}
+(NSString*) buildUrlForObject:(NSString*) object withApikey:(NSString*) apikey;
+(NSString*) buildUrlWithPostcode:(NSString*) postcode withApikey:(NSString*) apikey;
+(NSString*) buildUrlWithZipcode:(NSString*) zipcode withApikey:(NSString*) apikey;
+(NSString*) buildUrlWithCity:(NSString*) name withApikey:(NSString*) apikey;
+(NSString*) buildUrlForClosest:(NSString*) name withApikey:(NSString*) apikey inPoint:(GeoCoordinates*) coordinate;
+(NSString*) buildUrlForGeoobject:(NSString*) name withApikey:(NSString*) apikey;
+(NSString*) buildUrlForGeoobjectAroundPoint:(GeoCoordinates*) point withApikey:(NSString*) apikey inDistance:(int) distance;
+(NSString*) buildUrlForGeoobjectAroundStreet:(NSString*) street withApikey:(NSString*) apikey inDistance:(int) distance;
+(NSString*) buildUrlToFindStreet:(NSString*) street withApikey:(NSString*) apikey ;
+(NSString*) buildUrlToFindObject:(NSString*) objName  around:(CLLocationCoordinate2D)coordinate 
						 distance:(NSNumber*) distance  withApikey:(NSString*) apikey extraParams:(NSDictionary*) parameters;
@end


/** \example geocoding_example.h 
 * This is an example of how to use reverse geocoding.
 * More details about this example.
 */




//! Class makes request for geocoding search to get result ServiceRequestResult has to be adopted \sa ServiceRequest
@interface GeoCodingRequest : ServiceRequest
{
	NSString* apikey; 
	BOOL errorStatus;
	CMGeosearchOptionalParamaters* parameters;	
	TokenManager* _tokenManager;
#ifdef __GEO_CACHING__	
	NSString* requestedURL;
#endif	
}

@property (nonatomic,retain) 	CMGeosearchOptionalParamaters* parameters;

#ifdef __GEO_CACHING__	
@property (nonatomic,retain) 	NSString* requestedURL;
	
#endif


/**
 *  Initializes and returns a newly allocated view object with the specified frame rectangle.
 *  @param apiKey apikey
 *  @param searchOptions search options \sa CMGeosearchOptionalParamaters
 *  @param tokenManager token manager \sa TokenManager
 */
-(id) initWithApikey:(NSString*) apiKey withOptions:(CMGeosearchOptionalParamaters*) searchOptions tokenManager:(TokenManager*) tokenManager;
/**
 *  Searches for objects
 *  @param object searching object name
 *  @param bbox bounding box for searching in  
 *  @param results number of result
 */
-(void) findObjects:(NSString*) object :(BBox*) bbox ;
/**
 *  Searches for place by postcode
 *  @param postcode postcode
 *  @param countryName country where search should be done  
 */
-(void) findByPostcode:(NSString*) postcode inCountry:(NSString*) countryName;
/**
 *  Searches for place by zipcode
 *  @param zipcode zipcode
 *  @param countryName country in where search should be done  
 */
-(void) findByZipcode:(NSString*) zipcode inCountry:(NSString*) countryName;
/**
 *  Searches for city with given name
 *  @param name city name
 *  @param countryName country in where search should be done  
 */
-(void) findCityWithName:(NSString*) name inCountry:(NSString*) countryName;
/**
 *  Searches for closest object to given point object 
 *  @param name object type
 *  @param coordinate where search should be done
 */
-(void) findClosestObject:(NSString*) name inPoint:(GeoCoordinates*) coordinate;
/**
 *  Searches for geoobject in given bounding box 
 *  @param object object type
 *  @param bbox where search should be done
 */
-(void) findGeoObject:(NSString*) object inBBox:(BBox*) bbox;
/**
 *  Searches for geoobject around given city 
 *  @param city city name
 *  @param distance distance around city
 *  @param objectType object type
 *  @param objectName object name
 *  @param country country where search should be done   
 */
-(void) findGeoObjectAroundCity:(NSString*) city inDistance:(int) distance withType:(NSString*) objectType 
					   withName:(NSString*) objectName inCountry:(NSString*) country;
/**
 *  Searches for geoobject around given point 
 *  @param point coordinate where search should be done
 *  @param distance distance around point
 *  @param objectType object type
 *  @param objectName object name
  */
-(void) findGeoObjectAroundPoint:(GeoCoordinates*) point inDistance:(int) distance withType:(NSString*) objectType 
						withName:(NSString*) objectName;
/**
 *  Searches for geoobject around given street 
 *  @param streetName where search should be done
 *  @param distance distance around street
 *  @param objectType object type
 *  @param objectName object type 
 *  @param city city name 
 *  @param country country in where search should be done  
 */
-(void) findGeoObjectAroundStreet:(NSString*) streetName inDistance:(int) distance withType:(NSString*) objectType 
						 withName:(NSString*) objectName inCity:(NSString*) city inCountry:(NSString*) country;
/**
 *  Searches for street in given city 
 *  @param street where search should be done
 *  @param city city name 
 *  @param country country in where search should be done  
 */
-(void) findStreetWithName:(NSString*) street inCity:(NSString*) city inCountry:(NSString*) country;
/**
 *  Reverse geocoding http://developers.cloudmade.com/wiki/geocoding-http-api/Examples#Reverse-geocoding
 *  @param objName object you are looking for Details are here http://developers.cloudmade.com/wiki/geocoding-http-api/Object_Types
 *  @param coordinate coordinate
 *  @param distance distance. If distance is nil, closest object will be returned  
 */


-(void) findObject:(NSString*) objName around:(CLLocationCoordinate2D) coordinate withDistance:(NSNumber*) distance; 
/**  
 *  Structural search http://developers.cloudmade.com/wiki/geocoding-http-api/Examples#Using-structured-search 
 *  @param houseNumber number of the house 
 *  @param street where search should be done
 *  @param city city name
 *  @param postcode postcode. Can be nil 
 *  @param county county in where search should be done.Can be nil  
 *  @param country country in where search should be done.Can be nil   
 */
-(void) structuralSearchWithHouse:(NSString*) houseNumber  street:(NSString*) street city:(NSString*) city 
						 postcode:(NSString*) postcode county:(NSString*) county country:(NSString*) country;


-(NSString*) appendWithSearchOptions:(NSDictionary*) options;
-(NSMutableDictionary*) optionsDictionary;
@end

