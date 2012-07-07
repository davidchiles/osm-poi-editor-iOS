//
//  OPEWay.m
//  OSM POI Editor
//
//  Created by David Chiles on 7/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "OPEWay.h"

@implementation OPEWay

@synthesize nodes;

-(id)init
{
    self = [super init];
    
    return self;
}

-(id)initWithArrayOfNodes:(NSArray *)arrayOfNodes tags:(NSMutableDictionary *)tagDictioanry ID:(int)i version:(int)version
{
    self = [self init];
    nodes = arrayOfNodes;
    [self setLattitudeandLongitude];
    
    self.ident = i;
    self.tags = tagDictioanry;
    
    
    return self;
}

-(id)initWithArrayOfNodes:(NSArray *)arrayOfNodes ID:(int)i version:(int)version
{
    self = [self init];
    nodes = arrayOfNodes;
    [self setLattitudeandLongitude];
    self.ident = i;
    self.tags = [NSMutableArray array];
    
    return self;
}

-(void)setLattitudeandLongitude 
{
    if(nodes)
    {
        double centerLat=0.0;
        double centerLon=0.0;
        for(OPENode * node in nodes)
        {
            centerLat += node.coordinate.latitude;
            centerLon += node.coordinate.longitude;
        }
        self.coordinate = CLLocationCoordinate2DMake(centerLat/[nodes count], centerLon/[nodes count]);
    }
}


@end
