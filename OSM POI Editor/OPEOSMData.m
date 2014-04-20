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
#import "OPEAPIConstants.h"
#import "OPEConstants.h"
#import "OPEOsmNode.h"
#import "OPEOsmTag.h"
#import "OPEOsmWay.h"
#import "OPEOsmRelation.h"
#import "OPEChangeset.h"

#import "OPEUtility.h"
#import "OPEGeoCentroid.h"
#import "OPEOsmRelationMember.h"
#import "OPEReferenceOptional.h"
#import "OPEReferenceOptional.h"

#import "OSMParser.h"
#import "OSMParserHandlerDefault.h"
#import "OSMNote.h"
#import "OSMComment.h"

#import "OPELog.h"

#import "FMDatabase.h"
#import "OPEDatabaseManager.h"

@interface OPEOSMData ()


@property (nonatomic, strong) NSMutableDictionary * typeDictionary;
@property (nonatomic, strong) OPEOSMAPIManager * apiManager;
@property (nonatomic) dispatch_queue_t workQueue;

@end


@implementation OPEOSMData

-(id) init
{
    self = [super init];
    if(self)
    {
        self.apiManager = [[OPEOSMAPIManager alloc] init];
        NSString * queueLabel = [NSString stringWithFormat:@"%@.work.%@",[self class],self];
        self.workQueue = dispatch_queue_create([queueLabel UTF8String], 0);
    }
    
    return self;
}

-(FMDatabaseQueue *)databaseQueue
{
    if (!_databaseQueue) {
        _databaseQueue = [OPEDatabaseManager defaultDatabaseQueue];
    }
    return _databaseQueue;
}

-(OSMNote *)createNoteWithJSONDictionary:(NSDictionary *)noteDictionary
{
    NSDictionary * propertiesDictionary = noteDictionary[@"properties"];
    OSMNote * note = [[OSMNote alloc] init];
    note.id = [propertiesDictionary[@"id"] longLongValue];
    note.coordinate = CLLocationCoordinate2DMake([noteDictionary[@"geometry"][@"coordinates"][1] doubleValue], [noteDictionary[@"geometry"][@"coordinates"][0] doubleValue]);
    note.id = [propertiesDictionary[@"id"] longLongValue];
    NSString * statusString = (NSString *)propertiesDictionary[@"status"];
    note.isOpen = [statusString isEqualToString:@"open"];
    note.dateCreated = [OPEUtility noteDateFromString:(NSString *)propertiesDictionary[@"date_created"]];
    note.dateClosed = [OPEUtility noteDateFromString:(NSString *)propertiesDictionary[@"closed_at"]];
    __block NSMutableArray * newComments = [NSMutableArray array];
    NSArray * comments = (NSArray *)propertiesDictionary[@"comments"];
    [comments enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSDictionary * commentDictionary = (NSDictionary *)obj;
        OSMComment * comment = [[OSMComment alloc] init];
        NSString * username = commentDictionary[@"user"];
        if ([username length]) {
            comment.username = username;
            comment.userID = [commentDictionary[@"uid"] longLongValue];
        }
        comment.text = commentDictionary[@"text"];
        comment.date = [OPEUtility noteDateFromString:commentDictionary[@"date"]];
        comment.action = commentDictionary[@"action"];
        [newComments addObject:comment];
        
    }];
    note.commentsArray = newComments;
    return note;
}

- (NSString *)changesetCommentfor:(OPEOsmElement *)element
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

