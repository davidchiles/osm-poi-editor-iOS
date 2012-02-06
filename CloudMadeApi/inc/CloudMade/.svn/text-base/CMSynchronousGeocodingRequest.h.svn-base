//
//  CMSynchronousGeocodingRequest.h
//  CloudMadeApi
//
//  Created by Dmytro Golub on 8/4/09.
//  Copyright 2009 CloudMade. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GeoCodingRequest.h"

@interface CMSynchronousGeocodingRequest : GeoCodingRequest
{
}

-(NSString*) synchronousFindObjects:(NSString*) object :(BBox*) bbox; 
-(NSString*) synchronousFindByPostcode:(NSString*) postcode inCountry:(NSString*) countryName;
-(NSString*) synchronousFindByZipcode:(NSString*) zipcode inCountry:(NSString*) countryName;
-(NSString*) synchronousFindCityWithName:(NSString*) name inCountry:(NSString*) countryName;
-(NSString*) synchronousFindClosestObject:(NSString*) name inPoint:(GeoCoordinates*) coordinate;
-(NSString*) synchronousFindGeoObject:(NSString*) object inBBox:(BBox*) bbox;
-(NSString*) synchronousFindGeoObjectAroundCity:(NSString*) city inDistance:(int) distance withType:(NSString*) objectType 
									   withName:(NSString*) objectName inCountry:(NSString*) country;

-(NSString*) synchronousFindGeoObjectAroundPoint:(GeoCoordinates*) point inDistance:(int) distance withType:(NSString*) objectType 
										withName:(NSString*) objectName;

-(NSString*) synchronousFindGeoObjectAroundStreet:(NSString*) streetName inDistance:(int) distance withType:(NSString*) objectType 
										 withName:(NSString*) objectName inCity:(NSString*) city inCountry:(NSString*) country;

-(NSString*) synchronousFindStreetWithName:(NSString*) street inCity:(NSString*) city inCountry:(NSString*) country;

@end
