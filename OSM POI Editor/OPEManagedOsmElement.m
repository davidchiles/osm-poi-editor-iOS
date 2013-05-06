#import "OPEManagedOsmElement.h"
#import "OPEManagedReferencePoi.h"
#import "OPEUtility.h"
#import "OPEManagedOsmWay.h"
#import "OPEManagedOsmNode.h"
#import "OPEGeo.h"
#import "OPEManagedOsmRelation.h"

#import "OPEManagedOsmTag.h"



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

-(NSDictionary *)nearbyValuesForOsmKey:(NSString *)osmKey
{
    NSDictionary * values = nil;
    if ([osmKey isEqualToString:@"addr:street"]) {
        values = [self nearbyHighwayNames];
    }
    else if ([osmKey isEqualToString:@"addr:city"]) {
        values = [self nearbyCities];
    }
    else if ([osmKey isEqualToString:@"addr:state"])
    {
        values = [self nearbyStates];
    }
    else if ([osmKey isEqualToString:@"addr:province"])
    {
        values = [self nearbyProvinces];
    }
    else if ([osmKey isEqualToString:@"addr:postcode"])
    {
        values = [self nearbyPostcodes];
    }
    
    
    return values;
}
+(NSArray *)allElementsWithTag:(OPEManagedOsmTag *)tag
{
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"%@ IN self.tags",tag];
    
    //FIXME
    //return [OPEManagedOsmElement MR_findAllWithPredicate:predicate];
}

-(NSDictionary *)nearbyCities
{
    NSArray *values = [OPEManagedOsmTag uniqueValuesForOsmKeys:@[@"addr:city"]];
    
    OPEManagedOsmTag * cityTag = [OPEManagedOsmTag fetchOrCreateWithKey:@"place" value:@"city"];
    
    NSArray * cities = [OPEManagedOsmElement allElementsWithTag:cityTag];
    NSArray *cityNames = [cities valueForKey:@"name"];
    
    NSMutableSet * allCityNamesSet = [NSMutableSet setWithArray:values];
    [allCityNamesSet addObjectsFromArray:cityNames];
    
    NSNumber * num = [NSNumber numberWithInt:-1];
    NSMutableDictionary * dictionary = [NSMutableDictionary dictionary];
    for (NSString * name in allCityNamesSet)
    {
        [dictionary setObject:num forKey:name];
    }
    
    return dictionary;
}
-(NSDictionary *)nearbyStates
{
    NSArray *values = [OPEManagedOsmTag uniqueValuesForOsmKeys:@[@"addr:state"]];
    NSArray *uppercaseStrings = [values valueForKey:@"uppercaseString"];
    
    NSNumber * num = [NSNumber numberWithInt:-1];
    NSMutableDictionary * dictionary = [NSMutableDictionary dictionary];
    for (NSString * name in uppercaseStrings)
    {
        [dictionary setObject:num forKey:name];
    }
    
    return dictionary;
    
    
}
-(NSDictionary *)nearbyProvinces
{
    NSArray *values = [OPEManagedOsmTag uniqueValuesForOsmKeys:@[@"addr:province"]];
    
    NSNumber * num = [NSNumber numberWithInt:-1];
    NSMutableDictionary * dictionary = [NSMutableDictionary dictionary];
    for (NSString * name in values)
    {
        [dictionary setObject:num forKey:name];
    }
    
    return dictionary;
}
-(NSDictionary *)nearbyPostcodes
{
    NSArray *values = [OPEManagedOsmTag uniqueValuesForOsmKeys:@[@"addr:postcode",@"tiger:zip_left",@"tiger:zip_right"]];
    
    NSNumber * num = [NSNumber numberWithInt:-1];
    NSMutableDictionary * dictionary = [NSMutableDictionary dictionary];
    for (NSString * name in values)
    {
        [dictionary setObject:num forKey:name];
    }
    
    return dictionary;
}

-(double)minDistanceTo:(OPEManagedOsmWay *)way
{
    double distance = DBL_MAX;
    for (NSInteger index = 0; index<[way.element.nodes count]-1; index++) {
        Node * node1 = ((Node *)[way.element.nodes objectAtIndex:index]);
        Node * node2 = ((Node *)[way.element.nodes objectAtIndex:index+1]);
        
        OPELineSegment line = [OPEGeo lineSegmentFromPoint:node1.coordinate toPoint:node2.coordinate];
        
        double tempDistance  =  [OPEGeo distanceFromlineSegment:line toPoint:[self center]];
        distance = MIN(distance, tempDistance);
        
        
    }
    return distance;
    
}

-(NSDictionary *)nearbyHighwayNames
{
    /*
    NSPredicate * tagPredicate = [NSPredicate predicateWithFormat:@"%K == %@",OPEManagedOsmTagAttributes.key,@"highway"];
    NSArray * tags = [OPEManagedOsmTag MR_findAllWithPredicate:tagPredicate];
    
    NSPredicate * prediacte = [NSPredicate predicateWithFormat:@"(SUBQUERY(tags, $tag, $tag IN %@).@count >0)",tags];
    
    
    NSArray * ways = [OPEManagedOsmWay MR_findAllWithPredicate:prediacte];
    
    NSMutableDictionary * highwayDictionary = [NSMutableDictionary dictionary];
    
    for (OPEManagedOsmWay * way in ways)
    {
        NSString * wayName = [way valueForOsmKey:@"name"];
        if ([wayName length]) {
            double wayDistance = [self minDistanceTo:way];
            
            if (wayDistance < 20000) {
                if (![highwayDictionary objectForKey:wayName]) {
                    [highwayDictionary setObject:[NSNumber numberWithDouble:wayDistance] forKey:wayName];
                }
                else
                {
                    double tempDistance = [[highwayDictionary objectForKey:wayName] doubleValue];
                    double distance = MIN(tempDistance, wayDistance);
                    [highwayDictionary setObject:[NSNumber numberWithDouble:distance] forKey:wayName];
                }

            }
            
                    }
    }
    
    return highwayDictionary;
     */
}

-(void)updateLegacyTags
{
    if (self.type.isLegacy && self.type.currentTagMethod) {
        OPEManagedReferencePoi * newType = self.type.currentTagMethod;
        for (OPEManagedOsmTag * tag in newType.tags)
        {
            [self addKey:tag.key value:tag.value];
        }
        self.type = newType;
        
    }
    
    
}

+(OPEManagedOsmElement *)fetchOrCreateWithOsmID:(int64_t)ID type:(NSString *)typeString
{
    OPEManagedOsmElement * element = nil;
    if ([typeString isEqualToString:kOPEOsmElementNode]) {
        element = [OPEManagedOsmNode fetchOrCreateWithOsmID:ID];
    }
    else if ([typeString isEqualToString:kOPEOsmElementWay]) {
        element = [OPEManagedOsmWay fetchOrCreateWithOsmID:ID];
    }
    else if ([typeString isEqualToString:kOPEOsmElementRelation]) {
        element = [OPEManagedOsmRelation fetchOrCreateWithOsmID:ID];
    }
    return element;
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

@end
