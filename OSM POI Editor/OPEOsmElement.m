#import "OPEOsmElement.h"
#import "OPEReferencePoi.h"
#import "OPEUtility.h"
#import "OPEOsmWay.h"
#import "OPEOsmNode.h"
#import "OPEGeo.h"
#import "OPEOsmRelation.h"

#import "OPEOsmTag.h"

#import "OPEStrings.h"



@interface OPEOsmElement ()

// Private interface goes here.

@end


@implementation OPEOsmElement

-(id)init
{
    if (self = [super init]) {
        self.isVisible = YES;
    }
    return self;
}
-(id)initWithDictionary:(NSDictionary *)dictionary
{
    if (self = [self init]) {
        //self.element = [[Element alloc] initWithDictionary:dictionary];
        self.isVisible = dictionary[@"isVisible"];
        
        self.action = dictionary[@"action"];
        if ([dictionary[@"poi_id"] isKindOfClass:[NSNumber class]]) {
            self.typeID = [dictionary[@"poi_id"] intValue];
        }
        
    }
    return self;
    
}

-(CLLocationCoordinate2D)center
{
    return CLLocationCoordinate2DMake(0, 0);
}

-(NSString *)valueForOsmKey:(NSString *)osmKey
{
    return self.element.tags[osmKey];
}

-(int64_t)elementID
{
    return self.element.elementID;
}
-(void)setElementID:(int64_t)elementID
{
    self.element.elementID = elementID;
}

-(NSString *)tagsXML
{
    NSMutableString * xml = [NSMutableString stringWithString:@""];
    for (NSString *osmKey in self.element.tags)
    {
        [xml appendFormat:@"<tag k=\"%@\" v=\"%@\"/>",osmKey,[OPEUtility addHTML:self.element.tags[osmKey]]];
    }
    return xml;
}

-(NSString *)tagsDescription
{
    return @"";
}

-(NSString *)description
{
    return [NSString stringWithFormat:@"%@ %@",[super description],[self tagsDescription]];
}

-(NSString *)osmType
{
    return kOPEOsmElementNone;
}

-(NSString *)idKey
{
    return [NSString stringWithFormat:@"%@%lld",self.idKeyPrefix,self.elementID];
}

+(OPEOsmElement *)elementWithBasicOsmElement:(OSMElement *)element
{
    if ([element isKindOfClass:[OSMNode class]]) {
        OPEOsmNode * node = [[OPEOsmNode alloc] init];
        node.element = (OSMNode *)element;
        return node;
    }
    else if ([element isKindOfClass:[OSMWay class]]) {
        OPEOsmWay * way = [[OPEOsmWay alloc] init];
        way.element = (OSMWay *)element;
        return way;
    }
    else if ([element isKindOfClass:[OSMRelation class]]) {
        OPEOsmRelation * relation = [[OPEOsmRelation alloc] init];
        relation.element = (OSMRelation *)element;
        return relation;
    }
    return nil;
}

+(OPEOsmElement *)elementWithType:(NSString *)elementTypeString withDictionary:(NSDictionary *)dictionary;
{
    OPEOsmElement * element = nil;
    if ([elementTypeString isEqualToString:kOPEOsmElementNode]) {
        element = [[OPEOsmNode alloc] initWithDictionary:dictionary];
    }
    else if ([elementTypeString isEqualToString:kOPEOsmElementWay]) {
        element = [[OPEOsmWay alloc] initWithDictionary:dictionary];
    }
    else if ([elementTypeString isEqualToString:kOPEOsmElementRelation]) {
        element = [[OPEOsmRelation alloc] initWithDictionary:dictionary];
    }
    return element;
}

-(NSData *) uploadXMLforChangset: (int64_t)changesetNumber
{
    return nil;
}
-(NSData *) deleteXMLforChangset: (int64_t) changesetNumber
{
    return nil;
}

-(NSString *)displayNameForChangeset
{
    if ([self isKindOfClass:[OPEOsmWay class]]) {
        if(((OPEOsmWay *)self).isNoNameStreet)
        {
            return NO_NAME_STRING;
        }
    }
    else if ([[self valueForOsmKey:@"name"] length])
    {
        return [self valueForOsmKey:@"name"];
    }
    else if(self.type)
    {
        return self.type.name;
    }
    return [self osmType];
}

@end
