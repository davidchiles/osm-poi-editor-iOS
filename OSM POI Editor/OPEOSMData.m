//
//  OSMData.m
//  OSM POI Editor
//
//  Created by David Chiles on 2/3/12.
//  Copyright (c) 2011 David Chiles. All rights reserved.
//
//  This file is part of POI+.
//
//  POI+ is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  POI+ is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with POI+.  If not, see <http://www.gnu.org/licenses/>.

#import "OPEOSMData.h"
#import "TBXML.h"
#import "GTMOAuthViewControllerTouch.h"
#import "OPEAPIConstants.h"
#import "OPEConstants.h"
#import "OPEManagedOsmNode.h"
#import "OPEManagedOsmTag.h"
#import "OPEManagedOsmWay.h"
#import "OPEManagedOsmRelation.h"
#import "OPEChangeset.h"
#import "OPEMRUtility.h"
#import "OPEUtility.h"
#import "OPEGeoCentroid.h"
#import "OpeManagedOsmRelationMember.h"
#import "OPEManagedReferenceOptional.h"
#import "OPEManagedReferenceOptional.h"

#import "OSMParser.h"
#import "OSMParserHandlerDefault.h"

@implementation OPEOSMData

@synthesize auth=_auth;
@synthesize delegate;
@synthesize databaseQueue = _databaseQueue;
@synthesize httpClient = _httpClient;


-(id) init
{
    self = [super init];
    if(self)
    {
        
        
        q = dispatch_queue_create("Parse.Queue", NULL);
        
        //NSString * baseUrl = @"http://api06.dev.openstreetmap.org/";
        
        typeDictionary      = [NSMutableDictionary dictionary];
        apiManager = [[OPEOSMAPIManager alloc] init];
        
        
        //[httpClient setAuthorizationHeaderWithToken:auth.token];
    }
    
    return self;
}

-(AFHTTPClient *)httpClient
{
    if (!_httpClient) {
        NSString * baseUrl = @"http://api.openstreetmap.org/api/0.6/";
        _httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:baseUrl]];
    }
    return _httpClient;
}

-(GTMOAuthAuthentication *)auth
{
    if(!_auth)
    {
        _auth = [OPEOSMData osmAuth];
        [self canAuth];
    }
    return _auth;
    
}

-(FMDatabaseQueue *)databaseQueue
{
    if (!_databaseQueue) {
        _databaseQueue = [FMDatabaseQueue databaseQueueWithPath:kDatabasePath];
    }
    return _databaseQueue;
}
 
-(void) getDataWithSW:(CLLocationCoordinate2D)southWest NE: (CLLocationCoordinate2D) northEast
{
    [apiManager getDataWithSW:southWest NE:northEast success:^(NSData *response) {
        if ([delegate respondsToSelector:@selector(didEndDownloading)]) {
            [delegate didEndDownloading];
        }
        dispatch_async(q,  ^{
            
            OSMParser* parser = [[OSMParser alloc] initWithOSMData:response];
            OSMParserHandlerDefault* handler = [[OSMParserHandlerDefault alloc] initWithOutputFilePath:kDatabasePath overrideIfExists:NO];
            parser.delegate=handler;
            handler.outputDao.delegate = self;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([delegate respondsToSelector:@selector(willStartParsing:)]) {
                    [delegate willStartParsing:nil];
                }
            });
            
            
            [parser parse];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([delegate respondsToSelector:@selector(didEndParsing)]) {
                    [delegate didEndParsing];
                }
            });
            
            NSLog(@"done Parsing");
        });

    } failure:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([delegate respondsToSelector:@selector(downloadFailed:)]) {
                [delegate downloadFailed:error];
            }
        });
    }];
}

-(BOOL) canAuth;
{
        BOOL didAuth = NO;
        BOOL canAuth = NO;
        if (_auth) {
                didAuth = [GTMOAuthViewControllerTouch authorizeFromKeychainForName:@"OSMPOIEditor" authentication:_auth];
                // if the auth object contains an access token, didAuth is now true
                canAuth = [_auth canAuthorize];
            }
        else {
                return NO;
            }
        return didAuth && canAuth;
    
    
}

