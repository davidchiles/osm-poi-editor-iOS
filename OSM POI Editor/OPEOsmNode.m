#import "OPEOsmNode.h"
#import "OPEOsmTag.h"


@interface OPEOsmNode ()

// Private interface goes here.

@end


@implementation OPEOsmNode

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

-(NSString *)idKeyPrefix
{
    return @"n";
}

-(NSString *)osmType
{
    return kOPEOsmElementNode;
}

+(OPEOsmNode *)newNode
{
    OPEOsmNode * node = [[OPEOsmNode alloc] init];
    node.element = [[Node alloc] init];
    return node;
}

@end
