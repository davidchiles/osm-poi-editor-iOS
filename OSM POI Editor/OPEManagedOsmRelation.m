#import "OPEManagedOsmRelation.h"
#import "OpeManagedOsmRelationMember.h"
#import "OPEManagedOsmWay.h"


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

-(void)addInOrderElement:(OPEManagedOsmElement *)element withRole:(NSString *)role
{
    OpeManagedOsmRelationMember * member = [OpeManagedOsmRelationMember MR_createEntity];
    member.member = element;
    if ([role length]) {
        member.role = role;
    }
    [self.membersSet addObject:member];

}
-(NSIndexSet *)outerPolygonsIndexes
{
    NSIndexSet * rolseSet = [self.members indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        if( [((OpeManagedOsmRelationMember *)obj).role isEqualToString:@"outer"]){
            CLLocationCoordinate2D center = [((OpeManagedOsmRelationMember *)obj).member center];
            if (!(center.latitude == 0 && center.longitude == 0)) {
                return YES;
            }
        }
        return NO;
    }];
    return rolseSet;
}
-(NSIndexSet *)innerPolygonsIndexes
{
    NSIndexSet * rolseSet = [self.members indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        if( [((OpeManagedOsmRelationMember *)obj).role isEqualToString:@"inner"]){
            CLLocationCoordinate2D center = [((OpeManagedOsmRelationMember *)obj).member center];
            if (!(center.latitude == 0 && center.longitude == 0)) {
                return YES;
            }
        }
        return NO;
    }];
    return rolseSet;
}

-(NSArray *)outerPolygons
{
    NSMutableArray * PointsArray = [NSMutableArray array];
    NSIndexSet * indexes = [self outerPolygonsIndexes];
    
    NSArray * outerMembers = [self.members objectsAtIndexes:indexes];
    
    for (OpeManagedOsmRelationMember * member in outerMembers)
    {
        if ([member.member isKindOfClass:[OPEManagedOsmWay class]]) {
            [PointsArray addObject:((OPEManagedOsmWay *)member.member).points];
        }
    }
    return PointsArray;
}
-(NSArray *)innerPolygons
{
    NSMutableArray * PointsArray = [NSMutableArray array];
    NSIndexSet * indexes = [self innerPolygonsIndexes];
    
    NSArray * innerMembers = [self.members objectsAtIndexes:indexes];
    
    for (OpeManagedOsmRelationMember * member in innerMembers)
    {
        if ([member.member isKindOfClass:[OPEManagedOsmWay class]]) {
            [PointsArray addObject:((OPEManagedOsmWay *)member.member).points];
        }
    }
    return PointsArray;
}

@end