- (NSString *)changesetCommentfor:(OPEManagedOsmElement *)element
{
    NSString * comment;
    if ([element.action isEqualToString:kActionTypeDelete]) {
        comment = [NSString stringWithFormat:@"Deleted POI: %@",[self nameForElement: element]];
    }
    else{
        if (element.element.elementID < 0) {
            comment = [NSString stringWithFormat:@"Created new POI: %@",[self nameForElement: element]];
        }
        else{
            comment = [NSString stringWithFormat:@"Updated POI: %@",[self nameForElement: element]];
        }
    }
    return comment;
}

-(BOOL)isNoNameStreet:(OPEManagedOsmWay *)way
{
    __block BOOL result = NO;
    if ([way.element.tags count]) {
        if ([highwayTypes containsObject:[way.element.tags objectForKey:@"highway"]] && ![way.element.tags objectForKey:@"name"]) {
            result = YES;
        }
        else
        {
            result = NO;
        }
    }
    else{
        
        [self.databaseQueue inDatabase:^(FMDatabase *db) {
            FMResultSet * resultSet = [db executeQuery:@"select * from (select * from (SELECT *,COUNT(*) AS count FROM (select * from ways_tags where key='highway' union select * from ways_tags where key='name') group by way_id) WHERE count< 2 AND key = 'highway' AND way_id=?) AS A join ways on A.way_id = id",[NSNumber numberWithLongLong:way.elementID]];
            
            while([resultSet next]) {
                result = YES;
            }
        }];
    }
    way.isNoNameStreet = result;
    return result;
    
}

-(BOOL)findType:(OPEManagedOsmElement *)element
{
    NSString * baseTableName = [OSMDAO tableName:element.element];
    NSString * tagsTable = [NSString stringWithFormat:@"%@_tags",baseTableName];
    NSString * columnID = [NSString stringWithFormat:@"%@_id",[baseTableName substringToIndex:[baseTableName length] - 1]];
    __block BOOL didFind = NO;
    if (tagsTable && columnID && [element.element.tags count]) {
        [self.databaseQueue inDatabase:^(FMDatabase *db) {
            
            NSString * sql =  [NSString stringWithFormat:@"SELECT poi_id FROM (SELECT D.poi_id,%@ FROM (SELECT poi_id,%@,isLegacy,COUNT(*) AS count FROM (SELECT poi_id,%@ FROM pois_tags NATURAL JOIN %@) AS A JOIN poi AS B ON A.poi_id = B.rowid AND A.%@ = %lld GROUP BY poi_id ORDER BY isLegacy ASC) AS C, (SELECT poi_id,COUNT(*)AS count FROM pois_tags GROUP BY poi_id) AS D WHERE C.poi_id = D.poi_id AND C.count = D.count) LIMIT 1",columnID,columnID,columnID,tagsTable,columnID,element.element.elementID];
            FMResultSet * result = [db executeQuery:sql];
            
            if ([result next]) {
                int poi_id  = [result intForColumn:@"poi_id"];
                element.typeID = poi_id;
                sql = [NSString stringWithFormat:@"UPDATE %@ SET poi_id=%d WHERE id=%lld",baseTableName,poi_id,element.element.elementID];
                [db executeUpdateWithFormat:sql];
                didFind = YES;
            }
            [result close];
            

        }];
    }
    return didFind;
}
-(void)updateLegacyTags:(OPEManagedOsmElement *)element
{
    if (element.type.isLegacy) {
        NSString * baseName = [element.type.name stringByReplacingOccurrencesOfString:@" (legacy)" withString:@""];
        OPEManagedReferencePoi * newPoi = [self getTypeWithName:baseName];
        [element.element.tags addEntriesFromDictionary:newPoi.tags];
    }
}
-(OPEManagedReferencePoi *)getTypeWithName:(NSString *)name;
{
    __block OPEManagedReferencePoi * poi = nil;
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        FMResultSet * set = [db executeQuery:@"SELECT * FROM poi WHERE displayName = ?",name];
        
        while (set) {
            poi = [[OPEManagedReferencePoi alloc] initWithSqliteResultDictionary:[set resultDictionary]];
        }
        
        set = [db executeQueryWithFormat:@"SELECT * FROM pois_tags WHERE poi_id = %d",poi.rowID];
        
        while (set) {
            [poi.tags setObject:[set stringForColumn:@"value"] forKey:[set stringForColumn:@"key"]];
        }
        
    }];
    return poi;
    
}

