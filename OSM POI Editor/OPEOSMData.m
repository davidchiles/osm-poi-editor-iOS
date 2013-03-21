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
#import "OPENode.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "GTMOAuthViewControllerTouch.h"
#import "OPEAPIConstants.h"
#import "OPEWay.h"
#import "OPEConstants.h"
#import "OPEManagedOsmNode.h"
#import "OPEManagedOsmTag.h"
#import "OPEManagedOsmWay.h"
#import "OPEManagedOsmRelation.h"
#import "OPEChangeset.h"
#import "OPEMRUtility.h"

@implementation OPEOSMData

@synthesize auth;
@synthesize delegate;
@synthesize currentElement = _currentElement;


-(id) init
{
    self = [super init];
    if(self)
    {
        NSString *myConsumerKey = osmConsumerKey; //@"pJbuoc7SnpLG5DjVcvlmDtSZmugSDWMHHxr17wL3";    // pre-registered with service
        NSString *myConsumerSecret = osmConsumerSecret; //@"q5qdc9DvnZllHtoUNvZeI7iLuBtp1HebShbCE9Y1"; // pre-assigned by service
        
        auth = [[GTMOAuthAuthentication alloc] initWithSignatureMethod:kGTMOAuthSignatureMethodHMAC_SHA1
                                                           consumerKey:myConsumerKey
                                                            privateKey:myConsumerSecret];
        
        //tagInterpreter = [OPETagInterpreter sharedInstance];
        q = dispatch_queue_create("Parse.Queue", NULL);
        
        //NSString * baseUrl = @"http://api06.dev.openstreetmap.org/";
        NSString * baseUrl = @"http://api.openstreetmap.org/api/0.6/";
        
        httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:baseUrl]];
        //[httpClient setAuthorizationHeaderWithToken:auth.token];
    }
    
    return self;
}

-(BOOL) canAuth;
{
    BOOL didAuth = NO;
    BOOL canAuth = NO;
    if (auth) {
        didAuth = [GTMOAuthViewControllerTouch authorizeFromKeychainForName:@"OSMPOIEditor"
                                                             authentication:auth];
        // if the auth object contains an access token, didAuth is now true
        canAuth = [auth canAuthorize];
    }
    else {
        return NO;
    }
    return didAuth && canAuth;

    
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
    AFXMLRequestOperation * xmlRequestOperation = [AFXMLRequestOperation XMLParserRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, NSXMLParser *XMLParser) {
            dispatch_async(q,  ^{
            XMLParser.delegate = self;
            [XMLParser parse];
                });
            
        
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, NSXMLParser *XMLParser) {
        [delegate downloadFailed:error];
    }];
    [xmlRequestOperation start];
    
    
    NSLog(@"Download URL %@",url);
}

#pragma nsxmlparserdelegate

-(void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    if ([elementName isEqualToString:@"node"] || [elementName isEqualToString:@"way"] ||[elementName isEqualToString:@"relation"]) {
        [self.currentElement findType];
        
        if ([self.currentElement isKindOfClass:[OPEManagedOsmWay class]]) {
            OPEManagedOsmWay* osmWay =(OPEManagedOsmWay *)self.currentElement;
            osmWay.isNoNameStreetValue = [osmWay noNameStreet];
        }
        
        self.currentElement = nil;
    }
}

-(void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
     NSInteger newVersion = [[attributeDict objectForKey:@"version"] integerValue];
    
    if ([elementName isEqualToString:@"node"]) {
        OPEManagedOsmNode * newNode = [OPEManagedOsmNode fetchOrCreateNodeWithOsmID:[[attributeDict objectForKey:@"id"] longLongValue]];
        if (newVersion > newNode.versionValue) {
            [newNode setMetaData:attributeDict];
            newNode.isVisibleValue = YES;
            newNode.latitudeValue = [[attributeDict objectForKey:@"lat"] doubleValue];
            newNode.longitudeValue = [[attributeDict objectForKey:@"lon"] doubleValue];
            self.currentElement = newNode;
        }
        else{
            self.currentElement = nil;
        }
        
    }
    else if([elementName isEqualToString:@"way"])
    {
        OPEManagedOsmWay * newWay = [OPEManagedOsmWay fetchOrCreatWayWithOsmID:[[attributeDict objectForKey:@"id"] longLongValue]];
        if (newVersion > newWay.versionValue) {
            [newWay setMetaData:attributeDict];
            self.currentElement = newWay;
        }
        
    }
    else if([elementName isEqualToString:@"relation"])
    {
        
    }
    else if ([elementName isEqualToString:@"tag"])
    {
        if (self.currentElement) {
            [self.currentElement addKey:[attributeDict objectForKey:@"k"] value:[attributeDict objectForKey:@"v"]];
        }
        
    }
    else if ([elementName isEqualToString:@"nd"])
    {
        int64_t nodeId = [[attributeDict objectForKey:@"ref"] longLongValue];
        OPEManagedOsmNode * node = [OPEManagedOsmNode fetchOrCreateNodeWithOsmID:nodeId];
        [currentWay.nodesSet addObject:node];
    }
    else if([elementName isEqualToString:@"member"])
    {
        
    }
}

-(void)parserDidEndDocument:(NSXMLParser *)parser
{
    NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
    [context MR_saveToPersistentStoreWithCompletion:nil];
}

