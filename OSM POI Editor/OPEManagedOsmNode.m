#import "OPEManagedOsmNode.h"
#import "OPEManagedOsmTag.h"


@interface OPEManagedOsmNode ()

// Private interface goes here.

@end


@implementation OPEManagedOsmNode

-(CLLocationCoordinate2D) center
{
    return CLLocationCoordinate2DMake(self.latitudeValue, self.longitudeValue);
}

-(NSData *) uploadXMLforChangset:(int64_t)changesetNumber
{
    NSString * xml = [self xmlWithTags:YES changeset:changesetNumber];
    return [xml dataUsingEncoding:NSUTF8StringEncoding];
}

-(NSData *) deleteXMLforChangset: (int64_t) changesetNumber
{
    
    NSString * xml = [self xmlWithTags:NO changeset:changesetNumber];
    
    return [xml dataUsingEncoding:NSUTF8StringEncoding];
    
}

-(NSString *)xmlWithTags:(BOOL)tags changeset:(int64_t)changesetNumber
{
    NSMutableString * xml = [NSMutableString stringWithFormat: @"<?xml version=\"1.0\" encoding=\"UTF-8\" ?>"];
    [xml appendString:@"<osm version=\"0.6\" generator=\"OSMPOIEditor\">"];
    
    if (self.osmIDValue < 0) {
        [xml appendFormat:@"<node lat=\"%f\" lon=\"%f\" changeset=\"%lld\">",self.latitudeValue,self.longitudeValue, changesetNumber];
    }
    else{
        [xml appendFormat:@"<node id=\"%lld\" lat=\"%f\" lon=\"%f\" version=\"%lld\" changeset=\"%lld\">",self.osmIDValue,self.latitudeValue,self.longitudeValue,self.versionValue, changesetNumber];
    }
    
    if (tags) {
        [xml appendString:[self tagsXML]];

    }
    [xml appendFormat: @"</node> @</osm>"];
    
    return xml;
}

-(BOOL)memberOfOtherElement
{
    if ([self.ways count]) {
        return YES;
    }
    return [super memberOfOtherElement];
}

-(NSString *)osmType
{
    return OPEOsmElementNode;
}

+(OPEManagedOsmNode *)newNode
{
    OPEManagedOsmNode * newNode = [OPEManagedOsmNode MR_createEntity];
    newNode.osmIDValue = [OPEManagedOsmElement minID]-1;
    
    return newNode;
}

@end