-(void)setNewTypeRow:(NSInteger)rowId forElement:(OPEManagedOsmElement *)element
{
    if (rowId) {
        [self.databaseQueue inDatabase:^(FMDatabase *db) {
            [db executeUpdateWithFormat:@"UPDATE %@ SET poi_id = %d WHERE id = %lld",[OSMDAO tableName:element.element],rowId,element.element.elementID];
        }];
    }
    
}

-(void)setNewType:(OPEManagedReferencePoi *)type forElement:(OPEManagedOsmElement *)element
{
    [self removeType:element.type forElement:element];
    element.typeID = type.rowID;
    element.type = type;
    if (![type.tags count]) {
        [self getTagsForType:type];
    }
    
    for (NSString * osmKey in type.tags)
    {
        [self setOsmKey:osmKey andValue:type.tags[osmKey] forElement:element];
    }
    
    
}
-(void)removeOsmKey:(NSString *)osmKey forElement:(OPEManagedOsmElement *)element
{
    [element.element.tags removeObjectForKey:osmKey];
}
-(void)setOsmKey:(NSString *)osmKey andValue:(NSString *)osmValue forElement:(OPEManagedOsmElement *)element
{
    if ([osmValue length] && [osmKey length]) {
        [element.element.tags setObject:osmValue forKey:osmKey];
    }
}
-(void)removeType:(OPEManagedReferencePoi *)type forElement:(OPEManagedOsmElement *)element
{
    if (![type.tags count]) {
        [self getTagsForType:type];
    }
    element.typeID = 0;
    for (NSString * osmKey in type.tags)
    {
        [self removeOsmKey:osmKey forElement:element];
    }
}
-(void)getTypeFor:(OPEManagedOsmElement *)element
{
    if (element.typeID) {
        __block OPEManagedReferencePoi * poi = [typeDictionary objectForKey:[NSNumber numberWithInt:element.typeID]];
        if (!poi) {
            [self.databaseQueue inDatabase:^(FMDatabase *db) {
                FMResultSet * result = [db executeQuery:@"SELECT *,rowid AS id FROM poi WHERE rowid = ?",[NSNumber numberWithInt:element.typeID]];
                if ([result next]) {
                    poi = [[OPEManagedReferencePoi alloc] initWithSqliteResultDictionary:[result resultDictionary]];
                }
                [result close];
            }];
        }
        [typeDictionary setObject:poi forKey:[NSNumber numberWithInt:element.typeID]];
        element.type = poi;

        
    }
}
-(NSString *)nameForElement:(OPEManagedOsmElement *)element
{
    __block NSString * name = [element valueForOsmKey:@"name"];
    if ([name length]) {
        return name;
    }
    
    if ([element isKindOfClass:[OPEManagedOsmWay class]]) {
        if(((OPEManagedOsmWay *)element).isNoNameStreet)
        {
            return @"No Name Street";
        }
    }
    
    
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        NSString * baseTableName = [OSMDAO tableName:element.element];
        NSString * tagsTable = [NSString stringWithFormat:@"%@_tags",baseTableName];
        NSString * columnID = [NSString stringWithFormat:@"%@_id",[baseTableName substringToIndex:[baseTableName length] - 1]];
        NSString * sqlString = [NSString stringWithFormat:@"SELECT value FROM %@ WHERE key = 'name' AND %@ = %lld",tagsTable,columnID,element.elementID];
        FMResultSet * set = [db executeQuery:sqlString];
        while ([set next]) {
            name = [set stringForColumn:@"value"];
            [element.element.tags setObject:name forKey:@"name"];
        }
    }];
    if (![name length]) {
        name = element.type.name;
    }
    return name;
}
-(NSArray *)pointsForWay:(OPEManagedOsmWay *)way
{
    __block NSMutableArray * resultsArray = [[way points] mutableCopy];
    if ([resultsArray count]) {
        return resultsArray;
    }
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        FMResultSet * set = [db executeQueryWithFormat:@"SELECT latitude,longitude FROM ways_nodes,nodes WHERE ways_nodes.way_id = %lld AND ways_nodes.node_id = nodes.id ORDER BY local_order ASC",way.elementID];
        while ([set next]) {
            [resultsArray addObject:[[CLLocation alloc] initWithLatitude:[set doubleForColumn:@"latitude"] longitude:[set doubleForColumn:@"longitude"]]];
        }
    }];
    way.points = resultsArray;
    return resultsArray;
}

