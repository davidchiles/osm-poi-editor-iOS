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
#import "AFNetworking.h"

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
        
        tagInterpreter = [OPETagInterpreter sharedInstance];
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
            dispatch_queue_t q = dispatch_queue_create("Parse.Queue", NULL);
            dispatch_async(q,  ^{
                XMLParser.delegate = self;
                [XMLParser parse];
                });
            
        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, NSXMLParser *XMLParser) {
            [delegate downloadFailed:error];
        }];
        [xmlRequestOperation start];
    
    
    NSLog(@"Download URL %@",url);
    //ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    //request.userInfo = [[NSDictionary alloc] initWithObjectsAndKeys:@"download",@"type", nil];
    //[request setDelegate:self];
    //[request startAsynchronous];
}

#pragma nsxmlparserdelegate

-(void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    if ([elementName isEqualToString:@"node"] || [elementName isEqualToString:@"way"] ||[elementName isEqualToString:@"relation"]) {
        [self.currentElement findType];
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
            newNode.lattitudeValue = [[attributeDict objectForKey:@"lat"] doubleValue];
            newNode.longitudeValue = [[attributeDict objectForKey:@"lon"] doubleValue];
            self.currentElement = newNode;
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
        [self.currentElement addKey:[attributeDict objectForKey:@"k"] value:[attributeDict objectForKey:@"v"]];
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


- (int64_t) createNode: (OPEManagedOsmNode *) node
{
    int64_t changeset = [self openChangesetWithMessage:[NSString stringWithFormat:@"Created new POI: %@",node.name]];
    int64_t newIdent = [self createXmlNode:node withChangeset:changeset];
    [self closeChangeset:changeset];
    return newIdent;
    
}
- (int64_t) updateNode: (OPEManagedOsmElement *) element
{
    int64_t changeset = [self openChangesetWithMessage:[NSString stringWithFormat:@"Updated existing POI: %@",element.name]];
    int version = [self updateXmlNode:element withChangeset:changeset];
    [self closeChangeset:changeset];
    //[ignoreNodes setObject:node forKey:[node uniqueIdentifier]];
    return version;
    
}
- (int64_t) deleteNode: (OPEManagedOsmNode *) node
{
    int64_t changeset = [self openChangesetWithMessage:[NSString stringWithFormat:@"Deleted POI: %@",node.name]];
    int version = [self deleteXmlNode:node withChangeset:changeset];
    [self closeChangeset:changeset];
    
    return version;
    
}

- (int64_t) openChangesetWithMessage: (NSString *) message
{    
    BOOL didAuth = NO;
    BOOL canAuth = NO;
    if (auth) {
        didAuth = [GTMOAuthViewControllerTouch authorizeFromKeychainForName:@"OSMPOIEditor"
                                                                  authentication:auth];
        // if the auth object contains an access token, didAuth is now true
        canAuth = [auth canAuthorize];
    }
    
    // retain the authentication object, which holds the auth tokens
    //
    // we can determine later if the auth object contains an access token
    // by calling its -canAuthorize method
    //[self setAuthentication:auth];
    NSLog(@"didAuth %d",didAuth);
    NSLog(@"canAuth %d",canAuth);
    
    NSURL * url = [NSURL URLWithString:[NSString stringWithFormat:@"http://api.openstreetmap.org/api/0.6/changeset/create"]];
    NSLog(@"URL: %@",[url absoluteURL]);
    NSMutableURLRequest * urlRequest = [NSMutableURLRequest requestWithURL:url];
    //[urlRequest setURL:url];
    [urlRequest setHTTPMethod:@"PUT"];
   
    //NSLog(@"URL before: %@",[urlRequest.URL absoluteURL]);
    
    //NSLog(@"URL header: %@",urlRequest.allHTTPHeaderFields);
    //NSLog(@"URL after: %@",[urlRequest.URL absoluteURL]);
    
    NSMutableData *changeset = [NSMutableData data];
    
    [changeset appendData: [[NSString stringWithFormat: @"<?xml version=\"1.0\" encoding=\"UTF-8\" ?>"] dataUsingEncoding: NSUTF8StringEncoding]];
    [changeset appendData: [[NSString stringWithFormat: @"<osm version=\"0.6\" generator=\"OSMPOIEditor\">"] dataUsingEncoding: NSUTF8StringEncoding]];
    [changeset appendData: [[NSString stringWithFormat: @"<changeset>"] dataUsingEncoding: NSUTF8StringEncoding]];
    [changeset appendData: [[NSString stringWithFormat: @"<tag k=\"created_by\" v=\"OSMPOIEditor\"/>"] dataUsingEncoding: NSUTF8StringEncoding]];
    [changeset appendData: [[NSString stringWithFormat: @"<tag k=\"comment\" v=\"%@\"/>",message] dataUsingEncoding: NSUTF8StringEncoding]];
    [changeset appendData: [[NSString stringWithFormat: @"</changeset>"] dataUsingEncoding: NSUTF8StringEncoding]];
    [changeset appendData: [[NSString stringWithFormat: @"</osm>"] dataUsingEncoding: NSUTF8StringEncoding]];
    //[changeset appendData: [[NSString stringWithFormat: @"</xml>"] dataUsingEncoding: NSUTF8StringEncoding]];
    
    NSLog(@"Changeset Data: %@",[[NSString alloc] initWithData:changeset encoding:NSUTF8StringEncoding]);
    
    [urlRequest setHTTPBody: changeset];
    [urlRequest setHTTPMethod: @"PUT"];
    [auth authorizeRequest:urlRequest];
    NSData *returnData = [NSURLConnection sendSynchronousRequest: urlRequest returningResponse: nil error: nil];
    NSLog(@"Return Data: %@",[[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding]);
    
    
    return [[[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding] longLongValue];
}

- (int64_t) updateXmlNode: (OPEManagedOsmElement *) element withChangeset: (int64_t) changesetNumber
{
    
    NSData * nodeXML = [element updateXMLforChangset:changesetNumber];
    
    
    NSLog(@"Node Data: %@",[[NSString alloc] initWithData:nodeXML encoding:NSUTF8StringEncoding]);
    NSURL * url;
    
    if([element isKindOfClass:[OPENode class]] )
    {
        url = [NSURL URLWithString:[NSString stringWithFormat:@"http://api.openstreetmap.org/api/0.6/node/%lld",element.osmIDValue]];
    }
    else
    {
        url = [NSURL URLWithString:[NSString stringWithFormat:@"http://api.openstreetmap.org/api/0.6/way/%lld",element.osmIDValue]];
    }
    
    NSLog(@"URL: %@",[url absoluteURL]);
    NSMutableURLRequest * urlRequest = [NSMutableURLRequest requestWithURL:url];
    [urlRequest setHTTPBody: nodeXML];
    [urlRequest setHTTPMethod: @"PUT"];
    [auth authorizeRequest:urlRequest];
    NSData *returnData = [NSURLConnection sendSynchronousRequest: urlRequest returningResponse: nil error: nil];

    NSLog(@"Return Data: %@",[[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding]);
    return [[[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding] intValue];
    
}

- (int64_t) createXmlNode: (OPEManagedOsmNode *) node withChangeset: (int64_t) changesetNumber
{
    
    NSData *nodeXML = [node createXMLforChangset:changesetNumber];
    
    NSLog(@"Node Data: %@",[[NSString alloc] initWithData:nodeXML encoding:NSUTF8StringEncoding]);
    
    NSURL * url = [NSURL URLWithString:[NSString stringWithFormat:@"http://api.openstreetmap.org/api/0.6/node/create"]];
    NSLog(@"URL: %@",[url absoluteURL]);
    NSMutableURLRequest * urlRequest = [NSMutableURLRequest requestWithURL:url];
    [urlRequest setHTTPBody: nodeXML];
    [urlRequest setHTTPMethod: @"PUT"];
    [auth authorizeRequest:urlRequest];
    NSData *returnData = [NSURLConnection sendSynchronousRequest: urlRequest returningResponse: nil error: nil];
    //NSData * returnData = nil;
    NSLog(@"Create Node Return Data: %@",[[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding]);
    return [[[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding] intValue];
}
    
- (int64_t) deleteXmlNode: (OPEManagedOsmNode *) node withChangeset: (int64_t) changesetNumber
{
    
    NSData *nodeXML = [node deleteXMLforChangset:changesetNumber];
    
    
    NSURL * url = [NSURL URLWithString:[NSString stringWithFormat:@"http://api.openstreetmap.org/api/0.6/node/%lld",node.osmIDValue]];
    NSLog(@"URL: %@",[url absoluteURL]);
    NSMutableURLRequest * urlRequest = [NSMutableURLRequest requestWithURL:url];
    [urlRequest setHTTPBody: nodeXML];
    [urlRequest setHTTPMethod: @"DELETE"];
    [auth authorizeRequest:urlRequest];
    NSData *returnData = [NSURLConnection sendSynchronousRequest: urlRequest returningResponse: nil error: nil];
    //NSData * returnData = nil;
    NSLog(@"Delete Node Return Data: %@",[[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding]);
    return [[[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding] intValue];
    
}

- (void) closeChangeset: (int64_t) changesetNumber
{
    NSURL * url = [NSURL URLWithString:[NSString stringWithFormat:@"http://api.openstreetmap.org/api/0.6/changeset/%lld/close",changesetNumber]];
    NSLog(@"URL: %@",[url absoluteURL]);
    NSMutableURLRequest * urlRequest = [NSMutableURLRequest requestWithURL:url];
    [urlRequest setHTTPMethod: @"PUT"];
    [auth authorizeRequest:urlRequest];
    NSError * error;
    NSData *returnData = [NSURLConnection sendSynchronousRequest: urlRequest returningResponse: nil error: &error];
    [self uploadComplete];
    //NSData * returnData = nil;
    NSLog(@"Close Changeset Data: %@",[[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding]);
}

- (void) uploadComplete
{
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"uploadComplete"
     object:self
     userInfo:nil];
}


@end
