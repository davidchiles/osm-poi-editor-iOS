//
//  bbox.h
//  
//
//  Created by Dmytro Golub on 9/4/09.
//  Copyright 2009 CloudMade. All rights reserved.
//

#import <Foundation/Foundation.h>

//! Bounding box for geographical area
@interface BBox : NSObject
{
	float westernLongitude,southernLatitude,easternLongitude,northernLatitude;
}
//! western longitude
@property (nonatomic,readwrite) float westernLongitude;
//! southern latitude
@property (nonatomic,readwrite) float southernLatitude;
//! eastern longitude
@property (nonatomic,readwrite) float easternLongitude;
//! nothern latitude
@property (nonatomic,readwrite) float northernLatitude;
/**
 * Returns bounding box as a string
 * @return string representation of bounding box 
 */
-(NSString*) asString;

@end
