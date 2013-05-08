//
//  OPEOSMSearchManager.m
//  OSM POI Editor
//
//  Created by David on 5/6/13.
//
//

#import "OPEOSMSearchManager.h"
#import "FMDatabase.h"
#import "OPEManagedOsmWay.h"
#import "Node.h"
#import "OPEGeo.h"

@implementation OPEOSMSearchManager

-(id)init
{
    if(self = [super init])
    {
        databaseQueue = [FMDatabaseQueue databaseQueueWithPath:kDatabasePath];
        osmData = [[OPEOSMData alloc] init];
        
    }
    return self;
}

-(NSDictionary *)nearbyValuesForElement:(OPEManagedOsmElement *)element withOsmKey:(NSString *)osmKey
{
    currentElement = element;
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

-(NSSet *)uniqueValuesForOsmKeys:(NSSet *)osmKeys
{
    __block NSMutableSet * resultsSet = [NSMutableSet set];
    [databaseQueue inDatabase:^(FMDatabase *db) {
        db.traceExecution = YES;
        db.logsErrors = YES;
        
        NSString * keysString = [[osmKeys allObjects] componentsJoinedByString:@"\',\'"];
        NSString * sql = [NSString stringWithFormat:@"SELECT key,value FROM ways_tags WHERE key in (\'%@\')  UNION SELECT key,value FROM nodes_tags WHERE key in (\'%@\') UNION SELECT key,value FROM relations_tags WHERE key in (\'%@\')",keysString,keysString,keysString];
        
        FMResultSet * set = [db executeQuery:sql];
        while ([set next]) {
            [resultsSet addObject:[set stringForColumn:@"value"]];
        }
    }];
    return resultsSet;
}

-(NSDictionary *)nearbyCities
{
    NSSet *values = [self uniqueValuesForOsmKeys:[NSSet setWithArray:@[@"addr:city"]]];
    
    NSMutableSet * cityNames = [NSMutableSet set];
    
    [databaseQueue inDatabase:^(FMDatabase *db) {
        FMResultSet * resultSet = [db executeQuery:@"select * from (select * from (SELECT *,COUNT(*) AS count FROM (select * from nodes_tags where key='place' AND value in ('city','village','hamlet','town') union select * from nodes_tags where key='name') group by node_id) WHERE count= 2) AS A join nodes on A.node_id = id"];
        while ([resultSet next]) {
            [cityNames addObject:[resultSet stringForColumn:@"value"]];
        }
    }];
    
    [cityNames unionSet:values];
    
    NSNumber * num = [NSNumber numberWithInt:-1];
    NSMutableDictionary * dictionary = [NSMutableDictionary dictionary];
    for (NSString * name in cityNames)
    {
        [dictionary setObject:num forKey:name];
    }
    
    return dictionary;
}
-(NSDictionary *)nearbyStates
{
    NSSet *values = [self uniqueValuesForOsmKeys:[NSSet setWithArray:@[@"addr:state"]]];
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
    NSSet *values = [self uniqueValuesForOsmKeys:[NSSet setWithArray:@[@"addr:province"]]];
    
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
    NSSet *values = [self uniqueValuesForOsmKeys:[NSSet setWithArray:@[@"addr:postcode",@"tiger:zip_left",@"tiger:zip_right"]]];
    
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
    NSArray * points = [osmData pointsForWay:way];
    CLLocationCoordinate2D currentCenter = [osmData centerForElement:currentElement];
    
    for (NSInteger index = 0; index<[points count]-1; index++) {
        CLLocation * node1 = ((CLLocation *)[points objectAtIndex:index]);
        CLLocation * node2 = ((CLLocation *)[points objectAtIndex:index+1]);
        
        OPELineSegment line = [OPEGeo lineSegmentFromPoint:node1.coordinate toPoint:node2.coordinate];
        
        double tempDistance  =  [OPEGeo distanceFromlineSegment:line toPoint:currentCenter];
        distance = MIN(distance, tempDistance);
        
        
    }
    return distance;
    
}

-(NSDictionary *)nearbyHighwayNames
{
    __block NSMutableArray * namedHighways = [NSMutableArray array];
    [databaseQueue inDatabase:^(FMDatabase *db) {
        
        FMResultSet * resultSet = [db executeQuery:@"select * from (select * from (SELECT *,COUNT(*) AS count FROM (select * from ways_tags where key='highway' union select * from ways_tags where key='name') group by way_id) WHERE count= 2) AS A join ways on A.way_id = id"];
        
        while ([resultSet next]) {
            OPEManagedOsmWay * way = [[OPEManagedOsmWay alloc] initWithDictionary:[resultSet resultDictionary]];
            [way.element.tags setObject:[resultSet stringForColumn:@"value"] forKey:[resultSet stringForColumn:@"key"]];
            
            [namedHighways addObject:way];
        }
    }];
     
     NSMutableDictionary * highwayDictionary = [NSMutableDictionary dictionary];
     
     for (OPEManagedOsmWay * way in namedHighways)
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

-(NSArray *)noNameHighways
{
    NSMutableArray * resultArray = [NSMutableArray array];
    [databaseQueue inDatabase:^(FMDatabase *db) {
        FMResultSet * resultSet = [db executeQuery:@"select * from (select * from (SELECT *,COUNT(*) AS count FROM (select * from ways_tags where key='highway' union select * from ways_tags where key='name') group by way_id) WHERE count< 2 AND key = 'highway') AS A join ways on A.way_id = id"];
        
        while ([resultSet next]) {
            OPEManagedOsmWay * way = [[OPEManagedOsmWay alloc] initWithDictionary:[resultSet resultDictionary]];
            [resultArray addObject:way];
        }
    }];
    return resultArray;
}


+(NSDictionary *)nearbyValuesForElement:(OPEManagedOsmElement *)element withOsmKey:(NSString *)osmKey
{
    return [[[OPEOSMSearchManager alloc] init] nearbyValuesForElement:element withOsmKey:osmKey];
}


@end
