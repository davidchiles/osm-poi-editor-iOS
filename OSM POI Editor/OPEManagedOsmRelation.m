#import "OPEManagedOsmRelation.h"
#import "OpeManagedOsmRelationMember.h"


@interface OPEManagedOsmRelation ()

// Private interface goes here.

@end


@implementation OPEManagedOsmRelation

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
    return CLLocationCoordinate2DMake(0, 0);
}

-(NSString *)osmType
{
    return OPEOsmElementRelation;
}

@end
