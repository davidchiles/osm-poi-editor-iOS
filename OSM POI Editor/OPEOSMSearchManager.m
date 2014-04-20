//
//  OPEOSMSearchManager.m
//  OSM POI Editor
//
//  Created by David on 5/6/13.
//
//

#import "OPEOSMSearchManager.h"
#import "FMDatabase.h"
#import "OPEOsmWay.h"
#import "OPEOsmNode.h"
#import "OPEOsmRelation.h"
#import "OSMNode.h"
#import "OPEGeo.h"
#import "OPELog.h"
#import "OPEDatabaseManager.h"

@implementation OPEOSMSearchManager

-(id)init
{
    if(self = [super init])
    {
        databaseQueue = [OPEDatabaseManager defaultDatabaseQueue];
        osmData = [[OPEOSMData alloc] init];
        
    }
    return self;
}

-(NSArray *)nearbyValuesForElement:(OPEOsmElement *)element withOsmKey:(NSString *)osmKey
{
    currentElement = element;
    CLLocationCoordinate2D coordinate = [osmData centerForElement:element];
    
    NSDictionary * values = nil;
    if ([osmKey isEqualToString:@"addr:street"]) {
        values = [self nearbyHighwayNamesToCoordinate:coordinate];
    }
    else if ([osmKey isEqualToString:@"addr:city"]) {
        values = [self nearbyCities];
    }
    else if ([osmKey isEqualToString:@"addr:state"])
    {
        return [self nearbyStatesToCoodrinate:coordinate];
    }
    else if ([osmKey isEqualToString:@"addr:province"])
    {
        return [self nearbyProvincesToCoodrdinate:coordinate];
    }
    else if ([osmKey isEqualToString:@"addr:postcode"])
    {
        return [self nearbyPostcodesToCoodrinate:coordinate];
    }
    NSMutableArray * array = [NSMutableArray array];
    for (NSString * key in values)
    {
        [array addObject:@{@"value": key,@"distance":[values objectForKey:key]}];
    }
    
    NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"distance"  ascending:YES];
    NSSortDescriptor *nameDescriptor = [[NSSortDescriptor alloc] initWithKey:@"value" ascending:YES];
    
    return [array sortedArrayUsingDescriptors:@[descriptor,nameDescriptor]];
}

-(NSSet *)uniqueValuesForOsmKeys:(NSSet *)osmKeys
{
    __block NSMutableSet * resultsSet = [NSMutableSet set];
    [databaseQueue inDatabase:^(FMDatabase *db) {
        db.logsErrors = OPELogDatabaseErrors;
        db.traceExecution = OPETraceDatabaseTraceExecution;
        
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
-(NSArray *)nearbyStatesToCoodrinate:(CLLocationCoordinate2D)coordinate
{
    NSDictionary * sortedResults = [self nearbyValuesForCoordinate:coordinate withOsmKey:@"addr:state"];
    
    __block NSMutableDictionary * dictionary = [NSMutableDictionary dictionary];
    [sortedResults enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        NSString * newKey = [(NSString * )key uppercaseString];
        if (!dictionary[newKey]) {
            [dictionary setObject:obj forKey:newKey];
        }
        else if((NSNumber *)obj < dictionary[newKey])
        {
            [dictionary setObject:obj forKey:newKey];
        }
    }];
    
    return [self sortNearbyValue:dictionary];
    
    
}
-(NSArray *)nearbyProvincesToCoodrdinate:(CLLocationCoordinate2D)coordinate
{
    return [self sortedNearbyValuesForCoordinate:coordinate withOsmKey:@"addr:province"];
}

-(NSArray *)nearbyPostcodesToCoodrinate:(CLLocationCoordinate2D)coordinate
{
    NSArray * tagsArray = @[@"addr:postcode",@"tiger:zip_left",@"tiger:zip_right"];
    __block NSDictionary * distanceDictionary = [NSMutableDictionary dictionary];
    
    [tagsArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSDictionary * newDistanceDictionary = [self nearbyValuesForCoordinate:coordinate withOsmKey:obj];
        distanceDictionary = [self combineDistanceDictionary:newDistanceDictionary withDictionary:distanceDictionary];
    }];
    
    return [self sortNearbyValue:distanceDictionary];
}

-(NSDictionary *)combineDistanceDictionary:(NSDictionary *)dictionary1 withDictionary:(NSDictionary *)dictionary2
{
    __block NSMutableDictionary * distanceDictioary = [NSMutableDictionary dictionaryWithDictionary:dictionary1];
    [dictionary2 enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if (!distanceDictioary[key]) {
            [distanceDictioary setObject:obj forKey:key];
        }
        else if([(NSNumber *)obj doubleValue] < [distanceDictioary[key] doubleValue])
        {
            [distanceDictioary setObject:obj forKey:key];
        }
    }];
    
    return distanceDictioary;

}