-(NSArray *)relationMembersFor:(OPEManagedOsmRelation *)relation
{
    __block NSMutableArray * membersArray = [NSMutableArray array];
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        FMResultSet * set = [db executeQuery:@"select * from relations_members where relation_id = ?",[NSNumber numberWithLongLong:relation.elementID]];
        while ([set next]) {
            OpeManagedOsmRelationMember * member = [[OpeManagedOsmRelationMember alloc] initWithDictionary:[set resultDictionary]];
            [membersArray addObject:member];
        }
    }];
    
    for (OpeManagedOsmRelationMember * member in membersArray)
    {
        member.element = [self elementOfKind:member.type osmID:member.ref];
    }
    
    return membersArray;
    
}

-(BOOL)isArea:(OPEManagedOsmElement *)element
{
    if (![element isKindOfClass:[OPEManagedOsmNode class]]) {
        [self getTagsForElement:element];
        if ([[element.element.tags objectForKey:@"area"] isEqualToString:@"yes"] || [[element.element.tags objectForKey:@"type"] isEqualToString:@"multipolygon"]) {
            return YES;
        }

        if ([element isKindOfClass:[OPEManagedOsmWay class]]) {
            OPEManagedOsmWay * way = (OPEManagedOsmWay *)element;
            return [way.element isFirstNodeId:way.element.lastNodeId];
        }
        
        
        
    }
    return NO;
}

-(CLLocationCoordinate2D)centerForElement:(OPEManagedOsmElement *)element
{
    CLLocationCoordinate2D center = CLLocationCoordinate2DMake(0, 0);
    if ([element.element isKindOfClass:[Node class]]) {
        center = [((OPEManagedOsmNode *)element).element coordinate];
    }
    else if ([element.element isKindOfClass:[Way class]])
    {
        NSArray * array = [self pointsForWay:(OPEManagedOsmWay* )element];
        if (((OPEManagedOsmWay *)element).isNoNameStreet) {
            center = ((CLLocation *)array[0]).coordinate;
        }
        else if ([self isArea:element])
        {
            center = [[[OPEGeoCentroid alloc] init] centroidOfPolygon:array];
        }
        else{
            center = [OPEGeoCentroid centroidOfPolyline:array];
        }
        
        
        
    }
    else if ([element.element isKindOfClass:[Relation class]])
    {
        NSArray * membersArray = [self relationMembersFor:(OPEManagedOsmRelation *)element];
        
        double centerLat=0.0;
        double centerLon=0.0;
        int num = 0;
        for(OpeManagedOsmRelationMember * member in membersArray)
        {
            
            if (member.element) {
                num +=1;
                CLLocationCoordinate2D tempCenter = [self centerForElement:member.element];
                centerLat += tempCenter.latitude;
                centerLon += tempCenter.longitude;
            }
        }
        return CLLocationCoordinate2DMake(centerLat/num, centerLon/num);

        
        
    }
    return center;
}
-(NSArray *)outerPolygonsForRelation:(OPEManagedOsmRelation *)relation
{
    __block NSMutableArray * waysArray = [NSMutableArray array];
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        FMResultSet * set = [db executeQuery:@"select * from relations_members,ways where relation_id = ? AND type = 'way' AND role = 'outer' AND ref=id",[NSNumber numberWithLongLong:relation.elementID]];
        while ([set next]) {
            OPEManagedOsmWay * way = [[OPEManagedOsmWay alloc] initWithDictionary:[set resultDictionary]];
            [waysArray addObject:way];
        }
    }];
    
    NSMutableArray * resultsArray = [NSMutableArray array];
    
    for(OPEManagedOsmWay * way in waysArray)
    {
        [resultsArray addObject:[self pointsForWay:way]];
    }
    return resultsArray;
    
}
-(NSArray *)innerPolygonsForRelation:(OPEManagedOsmRelation *)relation
{
    __block NSMutableArray * waysArray = [NSMutableArray array];
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        FMResultSet * set = [db executeQuery:@"select * from relations_members,ways where relation_id = ? AND type = 'way' AND role = 'inner' AND ref=id",[NSNumber numberWithLongLong:relation.elementID]];
        while ([set next]) {
            OPEManagedOsmWay * way = [[OPEManagedOsmWay alloc] initWithDictionary:[set resultDictionary]];
            [waysArray addObject:way];
        }
    }];
    
    NSMutableArray * resultsArray = [NSMutableArray array];
    
    for(OPEManagedOsmWay * way in waysArray)
    {
        [resultsArray addObject:[self pointsForWay:way]];
    }
    return resultsArray;
}
-(NSArray *)allMembersOfRelation:(OPEManagedOsmRelation *)relation
{
    __block NSMutableArray * membersArray = [NSMutableArray array];
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        FMResultSet * set = [db executeQuery:@"select * from relations_members,ways where relation_id = ? AND ref=id",[NSNumber numberWithLongLong:relation.elementID]];
        while ([set next]) {
            if ([[[set resultDictionary] objectForKey:@"type"] isEqualToString:kOPEOsmElementNode]) {
                OPEManagedOsmNode * node = [[OPEManagedOsmNode alloc] initWithDictionary:[set resultDictionary]];
                [membersArray addObject:node];
            }
            else if ([[[set resultDictionary] objectForKey:@"type"] isEqualToString:kOPEOsmElementWay])
            {
                OPEManagedOsmWay * way = [[OPEManagedOsmWay alloc] initWithDictionary:[set resultDictionary]];
                [membersArray addObject:way];
            }
            else if ([[[set resultDictionary] objectForKey:@"type"] isEqualToString:kOPEOsmElementRelation])
            {
                OPEManagedOsmRelation * relation = [[OPEManagedOsmRelation alloc] initWithDictionary:[set resultDictionary]];
                [membersArray addObject:relation];
            }
            
        }
    }];
    return membersArray;
    
}
-(void)updateElement:(OPEManagedOsmElement *)element
{
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        [db beginTransaction];
        
        [db executeUpdate:[OSMDAO sqliteInsertOrReplaceString:element.element]];
        NSString * columnID = [NSString stringWithFormat:@"%@_id",[element.element.tableName substringToIndex:[element.element.tableName length] - 1]];
        NSString * deleteStatement = [NSString stringWithFormat:@"DELETE FROM %@ WHERE %@ = %lld",element.element.tagsTableName,columnID,element.elementID];
        [db executeUpdate:deleteStatement];
        NSArray * sqlArray = [OSMDAO sqliteInsertTagsString:element.element];
        for (NSString * sqlString in sqlArray)
        {
            [db executeUpdate:sqlString];
        }
        NSString * updatePOIStatement = [NSString stringWithFormat:@"UPDATE %@ SET poi_id = %d,isVisible = %d,action = \'%@\' WHERE id = %lld",element.element.tableName,element.typeID,element.isVisible,element.action,element.elementID];
        [db executeUpdateWithFormat:updatePOIStatement];
        [db commit];
        
    }];
}

