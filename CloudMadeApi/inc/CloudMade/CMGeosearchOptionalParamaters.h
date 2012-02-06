//
//  CMGeosearchOptionalParamaters.h
//  CloudMadeApi
//
//  Created by Dmytro Golub on 6/23/09.
//  Copyright 2009 Cloudmade. All rights reserved.
//

#import <Foundation/Foundation.h>


#import "bbox.h"
#import "ServiceRequest.h"

//#define __GEO_CACHING__
//! Optional parameters for geosearch http://developers.cloudmade.com/wiki/geocoding-http-api/Documentation 
@interface CMGeosearchOptionalParamaters:NSObject
{
	NSNumber* numberOfResults;  /**< Number of results to return, default 10 */
	NSNumber* skipResults;      /**< Number of results to skip from beginning, default 0 */
	NSNumber* bboxOnly;         /**< Used only if bbox is specified. Set it to false if you want to return results from the whole planet if they are not found in passed bbox. Default true. */
	NSNumber* returntGeometry;  /**< Set it to false if you do not want to have geometry in returned results. Default true. */
	NSNumber* returnLocation;   /**< Set it to true if you do want location information like road, city, county, country, postcode in returned results. Default false. */
}

///---------------------------------------------------------------------------------------
/// @name Properties
///---------------------------------------------------------------------------------------v

@property (nonatomic,retain) NSNumber* numberOfResults;
@property (nonatomic,retain) NSNumber* skipResults;
@property (nonatomic,retain) NSNumber* bboxOnly;
@property (nonatomic,retain) NSNumber* returntGeometry;
@property (nonatomic,retain) NSNumber* returnLocation;

///---------------------------------------------------------------------------------------
/// @name Creating and Initializing
///---------------------------------------------------------------------------------------

/**
 Creates parameters with given options
 @param number  Number of results to return
 @param skipnumber Number of results to skip from beginning
 @param bbox Used only if bbox is specified. Set it to false if you want to return results from the whole planet
 @param geometry Set it to false if you do not want to have geometry in returned results
 @param locationInfo Set it to true if you do want location information like road, city, county, country etc
 */ 
+(id) createWithNumberOfResults:(int) number skipResults:(int) skipnumber withBBox:(BOOL) bbox returnGeometry:(BOOL) geometry returnLocationInfo:(BOOL) locationInfo;
/**
 Inits parameters with given options
 @param number  Number of results to return
 @param skipnumber Number of results to skip from beginning
 @param bbox Used only if bbox is specified. Set it to false if you want to return results from the whole planet
 @param geometry Set it to false if you do not want to have geometry in returned results
 @param locationInfo Set it to true if you do want location information like road, city, county, country etc
 */ 
-(id) initWithNumberOfResults:(int) number skipResults:(int) skipnumber withBBox:(BOOL) bbox returnGeometry:(BOOL) geometry returnLocationInfo:(BOOL) locationInfo;

@end