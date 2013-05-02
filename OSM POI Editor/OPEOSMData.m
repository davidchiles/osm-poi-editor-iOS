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

@synthesize auth;
@synthesize delegate;
@synthesize databaseQueue = _databaseQueue;


-(id) init
{
    self = [super init];
    if(self)
    {
        auth = [OPEOSMData osmAuth];
        [self canAuth];
        
        q = dispatch_queue_create("Parse.Queue", NULL);
        
        //NSString * baseUrl = @"http://api06.dev.openstreetmap.org/";
        NSString * baseUrl = @"http://api.openstreetmap.org/api/0.6/";
        
        httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:baseUrl]];
        typeDictionary = [NSMutableDictionary dictionary];
        //[httpClient setAuthorizationHeaderWithToken:auth.token];
    }
    
    return self;
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
    double boxleft = southWest.longitude;
    double boxbottom = southWest.latitude;
    double boxright = northEast.longitude;
    double boxtop = northEast.latitude;
    
    NSURL* url = [NSURL URLWithString: [NSString stringWithFormat:@"%@[bbox=%f,%f,%f,%f][@meta]",kOPEAPIURL,boxleft,boxbottom,boxright,boxtop]];
    NSURLRequest * request =[NSURLRequest requestWithURL:url];
    
    [AFXMLRequestOperation addAcceptableContentTypes:[NSSet setWithObject:@"application/osm3s+xml"]];
    //dispatch_queue_t t = dispatch_queue_create(NULL, NULL);
    
    if ([delegate respondsToSelector:@selector(willStartDownloading)]) {
        [delegate willStartDownloading];
    }
    
    AFHTTPRequestOperation * httpRequestOperation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [httpRequestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([delegate respondsToSelector:@selector(didEndDownloading)]) {
            [delegate didEndDownloading];
        }
        
        dispatch_async(q,  ^{
            
            OSMParser* parser = [[OSMParser alloc] initWithOSMData:responseObject];
            OSMParserHandlerDefault* handler = [[OSMParserHandlerDefault alloc] initWithOutputFilePath:kDatabasePath overrideIfExists:NO];
            parser.delegate=handler;
            handler.outputDao.delegate = self;
            [parser parse];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([delegate respondsToSelector:@selector(didEndParsing)]) {
                    [delegate didEndParsing];
                }
            });
            
            NSLog(@"done Parsing");
        });
        //dispatch_release(t);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([delegate respondsToSelector:@selector(downloadFailed:)]) {
                [delegate downloadFailed:error];
            }
        });
    }];
    [httpRequestOperation start];
    
    NSLog(@"Download URL %@",url);
}

-(BOOL) canAuth;
{
        BOOL didAuth = NO;
        BOOL canAuth = NO;
        if (auth) {
                didAuth = [GTMOAuthViewControllerTouch authorizeFromKeychainForName:@"OSMPOIEditor" authentication:auth];
                // if the auth object contains an access token, didAuth is now true
                canAuth = [auth canAuthorize];
            }
        else {
                return NO;
            }
        return didAuth && canAuth;
    
    
}

-(void)uploadElement:(OPEManagedOsmElement *)element
{
    OPEChangeset * changeset = [[OPEChangeset alloc] init];
    [changeset addElement:element];
    
    if (element.element.elementID < 0) {
        changeset.message = [NSString stringWithFormat:@"Created new POI: %@",[self nameForElement: element]];
    }
    else{
        changeset.message = [NSString stringWithFormat:@"Updated POI: %@",[self nameForElement: element]];
    }
    
    
    [self openChangeset:changeset];
    
}
-(void)deleteElement:(OPEManagedOsmElement *)element
{
    OPEChangeset * changeset = [[OPEChangeset alloc] init];
    [changeset addElement:element];
    changeset.message = [NSString stringWithFormat:@"Deleted POI: %@",[self nameForElement: element]];
    
    [self openChangeset:changeset];
    
}

