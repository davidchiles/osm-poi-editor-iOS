//
//  GeoCodingJsonParser.h
//  
//
//  Created by Dmytro Golub on 9/4/09.
//  Copyright 2009 CloudMade. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "bbox.h"

//! Json parser for server response
@interface GeoCodingJsonParser : NSObject
{

}
/// \deprecated subject to removal at any moment fillLocationsArray method should be used instead \sa fillLocationsArray
/**
 * Returns arrays of Location \sa Location
 * @param jsonObjects json server's response
 * @return arrays of Location \sa Location
 */
-(NSArray*) getObjects:(NSString*) jsonObjects;
-(BBox*) boundBox:(NSString*) json;
/**
 * Returns arrays of Location \sa Location
 * @param jsonObjects json server's response
 * @return arrays of Location \sa Location
 */
-(NSArray*) fillLocationsArray:(NSString*) jsonObjects;

@end