-(BOOL)isNoNameStreet:(OPEOsmWay *)way
{
    __block BOOL result = NO;
    if ([way.element.tags count]) {
        if ([[OPEConstants highwayTypesArray] containsObject:[way.element.tags objectForKey:@"highway"]] && ![way.element.tags objectForKey:@"name"]) {
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

-(void)findType:(NSArray *)elements completion:(void (^)(NSArray * foundElements))completion
{
    if(!elements.count)
    {
        if (completion) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(nil);
            });
        }
        return;
    }
    
    dispatch_async(self.workQueue, ^{
        __block NSMutableArray * foundElements = [NSMutableArray array];
        [self.databaseQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
            
            [elements enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                OPEOsmElement * element = obj;
                if (![obj isKindOfClass:[OPEOsmElement class]]) {
                    element = [OPEOsmElement elementWithBasicOsmElement:obj];
                }
                
                NSString * baseTableName = [OSMDatabaseManager tableName:element.element];
                
                
                
                NSString * tagsTable = [NSString stringWithFormat:@"%@_tags",baseTableName];
                NSString * columnID = [NSString stringWithFormat:@"%@_id",[baseTableName substringToIndex:[baseTableName length] - 1]];
                if (tagsTable && columnID && [element.element.tags count]) {
                    
                    NSString * sql =  [NSString stringWithFormat:@"SELECT poi_id FROM (SELECT D.poi_id,%@ FROM (SELECT poi_id,%@,is_legacy,COUNT(*) AS count FROM (SELECT poi_id,%@ FROM pois_tags NATURAL JOIN %@) AS A JOIN poi AS B ON A.poi_id = B.rowid AND A.%@ = %lld GROUP BY poi_id ORDER BY is_legacy ASC) AS C, (SELECT poi_id,COUNT(*)AS count FROM pois_tags GROUP BY poi_id) AS D WHERE C.poi_id = D.poi_id AND C.count = D.count) LIMIT 1",columnID,columnID,columnID,tagsTable,columnID,element.element.elementID];
                    FMResultSet * result = [db executeQuery:sql];
                    
                    if([result next]) {
                        int poi_id  = [result intForColumn:@"poi_id"];
                        element.typeID = poi_id;
                        sql = [NSString stringWithFormat:@"UPDATE %@ SET poi_id=%d WHERE id=%lld",baseTableName,poi_id,element.element.elementID];
                        [db executeUpdate:sql];
                        [foundElements addObject:element];
                    }
                    [result close];
                }
            }];
        }];
        if (completion) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(foundElements);
            });
        }
    });
}

-(void)updateLegacyTags:(OPEOsmElement *)element
{
    if (element.type.isLegacy) {
        NSString * baseName = [element.type.name stringByReplacingOccurrencesOfString:@" (legacy)" withString:@""];
        OPEReferencePoi * newPoi = [self getTypeWithName:baseName];
        //[element.element.tags addEntriesFromDictionary:newPoi.tags];
        element.type = nil;
        [self setNewType:newPoi forElement:element];
    }
}
-(OPEReferencePoi *)getTypeWithName:(NSString *)name;
{
    __block OPEReferencePoi * poi = nil;
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        db.logsErrors = OPELogDatabaseErrors;
        db.traceExecution = OPETraceDatabaseTraceExecution;
        FMResultSet * set = [db executeQuery:@"SELECT rowid as id,* FROM poi WHERE displayName = ?",name];
        
        while ([set next]) {
            poi = [[OPEReferencePoi alloc] initWithSqliteResultDictionary:[set resultDict]];
        }
        
        set = [db executeQuery:@"SELECT * FROM pois_tags WHERE poi_id = ?",poi.rowID];
        
        while ([set next]) {
            [poi.tags setObject:[set stringForColumn:@"value"] forKey:[set stringForColumn:@"key"]];
        }
        
    }];
    return poi;
    
}

-(void)setNewTypeRow:(NSInteger)rowId forElement:(OPEOsmElement *)element
{
    if (rowId) {
        [self.databaseQueue inDatabase:^(FMDatabase *db) {
            [db executeUpdate:@"UPDATE %@ SET poi_id = ? WHERE id = ?",[OSMDatabaseManager tableName:element.element],rowId,element.element.elementID];
        }];
    }
    
}