-(OPEManagedReferencePoi *)typeWithElement:(OPEManagedOsmElement *)element withTags:(BOOL)withTags
{
    __block OPEManagedReferencePoi * type = nil;
    if (element.typeID) {
        [self.databaseQueue inDatabase:^(FMDatabase *db) {
            FMResultSet * result = [db executeQueryWithFormat:@"SELECT * FROM poi WHERE rowid = %d",element.typeID];
            
            if ([result next]) {
                type = [[OPEManagedReferencePoi alloc] initWithSqliteResultDictionary:[result resultDictionary]];
            }
            [result close];
            if (withTags) {
                result = [db executeQueryWithFormat:@"SELECT * FROM pois_tags WHERE poi_id = %d",element.typeID];
                NSMutableDictionary * tempTags = [NSMutableDictionary dictionary];
                while ([result next]) {
                    [tempTags setObject:[result stringForColumn:@"value"] forKey:[result stringForColumn:@"key"]];
                }
                type.tags = tempTags;
            }
        }];
    }
    element.type = type;
    return type;
}

- (NSString *)nameWithElement: (OPEManagedOsmElement *) element
{
    NSString * possibleName = [element valueForOsmKey:@"name"];
    if (!element.type) {
        [self typeWithElement:element withTags:NO];
    }
    
    if ([possibleName length]) {
        return possibleName;
    }
    else if (element.type)
    {
        return element.type.name;
    }
    else
    {
        return @"";
    }
}

