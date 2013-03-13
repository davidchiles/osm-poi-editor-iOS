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

@implementation OPEOSMData

@synthesize auth;


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

- (void)requestFinished:(ASIHTTPRequest *)request
{
    dispatch_queue_t q = dispatch_queue_create("Parse.Queue", NULL);
    dispatch_async(q,  ^{
    NSLog(@"Request Type: %@",[request.userInfo objectForKey:@"type"]);
    // Use when fetching text data
    //NSString *responseString = [request responseString];
    
    // Use when fetching binary data
    if ([[request.userInfo objectForKey:@"type"] isEqualToString: @"download"] )
    {
        NSData *responseData = [request responseData];
        TBXML* tbxml = [TBXML tbxmlWithXMLData:responseData];
        
        TBXMLElement * root = tbxml.rootXMLElement;
        if(root)
        {
            [self findNodes:root];
            [self findWays:root];
        }
        
        NSInteger count = [OPEManagedOsmNode MR_countOfEntities];
        count =  [OPEManagedOsmWay MR_countOfEntities];
    
        
        NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
        [context MR_saveToPersistentStoreAndWait];
        
    }
    });
    //dispatch_release(q);

}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    NSError *error = [request error];
    if (error) {
        NSLog(@"Error Description: %@",error.description);
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"DownloadError"
         object:self
         userInfo:nil];
    }
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

-(void)findNodes:(TBXMLElement *)root {
    if(root)
    {
        TBXMLElement* xmlNode = [TBXML childElementNamed:@"node" parentElement:root];
        while (xmlNode!=nil) {
            
            OPEManagedOsmNode * newNode = [OPEManagedOsmNode fetchOrCreateNodeWithOsmID:[[TBXML valueOfAttributeNamed:@"id" forElement:xmlNode] longLongValue]];
            NSInteger newVersion = [[TBXML valueOfAttributeNamed:@"version" forElement:xmlNode] integerValue];
            if (newVersion > newNode.versionValue) {
                newNode.lattitude = [NSNumber numberWithFloat:[[TBXML valueOfAttributeNamed:@"lat" forElement:xmlNode] floatValue]];
                newNode.longitude = [NSNumber numberWithFloat:[[TBXML valueOfAttributeNamed:@"lon" forElement:xmlNode] floatValue]];
                
                
                [newNode setMetaData:xmlNode];
                [newNode findType];
            }
            xmlNode = [TBXML nextSiblingNamed:@"node" searchFromElement:xmlNode];
        }
    }
}

-(void)findWays:(TBXMLElement *)root{
    if(root)
    {
        TBXMLElement* xmlWay = [TBXML childElementNamed:@"way" parentElement:root];
        while (xmlWay!=nil) {
            
            OPEManagedOsmWay * newWay = [OPEManagedOsmWay fetchOrCreatWayWithOsmID:[[TBXML valueOfAttributeNamed:@"id" forElement:xmlWay] longLongValue]];
            NSInteger newVersion = [[TBXML valueOfAttributeNamed:@"version" forElement:xmlWay] integerValue];
            if (newVersion > newWay.versionValue) {
                [newWay setMetaData:xmlWay];
                
                TBXMLElement* nodeXml = [TBXML childElementNamed:@"nd" parentElement:xmlWay];
                NSMutableOrderedSet * nodeSet = [NSMutableOrderedSet orderedSet];
                
                while (nodeXml!=nil) {
                    int64_t nodeId = [[TBXML valueOfAttributeNamed:@"ref" forElement:nodeXml] longLongValue];
                    OPEManagedOsmNode * node = [OPEManagedOsmNode fetchOrCreateNodeWithOsmID:nodeId];
                    [nodeSet addObject:node];
                    
                    nodeXml = [TBXML nextSiblingNamed:@"nd" searchFromElement:nodeXml];
                }
                [newWay setNodes:nodeSet];
                
                
                [newWay findType];
            }
            xmlWay = [TBXML nextSiblingNamed:@"way" searchFromElement:xmlWay];
        }
    }
}
 
-(void) getDataWithSW:(CLLocationCoordinate2D)southWest NE: (CLLocationCoordinate2D) northEast
{
    double boxleft = southWest.longitude;
    double boxbottom = southWest.latitude;
    double boxright = northEast.longitude;
    double boxtop = northEast.latitude;
    
    NSURL* url = [NSURL URLWithString: [NSString stringWithFormat:@"%@[bbox=%f,%f,%f,%f][@meta]",kOPEAPIURL,boxleft,boxbottom,boxright,boxtop]];
    NSLog(@"Download URL %@",url);
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    request.userInfo = [[NSDictionary alloc] initWithObjectsAndKeys:@"download",@"type", nil];
    [request setDelegate:self];
    [request startAsynchronous];
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
