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

@synthesize allNodes;
@synthesize ignoreNodes;
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
        allNodes = [[NSMutableDictionary alloc] init];
        ignoreNodes = [[NSMutableDictionary alloc] init];
        
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
        //NSMutableDictionary * newNodes = [[NSMutableDictionary alloc] init];
        //NSMutableDictionary * allNewNodes = [[NSMutableDictionary alloc] init];
        NSData *responseData = [request responseData];
        TBXML* tbxml = [TBXML tbxmlWithXMLData:responseData];
        
        [self findNodes:tbxml];
        [self findWays:tbxml];
        
        NSInteger count = [OPEManagedOsmNode MR_countOfEntities];
        count =  [OPEManagedOsmWay MR_countOfEntities];
        
        
        
        NSMutableDictionary * tempNodes; 
        NSMutableDictionary * tempWays;        
        [tempNodes addEntriesFromDictionary:tempWays];
        
        for (NSString *key in [tempNodes allKeys])
        {
            if(![tagInterpreter isSupported:[tempNodes objectForKey:key]]) //Checks that node to be added has recognized tags and then adds it to set of all nodes
            {
                [tempNodes removeObjectForKey:key];
            }
            
        }
        
        [tempNodes removeObjectsForKeys:[allNodes allKeys]];
        [tempNodes removeObjectsForKeys:[ignoreNodes allKeys]];
        [allNodes addEntriesFromDictionary:tempNodes];
    
        
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

-(void)findNodes:(TBXML *)xml {
    TBXMLElement * root = xml.rootXMLElement;
    if(root)
    {
        TBXMLElement* xmlNode = [TBXML childElementNamed:@"node" parentElement:root];
        while (xmlNode!=nil) {
            
            OPEManagedOsmNode * newNode = [OPEManagedOsmNode fetchNodeWithOsmId:[[TBXML valueOfAttributeNamed:@"id" forElement:xmlNode] integerValue]];
            if (!newNode) {
                newNode = [OPEManagedOsmNode MR_createEntity];
            }
            
            newNode.osmID = [NSNumber numberWithInteger:[[TBXML valueOfAttributeNamed:@"id" forElement:xmlNode] integerValue]];
            newNode.lattitude = [NSNumber numberWithFloat:[[TBXML valueOfAttributeNamed:@"lat" forElement:xmlNode] floatValue]];
            newNode.longitude = [NSNumber numberWithFloat:[[TBXML valueOfAttributeNamed:@"lon" forElement:xmlNode] floatValue]];
            newNode.version = [NSNumber numberWithInteger:[[TBXML valueOfAttributeNamed:@"version" forElement:xmlNode] integerValue]];
            
            TBXMLElement* tag = [TBXML childElementNamed:@"tag" parentElement:xmlNode];
            
            NSMutableSet * newTags = [NSMutableSet set];
            
            while (tag!=nil) //Takes in tags and adds them to newNode
            {
                NSString* key = [TBXML valueOfAttributeNamed:@"k" forElement:tag];
                NSString* value = [OPEOSMData htmlFix:[TBXML valueOfAttributeNamed:@"v" forElement:tag]];
                OPEManagedOsmTag * newTag = [OPEManagedOsmTag fetchOrCreateWithKey:key value:value];
                [newTags addObject:newTag];
                
                tag = [TBXML nextSiblingNamed:@"tag" searchFromElement:tag];
            }
            [newNode setTags:newTags];
            
            [newNode findType];
            

            xmlNode = [TBXML nextSiblingNamed:@"node" searchFromElement:xmlNode];
        }
    }
}