-(NSString *)highwayTypeForOsmWay:(OPEManagedOsmWay *)way
{
    NSString * type = @"";
    if (![way.element.tags count]) {
        [self getTagsForElement:way];
    }
    NSString * highwayValue = way.element.tags[@"highway"];
    
    
    if ([highwayValue length]) {
        type = [[highwayValue stringByReplacingOccurrencesOfString:@"_" withString:@" "] capitalizedString];
    }
    
    return type;
}

-(void)saveDate:(NSDate *)date forType:(OPEManagedReferencePoi *)poi
{
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:@"insert or replace into poi_lastUsed(date,displayName) values(datetime('now','localtime'),?)",[poi refName]];
    }];
    
}

-(NSArray *)allElementsWithType:(BOOL)withType
{
    NSMutableArray * resultArray = [NSMutableArray array];
    
    [resultArray addObjectsFromArray:[self allElementsOfKind:kOPEOsmElementNode withType:YES]];
    [resultArray addObjectsFromArray:[self allElementsOfKind:kOPEOsmElementWay withType:YES]];
    [resultArray addObjectsFromArray:[self allElementsOfKind:kOPEOsmElementRelation withType:YES]];
    
    return resultArray;
}

-(OPEManagedOsmElement *)elementOfKind:(NSString *)kind osmID:(int64_t)osmID
{
    __block OPEManagedOsmElement * managedElement = nil;
    NSMutableString * sql = [NSMutableString stringWithFormat:@"SELECT * FROM %@s WHERE id=%lld",kind,osmID];
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        FMResultSet * set = [db executeQuery:sql];
        while ([set next]) {
            managedElement = [OPEManagedOsmElement elementWithType:kind withDictionary:[set resultDictionary]];
        }
    }];
    return managedElement;
}

-(NSArray *)allElementsOfKind:(NSString *)kind withType:(BOOL)withType
{
    __block NSMutableArray * resultArray = [NSMutableArray array];
    NSMutableString * sql = [NSMutableString stringWithFormat:@"SELECT * FROM %@s",kind];
    if (withType) {
        [sql appendFormat:@" WHERE poi_id > 0"];
    }
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        FMResultSet * set = [db executeQuery:sql];
        
        while ([set next]) {
            OPEManagedOsmElement * managedElement = [OPEManagedOsmElement elementWithType:kind withDictionary:[set resultDictionary]];
            [resultArray addObject:managedElement];
        }
    }];
    
    return  resultArray;
}

-(void)getTagsForElement:(OPEManagedOsmElement *)element
{
    
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        NSString * baseTableName = [OSMDAO tableName:element.element];
        NSString * tagsTable = [NSString stringWithFormat:@"%@_tags",baseTableName];
        NSString * columnID = [NSString stringWithFormat:@"%@_id",[baseTableName substringToIndex:[baseTableName length] - 1]];
        NSString * sqlString = [NSString stringWithFormat:@"select * from %@ where %@ = %lld",tagsTable,columnID,element.elementID];
        
        FMResultSet * set = [db executeQuery:sqlString];
        
        while ([set next]) {
            [self setOsmKey:[set stringForColumn:@"key"] andValue:[set stringForColumn:@"value"] forElement:element];
        }
    }];
    
}

-(NSDictionary *)optionalSectionSortOrder
{
    __block NSMutableDictionary * dictionary = [NSMutableDictionary dictionary];
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        FMResultSet * set = [db executeQuery:@"SELECT * FROM optional_section"];
        while ([set next]) {
            [dictionary setObject:[set objectForColumnName:@"sortOrder"] forKey:[set objectForColumnName:@"name"]];
        }
        
        
    }];
    
    
    return dictionary;
    
}

