#import "OPEManagedOsmWay.h"
#import "OPEManagedOsmNode.h"
#import "OPEManagedOsmTag.h"
#import "OPEGeo.h"


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
        
        NSMutableArray * array = [NSMutableArray array];
        for (OPEManagedOsmNode * node in self.nodes)
        {
            [array addObject:[[CLLocation alloc] initWithLatitude:node.latitudeValue longitude:node.longitudeValue]];
        }
        
        
        CLLocationCoordinate2D center = [OPEGeo centroidOfPolygon:array];
        return center;
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

-(NSString *)highwayType
{
    NSString * type = nil;
    
    NSString * highwayValue = [self valueForOsmKey:@"highway"];
    if ([highwayValue length]) {
        type = [[highwayValue stringByReplacingOccurrencesOfString:@"_" withString:@" "] capitalizedString];
    }
    
    
    
    
    return type;
}

@end