-(void)findWays:(TBXML *)xml{
    TBXMLElement * root = xml.rootXMLElement;
    if(root)
    {
        TBXMLElement* xmlWay = [TBXML childElementNamed:@"way" parentElement:root];
        while (xmlWay!=nil) {
            
            OPEManagedOsmWay * newWay = [OPEManagedOsmWay MR_createEntity];
            
            newWay.osmID = [NSNumber numberWithInteger:[[TBXML valueOfAttributeNamed:@"id" forElement:xmlWay] integerValue]];
            newWay.version = [NSNumber numberWithInteger:[[TBXML valueOfAttributeNamed:@"version" forElement:xmlWay] integerValue]];
            
            TBXMLElement* nodeXml = [TBXML childElementNamed:@"nd" parentElement:xmlWay];
            NSMutableOrderedSet * nodeSet = [NSMutableOrderedSet orderedSet];
            
            while (nodeXml!=nil) {
                NSInteger nodeId = [[TBXML valueOfAttributeNamed:@"ref" forElement:nodeXml] integerValue];
                OPEManagedOsmNode * node = [OPEManagedOsmNode fetchNodeWithOsmId:nodeId];
                [nodeSet addObject:node];
                
                nodeXml = [TBXML nextSiblingNamed:@"nd" searchFromElement:nodeXml];
            }
            [newWay setNodes:nodeSet];
            
            
            TBXMLElement* tag = [TBXML childElementNamed:@"tag" parentElement:xmlWay];
            
            NSMutableSet * newTags = [NSMutableSet set];
            
            while (tag!=nil) //Takes in tags and adds them to newNode
            {
                NSString* key = [TBXML valueOfAttributeNamed:@"k" forElement:tag];
                NSString* value = [OPEOSMData htmlFix:[TBXML valueOfAttributeNamed:@"v" forElement:tag]];
                OPEManagedOsmTag * newTag = [OPEManagedOsmTag fetchOrCreateWithKey:key value:value];
                [newTags addObject:newTag];
                
                tag = [TBXML nextSiblingNamed:@"tag" searchFromElement:tag];
            }
            [newWay setTags:newTags];
            
            [newWay findType];
            
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

- (int) createNode: (OPEPoint *) newPoint
{
    NSInteger changeset = [self openChangesetWithMessage:[NSString stringWithFormat:@"Created new POI: %@",[tagInterpreter getName:newPoint]]];
    int newIdent = [self createXmlNode:newPoint withChangeset:changeset];
    [self closeChangeset:changeset];
    return newIdent;
    
}
- (int) updateNode: (OPEPoint *) node
{
    NSInteger changeset = [self openChangesetWithMessage:[NSString stringWithFormat:@"Updated existing POI: %@",[tagInterpreter getName:node]]];
    int version = [self updateXmlNode:node withChangeset:changeset];
    [self closeChangeset:changeset];
    [ignoreNodes setObject:node forKey:[node uniqueIdentifier]];
    return version;
    
}
- (int) deleteNode: (OPEPoint *) node
{
    NSInteger changeset = [self openChangesetWithMessage:[NSString stringWithFormat:@"Deleted POI: %@",[tagInterpreter getName:node]]];
    int version = [self deleteXmlNode:node withChangeset:changeset];
    [self closeChangeset:changeset];
    
    return version;
    
}

- (NSInteger) openChangesetWithMessage: (NSString *) message
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
    
    
    return [[[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding] intValue];
}

- (int) updateXmlNode: (OPEPoint *) node withChangeset: (NSInteger) changesetNumber
{
    
    NSData * nodeXML = [node updateXMLforChangset:changesetNumber];
    
    
    NSLog(@"Node Data: %@",[[NSString alloc] initWithData:nodeXML encoding:NSUTF8StringEncoding]);
    NSURL * url;
    
    if([node isKindOfClass:[OPENode class]] )
    {
        url = [NSURL URLWithString:[NSString stringWithFormat:@"http://api.openstreetmap.org/api/0.6/node/%d",node.ident]];
    }
    else
    {
        url = [NSURL URLWithString:[NSString stringWithFormat:@"http://api.openstreetmap.org/api/0.6/way/%d",node.ident]];
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

- (int) createXmlNode: (OPEPoint *) node withChangeset: (NSInteger) changesetNumber
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
    
- (int) deleteXmlNode: (OPEPoint *) node withChangeset: (NSInteger) changesetNumber
{
    
    NSData *nodeXML = [node deleteXMLforChangset:changesetNumber];
    
    
    NSURL * url = [NSURL URLWithString:[NSString stringWithFormat:@"http://api.openstreetmap.org/api/0.6/node/%d",node.ident]];
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

- (void) closeChangeset: (NSInteger) changesetNumber
{
    NSURL * url = [NSURL URLWithString:[NSString stringWithFormat:@"http://api.openstreetmap.org/api/0.6/changeset/%d/close",changesetNumber]];
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
+(void) backToHTML:(OPEPoint *)node
{
    NSMutableDictionary * fixedTags = [[NSMutableDictionary alloc] init];
    for(id item in node.tags)
    {
        NSString * fixed = [[node.tags objectForKey:item] stringByReplacingOccurrencesOfString:@"&" withString:@"&amp;"];
        [fixedTags setObject:fixed forKey:item];
    }
    node.tags = [[NSMutableDictionary alloc] initWithDictionary:fixedTags];
    
}

+ (NSString *)htmlFix:(NSString *)string
{
    return [string stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"];
}

+(void) HTMLFix:(OPEPoint *)node
{
    NSMutableDictionary * fixedTags = [[NSMutableDictionary alloc] init];
    for(id item in node.tags)
    {
        NSString * fixed = [[node.tags objectForKey:item] stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"];
        [fixedTags setObject:fixed forKey:item];
    }
    node.tags = [[NSMutableDictionary alloc] initWithDictionary:fixedTags];
}
@end