-(void)getOptionalsFor:(OPEManagedReferencePoi *)poi
{
    if (poi.rowID) {
        [self.databaseQueue inDatabase:^(FMDatabase *db) {
            db.logsErrors = YES;
            db.traceExecution = YES;
            FMResultSet * set = [db executeQueryWithFormat:@"select displayName,osmKey,type,sectionSortOrder,optional_section.name AS section,optional.rowid AS id from pois_optionals,optional,optional_section where optional_id = optional.rowid AND poi_id = %d AND section_id = optional_section.rowid",poi.rowID];
            while([set next])
            {
                OPEManagedReferenceOptional * optional = [[OPEManagedReferenceOptional alloc] init];
                optional.displayName = [set stringForColumn:@"displayName"];
                optional.osmKey = [set stringForColumn:@"osmKey"];
                optional.type = [set intForColumn:@"type"];
                optional.sectionSortOrder = [set intForColumn:@"sectionSortOrder"];
                optional.sectionName = [set stringForColumn:@"section"];
                optional.rowID = [set intForColumn:@"id"];
                
                [poi.optionalsSet addObject:optional];
            }
            
        }];
        
        for (OPEManagedReferenceOptional * optional in poi.optionalsSet)
        {
            if (optional.type == OPEOptionalTypeList) {
                [self getTagsFor:optional];
            }
            
        }
    }
}

-(void)getTagsFor:(OPEManagedReferenceOptional *)optional
{
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        FMResultSet * set = [db executeQueryWithFormat:@"select * from optionals_tags where optional_id = %d",optional.rowID];
        while ([set next]) {
            OPEManagedReferenceOsmTag * tag = [[OPEManagedReferenceOsmTag alloc] init];
            tag.name = [set stringForColumn:@"name"];
            tag.key = [set stringForColumn:@"key"];
            tag.value = [set stringForColumn:@"value"];
            [optional.optionalTags addObject:tag];
        }
        
    }];
    
}
-(NSArray *)allSortedCategories
{
    __block NSMutableArray * array = [NSMutableArray array];
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        NSString * sqlString = @"SELECT category FROM poi GROUP BY category ORDER BY category ASC";
        FMResultSet * set = [db executeQuery:sqlString];
        
        while ([set next]) {
            [array addObject:[set stringForColumn:@"category"]];
        }
        
    }];
    return array;
}
-(NSArray *)allSortedTypesWithCategory:(NSString *)category
{
    __block NSMutableArray * array = [NSMutableArray array];
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        FMResultSet * set = [db executeQuery:@"SELECT *,poi.rowid AS id FROM poi,pois_tags WHERE  poi.rowid = pois_tags.poi_id AND category = ? ORDER BY displayName",category];
        OPEManagedReferencePoi * poi = nil;
        poi.name = @"";
        while ([set next]) {
            if (![poi.name isEqualToString:[set stringForColumn:@"displayName"]]) {
                poi = [[OPEManagedReferencePoi alloc] initWithSqliteResultDictionary:[set resultDictionary]];
                
                [array addObject: poi];
            }
            [poi.tags setObject:[set stringForColumn:@"value"] forKey:[set stringForColumn:@"key"]];
        }
        
    }];
    
    
    return array;
    
}
-(void)getTagsForType:(OPEManagedReferencePoi *)poi
{
    __block OPEManagedReferencePoi * blockPoi = poi;
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        db.traceExecution = YES;
        db.logsErrors = YES;
        FMResultSet * set = [db executeQuery:@"SELECT * FROM pois_tags WHERE poi_id = ?",[NSNumber numberWithLongLong:blockPoi.rowID]];
        
        while ([set next]) {
            [blockPoi.tags setObject:[set stringForColumn:@"value"] forKey:[set stringForColumn:@"key"]];
        }
    }];
    
}

-(NSArray *)allTypesIncludeLegacy:(BOOL)includeLegacy
{
    __block NSMutableArray * array = [NSMutableArray array];
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        NSString * sqlString = @"SELECT *,poi.rowid AS id FROM poi,pois_tags WHERE  poi.rowid = pois_tags.poi_id AND editOnly=0";
        if (!includeLegacy) {
            sqlString = [sqlString stringByAppendingFormat:@" AND isLegacy = 0"];
        }
        
        FMResultSet * set = [db executeQuery:sqlString];
        OPEManagedReferencePoi * poi = nil;
        poi.name = @"";
        while ([set next]) {
            if (![poi.name isEqualToString:[set stringForColumn:@"displayName"]]) {
                poi = [[OPEManagedReferencePoi alloc] initWithSqliteResultDictionary:[set resultDictionary]];
                
                [array addObject: poi];
            }
            [poi.tags setObject:[set stringForColumn:@"value"] forKey:[set stringForColumn:@"key"]];
        }
        
    }];
    
    
    return array;
    
    
}