-(double)minDistinceToElement:(OPEOsmElement *)element fromCoordinate:(CLLocationCoordinate2D)fromCoordinate
{
    
    double minDistance = DBL_MAX;
    if ([element isKindOfClass:[OPEOsmNode class]]) {
        minDistance = [OPEGeo distance:fromCoordinate to:[osmData centerForElement:element]];
    }
    else if ([element isKindOfClass:[OPEOsmWay class]])
    {
        minDistance = [self minDistanceToWay:(OPEOsmWay *)element fromCoordinate:fromCoordinate];
    }
    else if ([element isKindOfClass:[OPEOsmRelation class]])
    {
        NSArray * members = [osmData allMembersOfRelation:(OPEOsmRelation *)element];
        for (OPEOsmElement * element in members)
        {
            double tempDistance = [self minDistinceToElement:element fromCoordinate:fromCoordinate];
            if (tempDistance < minDistance) {
                minDistance = tempDistance;
            }
            
        }
    }
    return minDistance;
    
}

-(double)minDistanceToWay:(OPEOsmWay *)way fromCoordinate:(CLLocationCoordinate2D)currentCenter
{
    double distance = DBL_MAX;
    NSArray * points = [osmData pointsForWay:way];
    
    for (NSInteger index = 0; index<[points count]-1; index++) {
        CLLocation * node1 = ((CLLocation *)[points objectAtIndex:index]);
        CLLocation * node2 = ((CLLocation *)[points objectAtIndex:index+1]);
        
        OPELineSegment line = [OPEGeo lineSegmentFromPoint:node1.coordinate toPoint:node2.coordinate];
        
        double tempDistance  =  [OPEGeo distanceFromlineSegment:line toPoint:currentCenter];
        distance = MIN(distance, tempDistance);
        
        
    }
    return distance;
    
}

-(NSDictionary *)nearbyHighwayNamesToCoordinate:(CLLocationCoordinate2D)coordinate
{
    __block NSMutableArray * namedHighways = [NSMutableArray array];
    [databaseQueue inDatabase:^(FMDatabase *db) {
        
        FMResultSet * resultSet = [db executeQuery:@"select * from (select * from (SELECT *,COUNT(*) AS count FROM (select * from ways_tags where key='highway' union select * from ways_tags where key='name') group by way_id) WHERE count= 2) AS A join ways on A.way_id = id"];
        
        while ([resultSet next]) {
            OPEOsmWay * way = [[OPEOsmWay alloc] initWithDictionary:[resultSet resultDict]];
            [way.element.tags setObject:[resultSet stringForColumn:@"value"] forKey:[resultSet stringForColumn:@"key"]];
            
            [namedHighways addObject:way];
        }
    }];
     
     NSMutableDictionary * highwayDictionary = [NSMutableDictionary dictionary];
     
     for (OPEOsmWay * way in namedHighways)
     {
         NSString * wayName = [way valueForOsmKey:@"name"];
         if ([wayName length]) {
            double wayDistance = [self minDistanceToWay:way fromCoordinate:coordinate];
     
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
            if ([[OPEConstants highwayTypesArray] containsObject:[resultSet stringForColumn:@"value"]]) {
                OPEOsmWay * way = [[OPEOsmWay alloc] initWithDictionary:[resultSet resultDict]];
                way.isNoNameStreet = YES;
                [resultArray addObject:way];
            }
            
        }
    }];
    return resultArray;
}

-(NSArray *)recentlyUsedPoisArrayWithLength:(NSInteger)length
{
    NSMutableArray * resultArray = [NSMutableArray array];
    [databaseQueue inDatabase:^(FMDatabase *db) {
        db.logsErrors = OPELogDatabaseErrors;
        db.traceExecution = OPETraceDatabaseTraceExecution;
        FMResultSet * resultsSet = [db executeQuery:@"SELECT *,poi.rowid AS id FROM poi NATURAL JOIN poi_lastUsed where date IS NOT NULL AND editOnly = 0 AND is_legacy = 0 order by datetime(date) DESC limit ?",[NSNumber numberWithInteger:length]];
        
        while ([resultsSet next]) {
            [resultArray addObject:[[OPEReferencePoi alloc] initWithSqliteResultDictionary:[resultsSet resultDict]]];
        }
    }];
    
    return resultArray;
}

