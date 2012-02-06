//
//  RequestSynhronizer.h
//  CloudMadeApi
//
//  Created by Dmytro Golub on 6/23/09.
//  Copyright 2009 Cloudmade. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GeoCodingRequest.h"
#import "TokenManager.h"

#define SP_STREET_NAME		@"SP_STREET_NAME"
#define SP_CITY_NAME		@"SP_CITY_NAME"
#define SP_COUNTRY_NAME		@"SP_COUNTRY_NAME"
#define SP_UNDETERMINATE	@"SP_UNDETERMINATE"
//! Delegate for the GeocoderManager
@protocol GeoCoderDelegate
/**
 * inits class
 * @param results array of found objects \sa Location 
 * @param bounds bounding bos for the found objects 
 */
-(void) searchIsFinished:(NSArray*) results inBounds:(BBox*) bounds;
@end



//! Geocoder which works in separate thread and handle request to server to get results  GeoCoderDelegate has to be adopted  
@interface GeocoderManager  : NSObject //NSOperation <ServiceRequestResult>
{
	NSString* apiKey;
	NSCondition* operationCompleteCondition;
	BOOL operationComplete;
	int gCounter;
	BOOL operationExecuting;
	NSMutableDictionary* searchResults;
	id<GeoCoderDelegate> delegate;
	NSMutableDictionary* searchOptions;
	int countOfStartedSearches;
	NSMutableArray* boundsArray;
	NSRunLoop* threadRunLoop;
	TokenManager* tokenManager;
	NSUInteger _returnResults;  
}

//! delegate property \sa GeoCoderDelegate
@property (readwrite) NSUInteger returnResults;;

//! delegate property \sa GeoCoderDelegate
@property (retain,nonatomic) id<GeoCoderDelegate> delegate;
/**
 * inits class
 * @param apikey CloudMade's developer APIKEY
 * @param searchRequest search request \note Search assume that you will send request as follows 
 *   \li street,city,country \c synchronousFindObjects will be called.
 *   \li city,country \c synchronousFindCityWithName will be called.
 *   \li whatever \c synchronousFindObjects will be called.
 */
-(id) initWithApikey:(NSString*) apikey searchFor:(NSString*) searchRequest;
/**
 * Make async search. GeoCoderDelegate will be called when search is done   
 * @param searchRequest search request \note Search assume that you will send request as follows 
 *   \li street,city,country \c synchronousFindObjects will be called.
 *   \li city,country \c synchronousFindCityWithName will be called.
 *   \li whatever \c synchronousFindObjects will be called.
 */
-(void) addSearchTask:(NSString*) searchRequest;

@end
