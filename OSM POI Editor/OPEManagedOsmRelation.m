//
//  OPEManagedOsmRelation.m
//  OSM POI Editor
//
//  Created by David on 1/22/13.
//
//

#import "OPEManagedOsmRelation.h"
#import "OpeManagedOsmRelationMember.h"


@implementation OPEManagedOsmRelation

@dynamic members;

-(CLLocationCoordinate2D) center
{
    if(self.members)
    {
        double centerLat=0.0;
        double centerLon=0.0;
        for(OpeManagedOsmRelationMember * member in self.members)
        {
            CLLocationCoordinate2D nodeCenter = [member.member center];
            centerLat += nodeCenter.latitude;
            centerLon += nodeCenter.longitude;
        }
        return CLLocationCoordinate2DMake(centerLat/[self.members count], centerLon/[self.members count]);
    }
    return nil;
}

@end