-(void)setNewType:(OPEReferencePoi *)type forElement:(OPEOsmElement *)element
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
-(void)removeOsmKey:(NSString *)osmKey forElement:(OPEOsmElement *)element
{
    [element.element.tags removeObjectForKey:osmKey];
}
-(void)setOsmKey:(NSString *)osmKey andValue:(NSString *)osmValue forElement:(OPEOsmElement *)element
{
    if ([osmValue length] && [osmKey length]) {
        [element.element.tags setObject:osmValue forKey:osmKey];
    }
    else if(osmKey){
        [self removeOsmKey:osmKey forElement:element];
    }
}
-(void)removeType:(OPEReferencePoi *)type forElement:(OPEOsmElement *)element
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
-(void)getTypeFor:(OPEOsmElement *)element
{
    if (element.typeID) {
        __block OPEReferencePoi * poi = [self.typeDictionary objectForKey:[NSNumber numberWithInt:element.typeID]];
        if (!poi) {
            [self.databaseQueue inDatabase:^(FMDatabase *db) {
                FMResultSet * result = [db executeQuery:@"SELECT *,rowid AS id FROM poi WHERE rowid = ?",[NSNumber numberWithInt:element.typeID]];
                if ([result next]) {
                    poi = [[OPEReferencePoi alloc] initWithSqliteResultDictionary:[result resultDict]];
                }
                [result close];
            }];
        }
        [self.typeDictionary setObject:poi forKey:[NSNumber numberWithInt:element.typeID]];
        element.type = poi;
        
        
    }
}
-(NSString *)nameForElement:(OPEOsmElement *)element
{
    __block NSString * name = [element valueForOsmKey:@"name"];
    if ([name length]) {
        return name;
    }
    
    if ([element isKindOfClass:[OPEOsmWay class]]) {
        if(((OPEOsmWay *)element).isNoNameStreet)
        {
            return @"No Name Street";
        }
    }
    
    
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        NSString * baseTableName = [OSMDatabaseManager tableName:element.element];
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
-(NSArray *)pointsForWay:(OPEOsmWay *)way
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

-(NSArray *)relationMembersFor:(OPEOsmRelation *)relation
{
    __block NSMutableArray * membersArray = [NSMutableArray array];
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        FMResultSet * set = [db executeQuery:@"select * from relations_members where relation_id = ?",[NSNumber numberWithLongLong:relation.elementID]];
        while ([set next]) {
            OPEOsmRelationMember * member = [[OPEOsmRelationMember alloc] initWithDictionary:[set resultDict]];
            [membersArray addObject:member];
        }
    }];
    
    for (OPEOsmRelationMember * member in membersArray)
    {
        member.element = [self elementOfKind:member.type osmID:member.ref];
    }
    
    return membersArray;
    
}

-(BOOL)isArea:(OPEOsmElement *)element
{
    if (![element isKindOfClass:[OPEOsmNode class]]) {
        [self getTagsForElement:element];
        if ([[element.element.tags objectForKey:@"area"] isEqualToString:@"yes"] || [[element.element.tags objectForKey:@"type"] isEqualToString:@"multipolygon"]) {
            return YES;
        }
        
        if ([element isKindOfClass:[OPEOsmWay class]]) {
            OPEOsmWay * way = (OPEOsmWay *)element;
            return [way.element isFirstNodeId:way.element.lastNodeId];
        }
        
        
        
    }
    return NO;
}

