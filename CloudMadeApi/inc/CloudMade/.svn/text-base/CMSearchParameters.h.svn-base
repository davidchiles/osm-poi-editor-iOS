//
//  CMSearchParameters.h
//  LBA
//
//  Created by user on 12/21/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CMSearchParameters;

NSString* NSStringFromCMSearchParameters(CMSearchParameters* parameters);

/**
* Search parameters calss is used by CMGeocoder to specify search area   
* \sa findWithGeosearchParamaters findObjectsWithName
*/
@interface CMSearchParameters : NSObject
{
	NSString* city;
	NSString* country;
	NSString* county;
	NSString* postcode;
	NSString* street;
	NSString* house;
}
/**
*  City name. Can be nil 
*/
@property (nonatomic, retain) NSString *city;
/**
*  Country name. Can be nil 
*/
@property (nonatomic, retain) NSString *country;
/**
*  Country name. Can be nil 
*/
@property (nonatomic, retain) NSString *county;
/**
*  Postcode. Can be nil 
* \par Discussion:
* Zipcode for US
*/
@property (nonatomic, retain) NSString *postcode;
/**
*  Street name. Can be nil 
*/
@property (nonatomic, retain) NSString *street;
/**
*  House number. Can be nil 
*/
@property (nonatomic, retain) NSString *house;




@end