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

@end
