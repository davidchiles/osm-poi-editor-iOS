//
//  CMGeosearchParams.h
//  CloudMadeApi
//
//  Created by user on 12/20/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>


typedef struct {
	CLLocationCoordinate2D northeast;
	CLLocationCoordinate2D southwest;
} BoundingBox;

const BoundingBox BoundingBoxZero;

CLLocationCoordinate2D CLLocationCoordinate2DMake(CLLocationDegrees lat,CLLocationDegrees lng);
BoundingBox CMBoundingBoxMake(CLLocationCoordinate2D northeast,CLLocationCoordinate2D southwest);

//! Request parameters for geocoding server request http://developers.cloudmade.com/wiki/geocoding-http-api/Documentation 
@interface CMGeosearchRequestParams : NSObject {
	BoundingBox bbox;
	BOOL bboxOnly;	
	BOOL returnLocation;
	BOOL returnGeometry;
	NSUInteger distance;
	NSUInteger skip;
	NSUInteger returnResults;
	NSDictionary* _dict;
}
/** 
* Bounding box of the search area. 
* \par Discussion:
* Search will be initialy done in the bounding box area and after that in the rest of the world if bboxOnly property is not set in YES  
* \sa bboxOnly
*/
@property (nonatomic, assign) BoundingBox bbox;
/** 
* If set to NO, the geocoder will return results from the whole planet, but still ranking results from within the specified 
* bbox higher, otherwise only results from within the specified bbox will be returned.
* \par Discussion:
* Used only if bbox is specified. Default value is YES.
* \sa  bbox
*/
@property (nonatomic, assign) BOOL bboxOnly;
/** 
* Set it to YES if you do want location information like road, city, county, country, postcode in returned results.
* \par Discussion:
* It might take a little longer to get results if this option's set to YES. Default value is NO. 
*/
@property (nonatomic, assign) BOOL returnLocation;
/** 
* Set it to YES if you want geometry included in search results.
* \par Discussion:
* Default value is NO.
* \sa CMLocation 
*/
@property (nonatomic, assign) BOOL returnGeometry;
/**
* Radius of the search area. Distance is specified in meters from the center point. Special 
* value *closest* limits search results to one, closest to the center point of the search area.
* \par Discussion:
* Default value is 100 meters.
*/
@property (nonatomic, assign) NSUInteger distance;
/**
* Number of results to skip from beginning.
* \par Discussion:
* Default value is 0.
*/
@property (nonatomic, assign) NSUInteger skip;
/**
* Number of results to return. If results <100 then response.found is how many objects found but not more then 100. 
* If results >100 then response.found is how many objects returned.
* \par Discussion:
* Default value is 10.
*/
@property (nonatomic, assign) NSUInteger returnResults;



NSString* NSStringFromGeosearchRequestParams(CMGeosearchRequestParams* parameters);

@end