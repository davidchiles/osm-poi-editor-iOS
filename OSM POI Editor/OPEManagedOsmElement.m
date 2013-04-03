#import "OPEManagedOsmElement.h"
#import "OPEManagedReferencePoi.h"
#import "OPEUtility.h"
#import "OPEManagedOsmWay.h"
#import "OPEManagedOsmNode.h"
#import "OPEGeo.h"

#import "OPEManagedOsmTag.h"



@interface OPEManagedOsmElement ()

// Private interface goes here.

@end


@implementation OPEManagedOsmElement

-(CLLocationCoordinate2D)center
{
    return CLLocationCoordinate2DMake(0, 0);
}

-(NSString *)valueForOsmKey:(NSString *)osmKey
{
    NSPredicate * tagFilter = [NSPredicate predicateWithFormat:@"key == %@",osmKey];
    NSSet * filteredSet = [self.tags filteredSetUsingPredicate:tagFilter];
    if ([filteredSet count]) {
        OPEManagedOsmTag * tag = [filteredSet anyObject];
        return tag.value;
    }
    return @"";
}

-(NSString *)name
{
    NSString * possibleName = [self valueForOsmKey:@"name"];
    if ([possibleName length]) {
        return possibleName;
    }
    else if (self.type)
    {
        return self.type.name;
    }
    else
    {
        return @"";
    }
}
-(void)addKey:(NSString *)key value:(NSString *)value
{
    [self removeTagWithOsmKey:key];
    OPEManagedOsmTag * newTag = [OPEManagedOsmTag fetchOrCreateWithKey:key value:value];
    [self.tagsSet addObject:newTag];
}

-(NSString *)tagsXML
{
    NSMutableString * xml = [NSMutableString stringWithString:@""];
    for (OPEManagedOsmTag *tag in self.tags)
    {
        [xml appendFormat:@"<tag k=\"%@\" v=\"%@\"/>",tag.key,[OPEUtility addHTML:tag.value]];
    }
    return xml;
}

-(BOOL)findType
{
    if ([self.tags count]) {
        
        
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"(SUBQUERY(tags, $tag, $tag IN %@).@count == tags.@count)",self.tags];
        NSArray * matches = [OPEManagedReferencePoi MR_findAllSortedBy:OPEManagedReferencePoiAttributes.isLegacy ascending:NO withPredicate:predicate];
        if ([matches count]) {
            
            self.type =[matches lastObject];
            return YES;
        }
    }
    
    return NO;
    
}

-(void)removeTagWithOsmKey:(NSString *)osmKey
{
    NSPredicate * keyFilter = [NSPredicate predicateWithFormat:@"%K == %@",OPEManagedOsmTagAttributes.key,osmKey];
    NSSet * removeSet = [self.tags filteredSetUsingPredicate:keyFilter];
    [self.tagsSet minusSet:removeSet];
}

-(void)newType:(OPEManagedReferencePoi *)newType
{
    if (self.type) {
        [self.tagsSet minusSet:self.type.tags];
    }
    [self.tagsSet unionSet:newType.tags];
    self.type = newType;
}

-(NSString *)tagsDescription
{
    NSMutableString * string = [NSMutableString stringWithString:@""];
    for (OPEManagedOsmTag * tag in self.tags)
    {
        [string appendFormat:@"\n%@ = %@",tag.key,tag.value];
    }
    return string;
}

-(NSString *)description
{
    return [NSString stringWithFormat:@"%@ %@",[super description],[self tagsDescription]];
}

-(NSString *)osmType
{
    return OPEOsmElementNone;
}

+(NSInteger) minID
{
    NSFetchRequest * request = [OPEManagedOsmElement MR_requestAllSortedBy:OPEManagedOsmElementAttributes.osmID ascending:YES];
    request.fetchLimit = 1;
    
    NSArray * results = [OPEManagedOsmElement MR_executeFetchRequest:request];
    if ([results count]) {
        OPEManagedOsmElement * element = [results lastObject];
        if (element.osmIDValue < 0) {
            return  element.osmIDValue;
        }
    }
    return 0;
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
    
    return [OPEManagedOsmElement MR_findAllWithPredicate:predicate];
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
    for (NSInteger index = 0; index<[way.nodes count]-1; index++) {
        OPEManagedOsmNode * node1 = [way.nodes objectAtIndex:index];
        OPEManagedOsmNode * node2 = [way.nodes objectAtIndex:index+1];
        OPELineSegment line = [OPEGeo lineSegmentFromPoint:[node1 center] toPoint:[node2 center]];
        
        double tempDistance  =  [OPEGeo distanceFromlineSegment:line toPoint:[self center]];
        distance = MIN(distance, tempDistance);
        
        
    }
    return distance;
    
}

-(NSDictionary *)nearbyHighwayNames
{
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
}

-(void)updateLegacyTags
{
    if (self.type.isLegacyValue && self.type.newTagMethod) {
        OPEManagedReferencePoi * newType = self.type.newTagMethod;
        for (OPEManagedOsmTag * tag in newType.tags)
        {
            [self addKey:tag.key value:tag.value];
        }
        self.type = newType;
        
    }
    
    
}

+(OPEManagedOsmElement *)fetchOrCreatWayWithOsmID:(int64_t)ID
{
    Class class = self;
    
    OPEManagedOsmElement * element = [class MR_findFirstByAttribute:OPEManagedOsmElementAttributes.osmID withValue:[NSNumber numberWithLongLong:ID]];
    
    if (!element) {
        element = [class MR_createEntity];
        element.osmIDValue = ID;
    }
    
    return element;
    
}

@end
