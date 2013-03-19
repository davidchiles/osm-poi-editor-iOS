#import "OPEManagedOsmWay.h"
#import "OPEManagedOsmNode.h"
#import "OPEManagedOsmTag.h"


@interface OPEManagedOsmWay ()

// Private interface goes here.

@end


@implementation OPEManagedOsmWay

-(CLLocationCoordinate2D)center
{
    if (self.isNoNameStreetValue) {
        return ((CLLocation *)[self.points objectAtIndex:0]).coordinate;
    }
    
    if(self.nodes)
    {
        double centerLat=0.0;
        double centerLon=0.0;
        
        centerLat = [[self.nodes valueForKeyPath:@"@sum.latitude"] doubleValue];
        centerLon = [[self.nodes valueForKeyPath:@"@sum.longitude"] doubleValue];
        
        return CLLocationCoordinate2DMake(centerLat/[self.nodes count], centerLon/[self.nodes count]);
    }
    return CLLocationCoordinate2DMake(0, 0);
}

-(NSData *) uploadXMLforChangset:(int64_t)changesetNumber
{
    NSMutableString * xml = [NSMutableString stringWithFormat: @"<?xml version=\"1.0\" encoding=\"UTF-8\" ?>"];
    [xml appendString:[NSString stringWithFormat: @"<osm version=\"0.6\" generator=\"OSMPOIEditor\">"]];
    [xml appendFormat:@"<way id=\"%lld\" version=\"%lld\" changeset=\"%lld\">",self.osmIDValue,self.versionValue, changesetNumber];
    
    for(OPEManagedOsmNode * node in self.nodes)
    {
        [xml appendFormat:@"<nd ref=\"%lld\"/>",node.osmIDValue];
    }
    
    [xml appendString:[self tagsXML]];
    
    [xml appendFormat: @"</way> @</osm>"];
    
    return [xml dataUsingEncoding:NSUTF8StringEncoding];
    
}

-(NSString *)osmType
{
    return OPEOsmElementWay;
}

-(NSArray *)points
{
    NSMutableArray * mutablePointsArray = [NSMutableArray array];
    for (OPEManagedOsmNode * node in self.nodes)
    {
        CLLocationCoordinate2D center = [node center];
        CLLocation * location = [[CLLocation alloc]initWithLatitude:center.latitude longitude:center.longitude];
        [mutablePointsArray addObject:location];
        
    }
    return mutablePointsArray;
}
-(NSString *)name
{
    if (self.isNoNameStreetValue) {
        return @"Highway Missing Name";
    }
    return [super name];
}

-(BOOL)noNameStreet
{
    if ([[self name] length]) {
        return NO;
    }
    
    
    
    NSString * highwayValue = [self valueForOsmKey:@"highway"];
    
    if ([highwayValue length])
    {
        NSSet * highwaySet = [NSSet setWithArray:highwayTypes];
        
        if ([highwaySet containsObject:highwayValue]) {
            return YES;
        }
        
    }
    return NO;
    
}

+(OPEManagedOsmWay *)fetchOrCreatWayWithOsmID:(int64_t)wayID
{
    NSPredicate *osmNodeFilter = [NSPredicate predicateWithFormat:@"osmID == %d",wayID];
    
    NSArray * results = [OPEManagedOsmWay MR_findAllWithPredicate:osmNodeFilter];
    
    OPEManagedOsmWay * osmWay = nil;
    
    if([results count])
    {
        osmWay = [results lastObject];
    }
    else{
        osmWay = [OPEManagedOsmWay MR_createEntity];
        osmWay.osmIDValue = wayID;
    }
    
    return osmWay;
}

@end