-(int64_t)newElementId
{
    __block int64_t newID = -1;
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        FMResultSet * set = [db executeQuery:@"SELECT MIN(id) as min from nodes"];
        
        while ([set next]) {
            if ([set longLongIntForColumn:@"min"] < 0) {
                newID = [set longLongIntForColumn:@"min"]-1;
            }
        }
    }];
    
    return newID;
}
-(BOOL)hasParentElement:(OPEManagedOsmElement *)element
{
    __block BOOL hasParent = YES;
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        db.logsErrors = YES;
        db.traceExecution = YES;
        BOOL hasWayParent = NO;
        BOOL hasRelationParent = NO;
        if ([element isKindOfClass:[OPEManagedOsmNode class]]) {
            FMResultSet * set = [db executeQuery:@"SELECT EXISTS(SELECT * FROM ways_nodes WHERE node_id= ? LIMIT 1)",[NSNumber numberWithLongLong: element.elementID]];
            while ([set next]) {
                hasWayParent = [set boolForColumnIndex:0];
            }
        }
        
        FMResultSet * set = [db executeQuery:@"SELECT EXISTS(SELECT * FROM relations_members WHERE ref= ? AND type =? LIMIT 1)",[NSNumber numberWithLongLong: element.elementID],[element osmType]];
        while ([set next]) {
            hasRelationParent = [set boolForColumnIndex:0];
        }
        
        hasParent = hasWayParent && hasRelationParent;
    }];
    return hasParent;
}

-(void)updateElements:(NSArray *)elementsArray
{
    for (OPEManagedOsmElement * element in elementsArray)
    {
        [self updateElement:element];
    }
}

//OSMDAODelegate Mehtod
-(void)didFinishSavingNewElements:(NSArray *)newElements updatedElements:(NSArray *)updatedElements
{
    NSMutableArray * newMatchedElements = [NSMutableArray array];
    NSMutableArray * updatedMatchedElements = [NSMutableArray array];
    
    BOOL showNoNameStreets = [[OPEUtility currentValueForSettingKey:kShowNoNameStreetsKey] boolValue];
    
    //match new elements
    for(Element * element in newElements)
    {
        if ([element.tags count]) {
            OPEManagedOsmElement * managedElement = [OPEManagedOsmElement elementWithBasicOsmElement:element];
            if([self findType:managedElement])
            {
                [newMatchedElements addObject: managedElement];
            }
            else if (showNoNameStreets && [managedElement isKindOfClass:[OPEManagedOsmWay class]]) {
                if([self isNoNameStreet:(OPEManagedOsmWay *)managedElement])
                {
                    [newMatchedElements addObject:managedElement];
                }
            }
        }
    }
    //match updated elements in case any tags have changed enough to change type
    for(Element * element in updatedElements)
    {
        if ([element.tags count]) {
            OPEManagedOsmElement * managedElement = [OPEManagedOsmElement elementWithBasicOsmElement:element];
            if([self findType:managedElement])
            {
                [updatedMatchedElements addObject: managedElement];
            }
            else if (showNoNameStreets && [managedElement isKindOfClass:[OPEManagedOsmWay class]]) {
                if([self isNoNameStreet:(OPEManagedOsmWay *)managedElement])
                {
                    [updatedMatchedElements addObject:managedElement];
                }
            }
        }
    }
    
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.delegate respondsToSelector:@selector(didFindNewElements:updatedElements:)]) {
            [self.delegate didFindNewElements:newMatchedElements updatedElements:updatedMatchedElements];
        }
    });
    
    
    
}



+(GTMOAuthAuthentication *)osmAuth {
    NSString *myConsumerKey = osmConsumerKey; //@"pJbuoc7SnpLG5DjVcvlmDtSZmugSDWMHHxr17wL3";    // pre-registered with service
    NSString *myConsumerSecret = osmConsumerSecret; //@"q5qdc9DvnZllHtoUNvZeI7iLuBtp1HebShbCE9Y1"; // pre-assigned by service
    
    GTMOAuthAuthentication *auth;
    auth = [[GTMOAuthAuthentication alloc] initWithSignatureMethod:kGTMOAuthSignatureMethodHMAC_SHA1
                                                       consumerKey:myConsumerKey
                                                        privateKey:myConsumerSecret];
    
    // setting the service name lets us inspect the auth object later to know
    // what service it is for
    auth.serviceProvider = @"OSMPOIEditor";
    
    return auth;
}

@end