-(NSDictionary *)localReverseGeocode:(CLLocationCoordinate2D)coordinate
{
    NSMutableDictionary * addressDictionary = [NSMutableDictionary dictionary];
    NSArray * sortedCities = [self sortedNearbyValuesForCoordinate:coordinate withOsmKey:@"addr:city"];
    if ([sortedCities count]) {
        [addressDictionary setObject:sortedCities[0][@"value"] forKey:@"city"];
    }
    
    NSDictionary * highwayWays = [self nearbyHighwayNamesToCoordinate:coordinate];
    NSDictionary * highwayNodes = [self nearbyValuesForCoordinate:coordinate withOsmKey:@"addr:street"];
    
    NSArray * sortedStreets = [self sortNearbyValue:[self combineDistanceDictionary:highwayWays withDictionary:highwayNodes]];
    if ([sortedStreets count]) {
        [addressDictionary setObject:sortedStreets[0][@"value"] forKey:@"road"];
    }
    
    
    return addressDictionary;
}

-(NSArray *)sortNearbyValue:(NSDictionary *)values
{
    NSMutableArray * array = [NSMutableArray array];
    [values enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [array addObject:@{@"value": key,@"distance":obj}];
    }];
    
    NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"distance"  ascending:YES];
    NSSortDescriptor *nameDescriptor = [[NSSortDescriptor alloc] initWithKey:@"value" ascending:YES];
    
    return [array sortedArrayUsingDescriptors:@[descriptor,nameDescriptor]];
}

-(NSArray *)sortedNearbyValuesForCoordinate:(CLLocationCoordinate2D)coordinate withOsmKey:(NSString *)osmKey
{
    NSDictionary * distanceDictionary = [self nearbyValuesForCoordinate:coordinate withOsmKey:osmKey];
    return [self sortNearbyValue:distanceDictionary];
}


-(NSDictionary *)nearbyValuesForCoordinate:(CLLocationCoordinate2D)coordinate withOsmKey:(NSString *)osmKey
{
    __block NSMutableDictionary * distanceDictionary = [NSMutableDictionary dictionary];
    for(NSString * osmType in @[kOPEOsmElementNode,kOPEOsmElementWay,kOPEOsmElementRelation])
    {
        [databaseQueue inDatabase:^(FMDatabase *db) {
            db.logsErrors = OPELogDatabaseErrors;
            db.traceExecution = OPETraceDatabaseTraceExecution;
            NSString * dbQuery = [NSString stringWithFormat:@"select * from (select key,value,%@_id as id from %@s_tags where %@s_tags.key='%@') as tags,%@s where tags.id = %@s.id",osmType,osmType,osmType,osmKey,osmType,osmType];
            FMResultSet * result = [db executeQuery:dbQuery];
            
            
            while ([result next]) {
                OPEOsmElement * element =nil;
                if ([osmType isEqualToString:kOPEOsmElementNode]) {
                    element = [[OPEOsmNode alloc] initWithDictionary:[result resultDict]];
                }
                else if ([osmType isEqualToString:kOPEOsmElementWay])
                {
                    element = [[OPEOsmWay alloc] initWithDictionary:[result resultDict]];
                }
                else if ([osmType isEqualToString:kOPEOsmElementRelation])
                {
                    element = [[OPEOsmRelation alloc] initWithDictionary:[result resultDict]];
                }
                double minDistance = [self minDistinceToElement:element fromCoordinate:coordinate];
                NSString * osmValue = [[result resultDict] objectForKey:@"value"];
                if (minDistance &&[distanceDictionary objectForKey:osmValue] && [[distanceDictionary objectForKey:osmValue] doubleValue] > minDistance) {
                    [distanceDictionary setObject:[NSNumber numberWithDouble:minDistance] forKey:osmValue];
                }
                else if (minDistance)
                {
                    [distanceDictionary setObject:[NSNumber numberWithDouble:minDistance] forKey:osmValue];
                }
            }
        }];
        
    }
    return distanceDictionary;
    
}

+(NSArray *)sortedNearbyValuesForElement:(OPEOsmElement *)element withOsmKey:(NSString *)osmKey
{
    return [[[OPEOSMSearchManager alloc] init] nearbyValuesForElement:element withOsmKey:osmKey];
}


@end
