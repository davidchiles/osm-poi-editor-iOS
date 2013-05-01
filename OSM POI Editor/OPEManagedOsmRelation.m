#import "OPEManagedOsmRelation.h"
#import "OpeManagedOsmRelationMember.h"
#import "OPEManagedOsmWay.h"


@interface OPEManagedOsmRelation ()

// Private interface goes here.

@end


@implementation OPEManagedOsmRelation

@synthesize element;

-(CLLocationCoordinate2D) center
{
    if([self.element.members count])
    {
        double centerLat=0.0;
        double centerLon=0.0;
        for(Member * member in self.element.members)
        {
            OPEManagedOsmElement * memberElement  = [OPEManagedOsmElement elementWithBasicOsmElement:member.member];
            CLLocationCoordinate2D nodeCenter = [memberElement center];
            centerLat += nodeCenter.latitude;
            centerLon += nodeCenter.longitude;
        }
        return CLLocationCoordinate2DMake(centerLat/[self.element.members count], centerLon/[self.element.members count]);
    }
    return CLLocationCoordinate2DMake(0, 0);
}

-(NSString *)osmType
{
    return kOPEOsmElementRelation;
}

-(NSIndexSet *)outerPolygonsIndexes
{
    NSIndexSet * rolseSet = [self.element.members indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        if( [((Member *)obj).role isEqualToString:@"outer"]){
            CLLocationCoordinate2D center = [[OPEManagedOsmElement elementWithBasicOsmElement:((Member *)obj).member] center];
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
    NSIndexSet * rolseSet = [self.element.members indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        if( [((Member *)obj).role isEqualToString:@"inner"]){
            CLLocationCoordinate2D center = [[OPEManagedOsmElement elementWithBasicOsmElement:((Member *)obj).member] center];
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
    
    NSArray * outerMembers = [self.element.members objectsAtIndexes:indexes];
    
    for (Member * member in outerMembers)
    {
        if ([member.member isKindOfClass:[Way class]]) {
            OPEManagedOsmWay * way = (OPEManagedOsmWay *)[OPEManagedOsmElement elementWithBasicOsmElement:member.member];
            [PointsArray addObject:way.points];
        }
    }
    return PointsArray;
}
-(NSArray *)innerPolygons
{
    NSMutableArray * PointsArray = [NSMutableArray array];
    NSIndexSet * indexes = [self innerPolygonsIndexes];
    
    NSArray * innerMembers = [self.element.members objectsAtIndexes:indexes];
    
    for (Member * member in innerMembers)
    {
        if ([member.member isKindOfClass:[OPEManagedOsmWay class]]) {
            OPEManagedOsmWay * way = (OPEManagedOsmWay *)[OPEManagedOsmElement elementWithBasicOsmElement:member.member];
            [PointsArray addObject:way.points];
        }
    }
    return PointsArray;
}

-(NSData *) uploadXMLforChangset:(int64_t)changesetNumber
{
    NSMutableString * xml = [NSMutableString stringWithFormat: @"<?xml version=\"1.0\" encoding=\"UTF-8\" ?>"];
    [xml appendString:[NSString stringWithFormat: @"<osm version=\"0.6\" generator=\"OSMPOIEditor\">"]];
    [xml appendFormat:@"<relation id=\"%lld\" version=\"%lld\" changeset=\"%lld\">",self.element.elementID,self.element.version, changesetNumber];
    
    for(Member * relationMember in self.element.members)
    {
        NSString * memberRoleString = @"";
        if ([relationMember.role length]) {
            memberRoleString = relationMember.role;
        }
        [xml appendFormat:@"<member type=\"%@\" ref=\"%lld\" role=\"%@\"/>",relationMember.type,relationMember.ref,relationMember.role];
    }
    
    [xml appendString:[self tagsXML]];
    
    [xml appendFormat: @"</relation> @</osm>"];
    
    return [xml dataUsingEncoding:NSUTF8StringEncoding];
    
}

@end