-(CLLocationCoordinate2D)centerForElement:(OPEOsmElement *)element
{
    CLLocationCoordinate2D center = CLLocationCoordinate2DMake(0, 0);
    if ([element.element isKindOfClass:[OSMNode class]]) {
        center = [((OPEOsmNode *)element).element coordinate];
    }
    else if ([element.element isKindOfClass:[OSMWay class]])
    {
        NSArray * array = [self pointsForWay:(OPEOsmWay* )element];
        if(!array.count)
        {
            DDLogError(@"Way with no points");
        }
        else {
            if (((OPEOsmWay *)element).isNoNameStreet) {
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
    }
    else if ([element.element isKindOfClass:[OSMRelation class]])
    {
        NSArray * membersArray = [self relationMembersFor:(OPEOsmRelation *)element];
        
        double centerLat=0.0;
        double centerLon=0.0;
        int num = 0;
        for(OPEOsmRelationMember * member in membersArray)
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
-(NSArray *)outerPolygonsForRelation:(OPEOsmRelation *)relation
{
    __block NSMutableArray * waysArray = [NSMutableArray array];
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        FMResultSet * set = [db executeQuery:@"select * from relations_members,ways where relation_id = ? AND type = 'way' AND role = 'outer' AND ref=id",[NSNumber numberWithLongLong:relation.elementID]];
        while ([set next]) {
            OPEOsmWay * way = [[OPEOsmWay alloc] initWithDictionary:[set resultDict]];
            [waysArray addObject:way];
        }
    }];
    
    NSMutableArray * resultsArray = [NSMutableArray array];
    
    for(OPEOsmWay * way in waysArray)
    {
        [resultsArray addObject:[self pointsForWay:way]];
    }
    return resultsArray;
    
}
-(NSArray *)innerPolygonsForRelation:(OPEOsmRelation *)relation
{
    __block NSMutableArray * waysArray = [NSMutableArray array];
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        FMResultSet * set = [db executeQuery:@"select * from relations_members,ways where relation_id = ? AND type = 'way' AND role = 'inner' AND ref=id",[NSNumber numberWithLongLong:relation.elementID]];
        while ([set next]) {
            OPEOsmWay * way = [[OPEOsmWay alloc] initWithDictionary:[set resultDict]];
            [waysArray addObject:way];
        }
    }];
    
    NSMutableArray * resultsArray = [NSMutableArray array];
    
    for(OPEOsmWay * way in waysArray)
    {
        [resultsArray addObject:[self pointsForWay:way]];
    }
    return resultsArray;
}
-(NSArray *)allMembersOfRelation:(OPEOsmRelation *)relation
{
    __block NSMutableArray * membersArray = [NSMutableArray array];
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        FMResultSet * set = [db executeQuery:@"select * from relations_members,ways where relation_id = ? AND ref=id",[NSNumber numberWithLongLong:relation.elementID]];
        while ([set next]) {
            if ([[[set resultDict] objectForKey:@"type"] isEqualToString:kOPEOsmElementNode]) {
                OPEOsmNode * node = [[OPEOsmNode alloc] initWithDictionary:[set resultDict]];
                [membersArray addObject:node];
            }
            else if ([[[set resultDict] objectForKey:@"type"] isEqualToString:kOPEOsmElementWay])
            {
                OPEOsmWay * way = [[OPEOsmWay alloc] initWithDictionary:[set resultDict]];
                [membersArray addObject:way];
            }
            else if ([[[set resultDict] objectForKey:@"type"] isEqualToString:kOPEOsmElementRelation])
            {
                OPEOsmRelation * relation = [[OPEOsmRelation alloc] initWithDictionary:[set resultDict]];
                [membersArray addObject:relation];
            }
            
        }
    }];
    return membersArray;
    
}
-(void)updateElement:(OPEOsmElement *)element
{
    [self.databaseQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        
        [db executeUpdate:[OSMDatabaseManager sqliteInsertOrReplaceString:element.element]];
        NSString * columnID = [NSString stringWithFormat:@"%@_id",[element.element.tableName substringToIndex:[element.element.tableName length] - 1]];
        NSString * deleteStatement = [NSString stringWithFormat:@"DELETE FROM %@ WHERE %@ = %lld",element.element.tagsTableName,columnID,element.elementID];
        [db executeUpdate:deleteStatement];
        NSArray * sqlArray = [OSMDatabaseManager sqliteInsertTagsString:element.element];
        for (NSString * sqlString in sqlArray)
        {
            [db executeUpdate:sqlString];
        }
        NSString * updatePOIStatement = [NSString stringWithFormat:@"UPDATE %@ SET poi_id = %d,isVisible = %d,action = \'%@\' WHERE id = %lld",element.element.tableName,element.typeID,element.isVisible,element.action,element.elementID];
        [db executeUpdate:updatePOIStatement];
    }];
}