- (void) openChangeset:(OPEChangeset *)changeset
{    
    
    NSMutableString * changesetString = [[NSMutableString alloc] init];
    
    [changesetString appendString:@"<?xml version=\"1.0\" encoding=\"UTF-8\" ?>"];
    [changesetString appendString:@"<osm version=\"0.6\" generator=\"OSMPOIEditor\">"];
    [changesetString appendString:@"<changeset>"];
    [changesetString appendString:@"<tag k=\"created_by\" v=\"OSMPOIEditor\"/>"];
    [changesetString appendFormat:@"<tag k=\"comment\" v=\"%@\"/>",[OPEUtility addHTML:changeset.message]];
    [changesetString appendString:@"</changeset>"];
    [changesetString appendString:@"</osm>"];
    
    NSData * changesetData = [changesetString dataUsingEncoding:NSUTF8StringEncoding];
    
    NSLog(@"Changeset Data: %@",[[NSString alloc] initWithData:changesetData encoding:NSUTF8StringEncoding]);
    
     NSMutableURLRequest * urlRequest = [httpClient requestWithMethod:@"PUT" path:@"changeset/create" parameters:nil];
    [urlRequest setHTTPBody:changesetData];
    [auth authorizeRequest:urlRequest];
    
    
    AFHTTPRequestOperation * requestOperation = [[AFHTTPRequestOperation alloc] initWithRequest:urlRequest];
    [requestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id object){
        NSLog(@"changeset %@",object);
        changeset.changesetID = [[[NSString alloc] initWithData:object encoding:NSUTF8StringEncoding] longLongValue];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [delegate didOpenChangeset:changeset.changesetID withMessage:changeset.message];
        });
        
        
        [self uploadElements:changeset];
        
    }failure:^(AFHTTPRequestOperation *operation, NSError * error)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([delegate respondsToSelector:@selector(downloadFailed:)]) {
                [delegate downloadFailed:error];
            }
        });
        NSLog(@"Failed: %@",urlRequest.URL);
    }];
    [requestOperation start];
}

-(void)uploadElements:(OPEChangeset *)changeset
{
    if (!changeset.changesetID) {
        return;
    }
    NSMutableArray * requestOperations = [NSMutableArray array];
    NSArray * elements =  @[changeset.nodes,changeset.ways,changeset.relations];

    for( NSArray * elmentArray in elements)
    {
        for(OPEManagedOsmElement * element in elmentArray)
        {
            if([element.action isEqualToString:kActionTypeDelete])
            {
                [requestOperations addObject:[self deleteRequestOperationWithElement:element changeset:changeset.changesetID]];
            }
            else if([element.action isEqualToString:kActionTypeModify])
            {
                [requestOperations addObject:[self uploadRequestOperationWithElement:element changeset:changeset.changesetID]];
            }
        }
    }

    [httpClient enqueueBatchOfHTTPRequestOperations:requestOperations progressBlock:^(NSUInteger numberOfFinishedOperations, NSUInteger totalNumberOfOperations) {
        NSLog(@"uploaded: %d/%d",numberOfFinishedOperations,totalNumberOfOperations);
        
    } completionBlock:^(NSArray *operations) {
        [self closeChangeset:changeset.changesetID];
    }];
    
    
    
    
}
-(AFHTTPRequestOperation *)uploadRequestOperationWithElement: (OPEManagedOsmElement *) element changeset: (int64_t) changesetNumber
{
    NSData * xmlData = [element uploadXMLforChangset:changesetNumber];
    
    NSMutableString * path = [NSMutableString stringWithFormat:@"%@/",[element osmType]];
    int64_t elementOsmID = element.element.elementID;
    
    if (elementOsmID < 0) {
        [path appendString:@"create"];
    }
    else{
        [path appendFormat:@"%lld",element.element.elementID];
    }
    
    NSMutableURLRequest * urlRequest = [httpClient requestWithMethod:@"PUT" path:path parameters:nil];
    [urlRequest setHTTPBody:xmlData];
    [auth authorizeRequest:urlRequest];
    
    AFHTTPRequestOperation * requestOperation = [[AFHTTPRequestOperation alloc] initWithRequest:urlRequest];
    [requestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id object){
        NSLog(@"changeset %@",object);
        int64_t response = [[[NSString alloc] initWithData:object encoding:NSUTF8StringEncoding] longLongValue];
        
        if (elementOsmID < 0) {
            element.element.elementID = response;
            element.element.version = 1;
        }
        else{
            element.element.version = response;
        }
        
        
        [self updateElement:element];
        
        //[delegate uploadedElement:element.objectID newVersion:newVersion];
        
        
    }failure:^(AFHTTPRequestOperation *operation, NSError * error)
     {
         dispatch_async(dispatch_get_main_queue(), ^{
             if ([delegate respondsToSelector:@selector(uploadFailed:)]) {
                 [delegate uploadFailed:error];
             }
         });
         NSLog(@"Failed: %@",urlRequest.URL);
     }];
    return requestOperation;
    
}

