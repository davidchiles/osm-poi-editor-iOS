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
        
        //return CLLocationCoordinate2DMake(centerLat/[self.nodes count], centerLon/[self.nodes count]);
        
        float twiceArea = 0.0f;
        double x = 0;
        double y = 0;
        //lat = y
        //long = x
        
        for (NSInteger index = 0; index < [self.nodes count]-1; index++)
        {
            OPEManagedOsmNode * node1 = [self.nodes objectAtIndex:index];
            OPEManagedOsmNode * node2 = [self.nodes objectAtIndex:index+1];
            
            twiceArea+=node1.longitudeValue*node2.latitudeValue;
            twiceArea-=node1.latitudeValue*node2.longitudeValue;
            double f = node1.longitudeValue*node2.latitudeValue-node2.longitudeValue*node1.latitudeValue;
            x+=(node1.longitudeValue*node2.longitudeValue)*f;
            y+=(node1.latitudeValue*node2.latitudeValue)*f;
            
            
        }
        double f = twiceArea*3;
        
        return CLLocationCoordinate2DMake(x/f, y/f);
        
        /*
        function get_polygon_centroid(pts){
            var twicearea=0,
            x=0, y=0,
            nPts = pts.length,
            p1, p2, f;
            for (var i=0, j=nPts-1 ;i<nPts;j=i++) {
                p1=pts[i]; p2=pts[j];
                twicearea+=p1.x*p2.y;
                twicearea-=p1.y*p2.x;
                f=p1.x*p2.y-p2.x*p1.y;
                x+=(p1.x+p2.x)*f;
                y+=(p1.y+p2.y)*f;
            }
            f=twicearea*3;
            return {x: x/f,y:y/f};
        }
         */
        
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
