#import "OPEManagedOsmWay.h"
#import "OPEManagedOsmNode.h"
#import "OPEManagedOsmTag.h"


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

-(NSData *) updateXMLforChangset:(int64_t)changesetNumber
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
