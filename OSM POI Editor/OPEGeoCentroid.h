//
//  OPEGeoCentroid.h
//  OSM POI Editor
//
//  Created by David on 4/15/13.
//
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "OPEGeo.h"

@interface OPEGeoCentroid : NSObject

@property (nonatomic) OPEProjectedPoint basePoint;
@property (nonatomic) OPEProjectedPoint centerPoint;
@property (nonatomic) double area;

-(CLLocationCoordinate2D)centroidOfPolygon:(NSArray *)points;

@end
