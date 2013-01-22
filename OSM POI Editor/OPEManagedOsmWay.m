//
//  OPEManagedOsmWay.m
//  OSM POI Editor
//
//  Created by David on 1/22/13.
//
//

#import "OPEManagedOsmWay.h"
#import "OPEManagedOsmNode.h"


@implementation OPEManagedOsmWay

@dynamic isArea;
@dynamic nodes;

-(CLLocationCoordinate2D)center
{
    if(self.nodes)
    {
        double centerLat=0.0;
        double centerLon=0.0;
        for(OPEManagedOsmNode * node in self.nodes)
        {
            CLLocationCoordinate2D nodeCenter = [node center];
            centerLat += nodeCenter.latitude;
            centerLon += nodeCenter.longitude;
        }
        return CLLocationCoordinate2DMake(centerLat/[self.nodes count], centerLon/[self.nodes count]);
    }
    return nil;
}

@end