-(OPEReferencePoi *)typeWithElement:(OPEOsmElement *)element withTags:(BOOL)withTags
{
    __block OPEReferencePoi * type = nil;
    if (element.typeID) {
        [self.databaseQueue inDatabase:^(FMDatabase *db) {
            FMResultSet * result = [db executeQueryWithFormat:@"SELECT * FROM poi WHERE rowid = %d",element.typeID];
            
            if ([result next]) {
                type = [[OPEReferencePoi alloc] initWithSqliteResultDictionary:[result resultDict]];
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

- (NSString *)nameWithElement: (OPEOsmElement *) element
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

-(NSString *)highwayTypeForOsmWay:(OPEOsmWay *)way
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

-(void)saveDate:(NSDate *)date forType:(OPEReferencePoi *)poi
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

-(OPEOsmElement *)elementOfKind:(NSString *)kind osmID:(int64_t)osmID
{
    __block OPEOsmElement * managedElement = nil;
    NSMutableString * sql = [NSMutableString stringWithFormat:@"SELECT * FROM %@s WHERE id=%lld",kind,osmID];
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        FMResultSet * set = [db executeQuery:sql];
        while ([set next]) {
            managedElement = [OPEOsmElement elementWithType:kind withDictionary:[set resultDict]];
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
            OPEOsmElement * managedElement = [OPEOsmElement elementWithType:kind withDictionary:[set resultDict]];
            [resultArray addObject:managedElement];
        }
    }];
    
    return  resultArray;
}

-(void)getTagsForElement:(OPEOsmElement *)element
{
    
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        NSString * baseTableName = [OSMDatabaseManager tableName:element.element];
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

-(void)getOptionalsFor:(OPEReferencePoi *)poi
{
    if (poi.rowID) {
        [self.databaseQueue inDatabase:^(FMDatabase *db) {
            db.logsErrors = OPELogDatabaseErrors;
            db.traceExecution = OPETraceDatabaseTraceExecution;
            FMResultSet * set = [db executeQueryWithFormat:@"select displayName,osmKey,type,sectionSortOrder,optional_section.name AS section,optional.rowid AS id from pois_optionals,optional,optional_section where optional_id = optional.rowid AND poi_id = %lld AND section_id = optional_section.rowid",poi.rowID];
            while([set next])
            {
                OPEReferenceOptional * optional = [[OPEReferenceOptional alloc] init];
                optional.displayName = [set stringForColumn:@"displayName"];
                optional.osmKey = [set stringForColumn:@"osmKey"];
                optional.type = [set intForColumn:@"type"];
                optional.sectionSortOrder = [set intForColumn:@"sectionSortOrder"];
                optional.sectionName = [set stringForColumn:@"section"];
                optional.rowID = [set intForColumn:@"id"];
                
                [poi.optionalsSet addObject:optional];
            }
            
        }];
        
        for (OPEReferenceOptional * optional in poi.optionalsSet)
        {
            if (optional.type == OPEOptionalTypeList) {
                [self getTagsForReferenceOptional:optional];
            }
            
        }
    }
}

-(void)getTagsForReferenceOptional:(OPEReferenceOptional *)optional
{
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        FMResultSet * set = [db executeQueryWithFormat:@"select * from optionals_tags where optional_id = %lld",optional.rowID];
        while ([set next]) {
            OPEReferenceOsmTag * tag = [[OPEReferenceOsmTag alloc] init];
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
        FMResultSet * set = [db executeQuery:@"SELECT *,poi.rowid AS id FROM poi,pois_tags WHERE  poi.rowid = pois_tags.poi_id AND category = ? ORDER BY display_name",category];
        OPEReferencePoi * poi = nil;
        poi.name = @"";
        while ([set next]) {
            if (![poi.name isEqualToString:[set stringForColumn:@"display_name"]]) {
                poi = [[OPEReferencePoi alloc] initWithSqliteResultDictionary:[set resultDict]];
                
                [array addObject: poi];
            }
            [poi.tags setObject:[set stringForColumn:@"value"] forKey:[set stringForColumn:@"key"]];
        }
        
    }];
    
    
    return array;
    
}
-(void)getTagsForType:(OPEReferencePoi *)poi
{
    __block OPEReferencePoi * blockPoi = poi;
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        db.logsErrors = OPELogDatabaseErrors;
        db.traceExecution = OPETraceDatabaseTraceExecution;
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
        NSString * sqlString = @"SELECT *,poi.rowid AS id FROM poi,pois_tags WHERE  poi.rowid = pois_tags.poi_id AND edit_only=0 GROUP BY id ORDER BY display_name";
        if (!includeLegacy) {
            sqlString = [sqlString stringByAppendingFormat:@" AND is_legacy = 0"];
        }
        
        FMResultSet * set = [db executeQuery:sqlString];
        OPEReferencePoi * poi = nil;
        poi.name = @"";
        while ([set next]) {
            poi = [[OPEReferencePoi alloc] initWithSqliteResultDictionary:[set resultDict]];
            
            [array addObject: poi];
        }
        
    }];
    return array;
}

-(void)getMetaDataForType:(OPEReferencePoi *)poi
{
    __block OPEReferencePoi * newPOI;
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        db.logsErrors = OPELogDatabaseErrors;
        db.traceExecution = OPETraceDatabaseTraceExecution;
        FMResultSet * set = [db executeQuery:@"SELECT *,poi.rowid AS id FROM poi WHERE id = ?",[NSNumber numberWithLongLong:poi.rowID]];
        while ([set next]) {
            newPOI = [[OPEReferencePoi alloc] initWithSqliteResultDictionary:[set resultDict]];
        }
    }];
    [self getTagsForType:newPOI];
    poi=newPOI;
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
-(BOOL)hasParentElement:(OPEOsmElement *)element
{
    __block BOOL hasParent = YES;
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        BOOL hasWayParent = NO;
        BOOL hasRelationParent = NO;
        if ([element isKindOfClass:[OPEOsmNode class]]) {
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
    for (OPEOsmElement * element in elementsArray)
    {
        [self updateElement:element];
    }
}

@end
