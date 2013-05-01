#import "OPEManagedOsmWay.h"
#import "OPEManagedOsmNode.h"
#import "OPEManagedOsmTag.h"
#import "OPEGeo.h"
#import "OPEGeoCentroid.h"


@interface OPEManagedOsmWay ()

// Private interface goes here.

@end


@implementation OPEManagedOsmWay

-(id)initWithDictionary:(NSDictionary *)dictionary
{
    if (self = [super initWithDictionary:dictionary]) {
        self.element = [[Way alloc] initWithDictionary:dictionary];
    }
    return self;
}

-(CLLocationCoordinate2D)center
{
    if (self.isNoNameStreet) {
        return ((CLLocation *)[self.points objectAtIndex:0]).coordinate;
    }
    
    if([self.element.nodes count])
    {
        //double centerLat=0.0;
        //double centerLon=0.0;
        
        //centerLat = [[self.nodes valueForKeyPath:@"@sum.latitude"] doubleValue];
        //centerLon = [[self.nodes valueForKeyPath:@"@sum.longitude"] doubleValue];
        
        //return CLLocationCoordinate2DMake(centerLat/[self.nodes count], centerLon/[self.nodes count]);
        
        NSMutableArray * array = [NSMutableArray array];
        for (Node * node in self.element.nodes)
        {
            [array addObject:[[CLLocation alloc] initWithLatitude:node.latitude longitude:node.longitude]];
        }
        
        
        //CLLocationCoordinate2D center = [OPEGeo centroidOfPolygon:array];
        CLLocationCoordinate2D center = [[[OPEGeoCentroid alloc] init] centroidOfPolygon:array];
        return center;
    }
    return CLLocationCoordinate2DMake(0, 0);
}

-(NSData *) uploadXMLforChangset:(int64_t)changesetNumber
{
    NSMutableString * xml = [NSMutableString stringWithFormat: @"<?xml version=\"1.0\" encoding=\"UTF-8\" ?>"];
    [xml appendString:[NSString stringWithFormat: @"<osm version=\"0.6\" generator=\"OSMPOIEditor\">"]];
    [xml appendFormat:@"<way id=\"%lld\" version=\"%lld\" changeset=\"%lld\">",self.element.elementID,self.element.version, changesetNumber];
    
    for(Node * node in self.element.nodes)
    {
        [xml appendFormat:@"<nd ref=\"%lld\"/>",node.elementID];
    }
    
    [xml appendString:[self tagsXML]];
    
    [xml appendFormat: @"</way> @</osm>"];
    
    return [xml dataUsingEncoding:NSUTF8StringEncoding];
    
}

-(NSString *)osmType
{
    return kOPEOsmElementWay;
}

-(NSArray *)points
{
    NSMutableArray * mutablePointsArray = [NSMutableArray array];
    for (Node * node in self.element.nodes)
    {
        CLLocationCoordinate2D center = node.coordinate;
        CLLocation * location = [[CLLocation alloc]initWithLatitude:center.latitude longitude:center.longitude];
        [mutablePointsArray addObject:location];
    }
    return mutablePointsArray;
}
-(NSString *)name
{
    //FIXME
    if (self.isNoNameStreet) {
        return @"Highway Missing Name";
    }
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