-(AFHTTPRequestOperation *)deleteRequestOperationWithElement: (OPEManagedOsmElement *) element changeset: (int64_t) changesetNumber
{
    NSData * xmlData = [element deleteXMLforChangset:changesetNumber];
    NSString * path = [NSString stringWithFormat:@"%@/%lld",[element osmType],element.element.elementID];
    
    NSMutableURLRequest * urlRequest = [httpClient requestWithMethod:@"DELETE" path:path parameters:nil];
    [urlRequest setHTTPBody:xmlData];
    [auth authorizeRequest:urlRequest];
    
    AFHTTPRequestOperation * requestOperation = [[AFHTTPRequestOperation alloc] initWithRequest:urlRequest];
    [requestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id object){
        NSLog(@"changeset %@",object);
        NSInteger newVersion = [[[NSString alloc] initWithData:object encoding:NSUTF8StringEncoding] integerValue];
        
        element.element.version = newVersion;
        element.isVisible = NO;
        
        [self updateElement:element];
        
        //[delegate uploadedElement:element.objectID newVersion:newVersion];
        
        
    }failure:^(AFHTTPRequestOperation *operation, NSError * error)
     {
         dispatch_async(dispatch_get_main_queue(), ^{
             if ([delegate respondsToSelector:@selector(downloadFailed:)]) {
                 [delegate downloadFailed:error];
             }
         });
         NSLog(@"Failed: %@",urlRequest.URL);
     }];
    return requestOperation;

    
}

- (void) closeChangeset: (int64_t) changesetNumber
{
    NSString * path = [NSString stringWithFormat:@"changeset/%lld/close",changesetNumber];
    
    NSMutableURLRequest * urlRequest = [httpClient requestWithMethod:@"PUT" path:path parameters:nil];
    [auth authorizeRequest:urlRequest];
    
    AFHTTPRequestOperation * requestOperation = [[AFHTTPRequestOperation alloc] initWithRequest:urlRequest];
    [requestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id object){
        NSLog(@"changeset Closed");
        dispatch_async(dispatch_get_main_queue(), ^{
            [delegate didCloseChangeset:changesetNumber];
        });
        
        
    }failure:^(AFHTTPRequestOperation *operation, NSError * error)
     {
         dispatch_async(dispatch_get_main_queue(), ^{
             if ([delegate respondsToSelector:@selector(downloadFailed:)]) {
                 [delegate downloadFailed:error];
             }
         });
         NSLog(@"Failed: %@",urlRequest.URL);
     }];
    [requestOperation start];
    
}

-(BOOL)findType:(OPEManagedOsmElement *)element
{
    NSString * baseTableName = [OSMDAO tableName:element.element];
    NSString * tagsTable = [NSString stringWithFormat:@"%@_tags",baseTableName];
    NSString * columnID = [NSString stringWithFormat:@"%@_id",[baseTableName substringToIndex:[baseTableName length] - 1]];
    __block BOOL didFind = NO;
    if (tagsTable && columnID && [element.element.tags count]) {
        [self.databaseQueue inDatabase:^(FMDatabase *db) {
            if ([[element.element.tags objectForKey:@"bus"] isEqualToString:@"yes"]) {
                NSLog(@"bus stop");
            }
            
            NSString * sql =  [NSString stringWithFormat:@"SELECT poi_id FROM (SELECT D.poi_id,%@ FROM (SELECT poi_id,%@,isLegacy,COUNT(*) AS count FROM (SELECT poi_id,%@ FROM pois_tags NATURAL JOIN %@) AS A JOIN poi AS B ON A.poi_id = B.rowid AND A.%@ = %lld GROUP BY poi_id ORDER BY isLegacy ASC) AS C, (SELECT poi_id,COUNT(*)AS count FROM pois_tags GROUP BY poi_id) AS D WHERE C.poi_id = D.poi_id AND C.count = D.count) LIMIT 1",columnID,columnID,columnID,tagsTable,columnID,element.element.elementID];
            FMResultSet * result = [db executeQuery:sql];
            
            if ([result next]) {
                int poi_id  = [result intForColumn:@"poi_id"];
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
            BOOL result = [db executeUpdateWithFormat:@"UPDATE %@ SET poi_id = %d WHERE id = %lld",[OSMDAO tableName:element.element],rowId,element.element.elementID];
        }];
    }
    
}

-(void)setNewType:(OPEManagedReferencePoi *)type forElement:(OPEManagedOsmElement *)element
{
    [self removeType:element.type forElement:element];
    element.typeID = type.rowID;
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
    [element.element.tags setObject:osmValue forKey:osmKey];
    
}
-(void)removeType:(OPEManagedReferencePoi *)type forElement:(OPEManagedOsmElement *)element
{
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
                    poi.rowID = [result intForColumn:@"id"];
                    
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
    __block NSMutableArray * resultsArray = [NSMutableArray array];
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        FMResultSet * set = [db executeQueryWithFormat:@"SELECT latitude,longitude FROM ways_nodes,nodes WHERE ways_nodes.way_id = %lld AND ways_nodes.node_id = nodes.id ORDER BY local_order ASC",way.elementID];
        while ([set next]) {
            [resultsArray addObject:[[CLLocation alloc] initWithLatitude:[set doubleForColumn:@"latitude"] longitude:[set doubleForColumn:@"longitude"]]];
        }
    }];
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

