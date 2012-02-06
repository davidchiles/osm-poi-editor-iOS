//
//  Location.h
//  CloudMadeApi
//
//  Created by Dmytro Golub on 1/26/09.
//  Copyright 2009 CloudMade. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

//! Class which describes user locations 
@interface Location : NSObject
{
/// \deprecated subject to removal at any moment street should be used instead \sa coordinate	
	NSString* strName;  /**< location's name*/
	NSString* street;  /**< street's name*/	
	NSString* strDesc;  /**< location's description*/
	NSString* strTag;   /**< location's tags*/
	NSString* strID;    /**< location's ID (usually hidden from user) is used for delete and update location*/
	float fLatitude;    /**< location's latitude*/
	float fLongitude;   /**< location's longitude*/
	NSString* strURL;	/**< location's icon's file name*/
	NSString* strPhotoName;	 /**< location's photos name*/
	BOOL bStaticPlace;
	CLLocationCoordinate2D coordinate;
	NSString* houseNumber;
	NSString* road;
	NSString* postcode;
	NSString* city;
	NSString* county;
}

@property (nonatomic,readwrite)	BOOL bStaticPlace;
/// \deprecated subject to removal at any moment streetName should be used instead \sa coordinate	
@property (nonatomic,retain) NSString* strName;
@property (nonatomic,retain)NSString* street;
@property (nonatomic,retain)NSString* county;
@property (nonatomic,retain) NSString* strDesc;
@property (nonatomic,retain) NSString* strTag;
@property (nonatomic,retain) NSString* strID;
//! House number if it is present 
@property (nonatomic,retain) NSString* houseNumber;
/// \deprecated subject to removal at any moment coordinate property should be used instead \sa coordinate
//! location's latitude
@property (nonatomic,readwrite) float fLatitude;
/// \deprecated subject to removal at any moment coordinate property should be used instead \sa coordinate
//! location's longitude 
@property (nonatomic,readwrite) float fLongitude;
//! location's coordinate
@property (nonatomic,readwrite) CLLocationCoordinate2D coordinate;
@property (nonatomic,retain) NSString* strURL;
@property (nonatomic,retain) NSString* strPhotoName;
//! location's the closest road name 
@property (nonatomic,retain) NSString* road;
//! location's postcode 
@property (nonatomic,retain) NSString* postcode;
//! location's city 
@property (nonatomic,retain) NSString* city;


/**
 Reset locations properties to default 
 */ 
-(void) reset;
// \deprecated subject to removal at any moment. locationWithFeatures method should be used instead \sa locationWithFeatures
+(Location*) initWithFeatures:(NSDictionary*) features;
+(Location*) locationWithFeatures:(NSDictionary*) features;
@end
