#import "OPEManagedOsmNode.h"
#import "OPEManagedOsmTag.h"


@interface OPEManagedOsmNode ()

// Private interface goes here.

@end


@implementation OPEManagedOsmNode
@synthesize element;

-(id)initWithDictionary:(NSDictionary *)dictionary
{
    if (self = [super initWithDictionary:dictionary]) {
        self.element = [[Node alloc] initWithDictionary:dictionary];
    }
    return self;
}

-(CLLocationCoordinate2D) center
{
    return [self.element coordinate];
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
    
    if (self.element.elementID < 0) {
        [xml appendFormat:@"<node lat=\"%f\" lon=\"%f\" changeset=\"%lld\">",self.element.latitude,self.element.longitude, changesetNumber];
    }
    else{
        [xml appendFormat:@"<node id=\"%lld\" lat=\"%f\" lon=\"%f\" version=\"%lld\" changeset=\"%lld\">",self.element.elementID,self.element.latitude,self.element.longitude,self.element.version, changesetNumber];
    }
    
    if (tags) {
        [xml appendString:[self tagsXML]];

    }
    [xml appendFormat: @"</node> @</osm>"];
    
    return xml;
}

-(BOOL)memberOfOtherElement
{
    //FIXME
    /*
    if ([self.ways count]) {
        return YES;
    }
    return [super memberOfOtherElement];
     */
}

-(NSString *)osmType
{
    return kOPEOsmElementNode;
}

@end