-(CLLocationCoordinate2D)centerForElement:(OPEManagedOsmElement *)element
{
    CLLocationCoordinate2D center = CLLocationCoordinate2DMake(0, 0);
    if ([element isKindOfClass:[OPEManagedOsmNode class]]) {
        center = [((OPEManagedOsmNode *)element).element coordinate];
    }
    else if ([element isKindOfClass:[OPEManagedOsmWay class]])
    {
        NSArray * array = [self pointsForWay:(OPEManagedOsmWay* )element];
        center = [[[OPEGeoCentroid alloc] init] centroidOfPolygon:array];
        
    }
    else if ([element isKindOfClass:[OPEManagedOsmRelation class]])
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

-(void)updateElement:(OPEManagedOsmElement *)element
{
    if ([element isKindOfClass:[OPEManagedOsmNode class]]) {
        [self updateNode:(OPEManagedOsmNode *)element];
    }
    else if ([element isKindOfClass:[OPEManagedOsmWay class]]) {
        [self updateWay:(OPEManagedOsmWay *)element];
    }
    else if ([element isKindOfClass:[OPEManagedOsmRelation class]]) {
        [self updateRelation:(OPEManagedOsmRelation *)element];
    }
    
}

-(void)updateNode:(OPEManagedOsmNode *)node
{
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        
        [db executeUpdate:[OSMDAO sqliteInsertOrReplaceNodeString:node.element]];
        [db executeUpdateWithFormat:@"DELETE FROM nodes_tags WHERE node_id = %lld",node.element.elementID];
        [db executeUpdate:[OSMDAO sqliteInsertNodeTagsString:node.element]];
        [db executeUpdateWithFormat:@"UPDATE nodes SET poi_id = %d,isVisible = %d WHERE id = %lld",node.typeID,node.isVisible,node.element.elementID];
        
    }];
    
}
-(void)updateWay:(OPEManagedOsmWay *)way
{
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        
        [db executeUpdate:[OSMDAO sqliteInsertOrReplaceWayTagsString:way.element]];
        [db executeUpdateWithFormat:@"DELETE FROM ways_tags WHERE way_id = %lld",way.element.elementID];
        [db executeUpdate:[OSMDAO sqliteInsertOrReplaceWayTagsString:way.element]];
        [db executeUpdateWithFormat:@"UPDATE ways SET poi_id = %d,isVisible = %d WHERE id = %lld",way.typeID,way.isVisible,way.element.elementID];
        
    }];
    
}
-(void)updateRelation:(OPEManagedOsmRelation *)relation
{
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        
        [db executeUpdate:[OSMDAO sqliteInsertOrReplaceRelationString:relation.element]];
        [db executeUpdateWithFormat:@"DELETE FROM relations_tags WHERE relation_id = %lld",relation.element.elementID];
        [db executeUpdate:[OSMDAO sqliteInsertOrReplaceRelationTagsString:relation.element]];
        [db executeUpdateWithFormat:@"UPDATE relations SET poi_id,isVisible = %d = %d WHERE id = %lld",relation.typeID,relation.isVisible,relation.element.elementID];
        
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

//OSMDAODelegate Mehtod
-(void)didFinishSavingElements:(NSArray *)elements
{
    for(Element * element in elements)
    {
        if ([element.tags count]) {
            OPEManagedOsmElement * managedElement = [OPEManagedOsmElement elementWithBasicOsmElement:element];
            [self findType:managedElement];
        }
    }
    
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
