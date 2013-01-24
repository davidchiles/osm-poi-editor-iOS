#import "OPEManagedOsmWay.h"
#import "OPEManagedOsmNode.h"


@interface OPEManagedOsmWay ()

// Private interface goes here.

@end


@implementation OPEManagedOsmWay

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
    return CLLocationCoordinate2DMake(0, 0);
}

@end
