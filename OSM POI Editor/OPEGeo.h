//
//  OPEGeo.h
//  OSM POI Editor
//
//  Created by David on 3/25/13.
//
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface OPEBoundingBox : NSObject;

@property (nonatomic) double left;
@property (nonatomic) double right;
@property (nonatomic) double top;
@property (nonatomic) double bottom;

+(id)boundingBoxSW:(CLLocationCoordinate2D)southWest NE:(CLLocationCoordinate2D)northEast;

@end

@interface OPEGeo : NSObject

typedef struct {
	double x, y;
} OPEProjectedPoint;

typedef struct {
	CLLocationCoordinate2D x, y;
} OPELineSegment;

typedef struct {
	OPEProjectedPoint x, y;
} OPEProjectedLineSegment;

+(double)degreesToRadians:(double)degrees;
+(double)radiansToDegrees:(double)radians;
+(double)distance:(CLLocationCoordinate2D)point1 to:(CLLocationCoordinate2D)point2;
+(double)bearingFrom:(CLLocation *)location1 to:(CLLocation *)location2;
+(OPELineSegment)lineSegmentFromPoint:(CLLocationCoordinate2D)point1 toPoint:(CLLocationCoordinate2D)point2;
+(double)distanceFromlineSegment:(OPELineSegment)lineSegment toPoint:(CLLocationCoordinate2D)point;
//+(CLLocationCoordinate2D)centroidOfPolygon:(NSArray *)points;
+(OPEProjectedPoint)coordinateToProjectedPoint:(CLLocationCoordinate2D)aLatLong;
+(CLLocationCoordinate2D)toCoordinate:(OPEProjectedPoint)point;

+(BOOL)boundingBox:(OPEBoundingBox *)boundingBox containsPoint:(CLLocationCoordinate2D)point;

@end
