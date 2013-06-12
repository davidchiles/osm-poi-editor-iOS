#import "OPEManagedOsmElement.h"
#import "OPEManagedReferencePoi.h"
#import "OPEUtility.h"
#import "OPEManagedOsmWay.h"
#import "OPEManagedOsmNode.h"
#import "OPEGeo.h"
#import "OPEManagedOsmRelation.h"

#import "OPEManagedOsmTag.h"

#import "OPEStrings.h"



@interface OPEManagedOsmElement ()

// Private interface goes here.

@end


@implementation OPEManagedOsmElement
@synthesize typeID,type,isVisible,element,action;
@synthesize idKeyPrefix,idKey;

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

+(OPEManagedOsmElement *)elementWithBasicOsmElement:(Element *)element
{
    if ([element isKindOfClass:[Node class]]) {
        OPEManagedOsmNode * node = [[OPEManagedOsmNode alloc] init];
        node.element = (Node *)element;
        return node;
    }
    else if ([element isKindOfClass:[Way class]]) {
        OPEManagedOsmWay * way = [[OPEManagedOsmWay alloc] init];
        way.element = (Way *)element;
        return way;
    }
    else if ([element isKindOfClass:[Relation class]]) {
        OPEManagedOsmRelation * relation = [[OPEManagedOsmRelation alloc] init];
        relation.element = (Relation *)element;
        return relation;
    }
    return nil;
}

+(OPEManagedOsmElement *)elementWithType:(NSString *)elementTypeString withDictionary:(NSDictionary *)dictionary;
{
    OPEManagedOsmElement * element = nil;
    if ([elementTypeString isEqualToString:kOPEOsmElementNode]) {
        element = [[OPEManagedOsmNode alloc] initWithDictionary:dictionary];
    }
    else if ([elementTypeString isEqualToString:kOPEOsmElementWay]) {
        element = [[OPEManagedOsmWay alloc] initWithDictionary:dictionary];
    }
    else if ([elementTypeString isEqualToString:kOPEOsmElementRelation]) {
        element = [[OPEManagedOsmRelation alloc] initWithDictionary:dictionary];
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
    if ([self isKindOfClass:[OPEManagedOsmWay class]]) {
        if(((OPEManagedOsmWay *)self).isNoNameStreet)
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