-(void)setCurrentElement:(OPEManagedOsmElement *)currentElement{
    _currentElement = currentElement;
    currentRelation = nil;
    currentWay = nil;
    if ([currentElement isKindOfClass:[OPEManagedOsmWay class]]) {
        currentWay = (OPEManagedOsmWay *)currentElement;
    }
    else if ([currentElement isKindOfClass:[OPEManagedOsmRelation class]])
    {
        currentRelation = (OPEManagedOsmRelation *)currentElement;
    }
}

-(void)uploadElement:(OPEManagedOsmElement *)element
{
    OPEChangeset * changeset = [[OPEChangeset alloc] init];
    [changeset addElement:element];
    changeset.message = [NSString stringWithFormat:@"Created new POI: %@",element.name];
    
    [self openChangeset:changeset];
    
}
-(void)deleteElement:(OPEManagedOsmElement *)element
{
    OPEChangeset * changeset = [[OPEChangeset alloc] init];
    [changeset addElement:element];
    changeset.message = [NSString stringWithFormat:@"Deleted POI: %@",element.name];
    
    [self openChangeset:changeset];
    
}

- (void) openChangeset:(OPEChangeset *)changeset
{    
    
    NSMutableString * changesetString = [[NSMutableString alloc] init];
    
    [changesetString appendString:@"<?xml version=\"1.0\" encoding=\"UTF-8\" ?>"];
    [changesetString appendString:@"<osm version=\"0.6\" generator=\"OSMPOIEditor\">"];
    [changesetString appendString:@"<changeset>"];
    [changesetString appendString:@"<tag k=\"created_by\" v=\"OSMPOIEditor\"/>"];
    [changesetString appendFormat:@"<tag k=\"comment\" v=\"%@\"/>",changeset.message];
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
            [delegate uploadFailed:error];
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
    int64_t elementOsmID = element.osmIDValue;
    NSManagedObjectID * objectID = element.objectID;
    
    if (elementOsmID < 0) {
        [path appendString:@"create"];
    }
    else{
        [path appendFormat:@"%lld",element.osmIDValue];
    }
    
    NSMutableURLRequest * urlRequest = [httpClient requestWithMethod:@"PUT" path:path parameters:nil];
    [urlRequest setHTTPBody:xmlData];
    [auth authorizeRequest:urlRequest];
    
    AFHTTPRequestOperation * requestOperation = [[AFHTTPRequestOperation alloc] initWithRequest:urlRequest];
    [requestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id object){
        NSLog(@"changeset %@",object);
        int64_t response = [[[NSString alloc] initWithData:object encoding:NSUTF8StringEncoding] longLongValue];
        
        OPEManagedOsmElement * element = (OPEManagedOsmElement*)[OPEMRUtility managedObjectWithID:objectID];
        
        if (elementOsmID < 0) {
            element.osmIDValue = response;
            element.versionValue = 1;
        }
        else{
            element.versionValue = response;
        }
        
        
        NSManagedObjectContext * context = [NSManagedObjectContext MR_contextForCurrentThread];
        [context MR_saveToPersistentStoreAndWait];
        
        //[delegate uploadedElement:element.objectID newVersion:newVersion];
        
        
    }failure:^(AFHTTPRequestOperation *operation, NSError * error)
     {
         dispatch_async(dispatch_get_main_queue(), ^{
             [delegate uploadFailed:error];
         });
         NSLog(@"Failed: %@",urlRequest.URL);
     }];
    return requestOperation;
    
}

-(AFHTTPRequestOperation *)deleteRequestOperationWithElement: (OPEManagedOsmElement *) element changeset: (int64_t) changesetNumber
{
    NSData * xmlData = [element deleteXMLforChangset:changesetNumber];
    NSString * path = [NSString stringWithFormat:@"%@/%lld",[element osmType],element.osmIDValue];
    NSManagedObjectID * objectID = element.objectID;
    
    NSMutableURLRequest * urlRequest = [httpClient requestWithMethod:@"DELETE" path:path parameters:nil];
    [urlRequest setHTTPBody:xmlData];
    [auth authorizeRequest:urlRequest];
    
    AFHTTPRequestOperation * requestOperation = [[AFHTTPRequestOperation alloc] initWithRequest:urlRequest];
    [requestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id object){
        NSLog(@"changeset %@",object);
        NSInteger newVersion = [[[NSString alloc] initWithData:object encoding:NSUTF8StringEncoding] integerValue];
        OPEManagedOsmElement * element = (OPEManagedOsmElement*)[OPEMRUtility managedObjectWithID:objectID];
        
        element.osmIDValue = newVersion;
        element.isVisibleValue = NO;
        NSManagedObjectContext * context = [NSManagedObjectContext MR_contextForCurrentThread];
        [context MR_saveToPersistentStoreAndWait];
        
        //[delegate uploadedElement:element.objectID newVersion:newVersion];
        
        
    }failure:^(AFHTTPRequestOperation *operation, NSError * error)
     {
         dispatch_async(dispatch_get_main_queue(), ^{
             [delegate uploadFailed:error];
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
             [delegate uploadFailed:error];
         });
         NSLog(@"Failed: %@",urlRequest.URL);
     }];
    [requestOperation start];
    
}


@end
