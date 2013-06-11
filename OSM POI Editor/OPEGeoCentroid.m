//
//  OPEGeoCentroid.m
//  OSM POI Editor
//
//  Created by David on 4/15/13.
//
//

#import "OPEGeoCentroid.h"
#import "OPEGeo.h"

@implementation OPEGeoCentroid

@synthesize basePoint;
@synthesize centerPoint;
@synthesize area;

-(id)init
{
    if(self = [super init])
    {
        basePoint.x = basePoint.y = 0.0;
        centerPoint.x = centerPoint.y = 0.0;
        area = 0.0;
        
    }
    return self;
}


-(CLLocationCoordinate2D)centroidOfPolygon:(NSArray *)points
{
    basePoint = [OPEGeo coordinateToProjectedPoint:((CLLocation *)points[0]).coordinate];
    
    for (NSInteger index = 0; index < [points count]-1; index++)
    {
        NSInteger secondIndex = index+1;
        
        OPEProjectedPoint point1 = [OPEGeo coordinateToProjectedPoint:((CLLocation *)points[index]).coordinate];
        OPEProjectedPoint point2 = [OPEGeo coordinateToProjectedPoint:((CLLocation *)points[secondIndex]).coordinate];
        
        [self addTriangleWithPoints:basePoint point2:point1 point3:point2];
        
    }
    centerPoint.x =centerPoint.x/3.0/area;
    centerPoint.y = centerPoint.y/3.0/area;
    
    return [OPEGeo toCoordinate:centerPoint];
        
}

-(void)addTriangleWithPoints:(OPEProjectedPoint) p1 point2:(OPEProjectedPoint) p2 point3:(OPEProjectedPoint) p3
{
    double sign = 1.0;
    OPEProjectedPoint triangleCenter3 = [self center3OfTriangle:p1 point2:p2 point3:p3];
    double areaTriangle2 =fabs([self areaTriangle2:p1 point2:p2 point3:p3]);
    
    centerPoint.x+=sign*areaTriangle2*triangleCenter3.x;
	centerPoint.y+=sign*areaTriangle2*triangleCenter3.y;
	area+=sign*areaTriangle2;
    
    
}

-(double)areaTriangle2:(OPEProjectedPoint) p1 point2:(OPEProjectedPoint) p2 point3:(OPEProjectedPoint) p3
{
    return (p2.x-p1.x)*(p3.y-p1.y)-(p3.x-p1.x)*(p2.y-p1.y);
}

-(OPEProjectedPoint)center3OfTriangle:(OPEProjectedPoint) p1 point2:(OPEProjectedPoint) p2 point3:(OPEProjectedPoint) p3
{
    OPEProjectedPoint center;
    
    center.x=p1.x+p2.x+p3.x;
	center.y=p1.y+p2.y+p3.y;
    
    return center;
    
}

+(CLLocationCoordinate2D)centroidOfPolyline:(NSArray *)points
{
    double TotalDistance = 0;
    for (int index = 0; index < [points count]-1; index++)
    {
        TotalDistance += [OPEGeo distance:((CLLocation *)points[index]).coordinate to:((CLLocation *)points[index+1]).coordinate];
    }
    
    double DistanceSoFar = 0;
    for (int index = 0; index < [points count]-1; index++) {
        //
        // If this linesegment puts us past the middle then this
        // is the segment in which the midpoint appears
        //
        if (DistanceSoFar + [OPEGeo distance:((CLLocation *)points[index]).coordinate to:((CLLocation *)points[index+1]).coordinate] > TotalDistance / 2.0) {
            //
            // Figure out how far to the midpoint
            //
            double DistanceToMidpoint = TotalDistance / 2 - DistanceSoFar;
            
            //
            // Given the start/end of a line and a distance return the point
            // on the line the specified distance away
            //
            return [self lineInterpolateFrom:((CLLocation *)points[index]).coordinate to:((CLLocation *)points[index+1]).coordinate withDistance:DistanceToMidpoint];
        }
        
        DistanceSoFar += [OPEGeo distance:((CLLocation *)points[index]).coordinate to:((CLLocation *)points[index+1]).coordinate];
    }
    
    //
    // Can happen when the line is of zero length... so just return the first segment
    //
    return ((CLLocation *)points[0]).coordinate;
    
}

+(CLLocationCoordinate2D)lineInterpolateFrom:(CLLocationCoordinate2D) point1 to:(CLLocationCoordinate2D) point2 withDistance:(double)distance {
    OPEProjectedPoint projectedPoint1 = [OPEGeo coordinateToProjectedPoint:point1];
    OPEProjectedPoint projectedPoint2 = [OPEGeo coordinateToProjectedPoint:point2];
    
    double xabs = fabs(projectedPoint1.x - projectedPoint2.x);
    double yabs = fabs(projectedPoint1.y - projectedPoint2.y);
    double xdiff = projectedPoint2.x - projectedPoint1.x;
    double ydiff = projectedPoint2.y - projectedPoint1.y;
    
    double length = sqrt((pow(xabs, 2) + pow(yabs, 2)));
    double steps = length / distance;
    double xstep = xdiff / steps;
    double ystep = ydiff / steps;
    
    OPEProjectedPoint newPoint;
    newPoint.x = projectedPoint1.x + xstep;
    newPoint.y = projectedPoint1.y + ystep;
    
    return [OPEGeo toCoordinate:newPoint];
}


@end
