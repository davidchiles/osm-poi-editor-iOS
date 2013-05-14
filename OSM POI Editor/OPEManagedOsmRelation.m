#import "OPEManagedOsmRelation.h"
#import "OpeManagedOsmRelationMember.h"
#import "OPEManagedOsmWay.h"


@interface OPEManagedOsmRelation ()

// Private interface goes here.

@end


@implementation OPEManagedOsmRelation

@synthesize element;

-(id)initWithDictionary:(NSDictionary *)dictionary
{
    if (self = [super initWithDictionary:dictionary]) {
        self.element = [[Relation alloc] initWithDictionary:dictionary];
    }
    return self;
}

-(NSString *)osmType
{
    return kOPEOsmElementRelation;
}

-(NSString *)idKeyPrefix
{
    return @"r";
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
