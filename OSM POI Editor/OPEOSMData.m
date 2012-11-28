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
    dispatch_queue_t q = dispatch_queue_create("queue", NULL);
    dispatch_async(q,  ^{
    NSLog(@"Request Type: %@",[request.userInfo objectForKey:@"type"]);
    // Use when fetching text data
    //NSString *responseString = [request responseString];
    
    // Use when fetching binary data
    if ([request.userInfo objectForKey:@"type"] == @"download" )
    {
        //NSMutableDictionary * newNodes = [[NSMutableDictionary alloc] init];
        //NSMutableDictionary * allNewNodes = [[NSMutableDictionary alloc] init];
        NSData *responseData = [request responseData];
        TBXML* tbxml = [TBXML tbxmlWithXMLData:responseData];
        
        NSMutableDictionary * tempNodes = [self findNodes:tbxml];
        NSMutableDictionary * tempWays = [self findWays:tbxml nodes:tempNodes];
        
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
        
        /*
        TBXMLElement * root = tbxml.rootXMLElement;
        if(root)
        {
            //NSLog(@"root: %@",[TBXML elementName:root]);
            //NSLog(@"version: %@",[TBXML valueOfAttributeNamed:@"version" forElement:root]);
            TBXMLElement* node = [TBXML childElementNamed:@"node" parentElement:root];
            while (node!=nil) {
                
                //NSLog(@"node: %@",[TBXML textForElement:node]);
                NSString* identS = [TBXML valueOfAttributeNamed:@"id" forElement:node];
                //NSLog(@"id %@",identS);
                NSString* latS = [TBXML valueOfAttributeNamed:@"lat" forElement:node];
                NSString* lonS = [TBXML valueOfAttributeNamed:@"lon" forElement:node];
                NSString* verS = [TBXML valueOfAttributeNamed:@"version" forElement:node];
                
                double ident = [identS doubleValue];
                double lat = [latS doubleValue];
                double lon = [lonS doubleValue];
                int ver = [verS intValue];
                
                OPENode * newNode = [[OPENode alloc] initWithId:ident latitude:lat longitude:lon version:ver];
                //NSLog(@"lat: %f, lon: %f",lat,lon);
                TBXMLElement* tag = [TBXML childElementNamed:@"tag" parentElement:node];
                
                while (tag!=nil) //Takes in tags and adds them to newNode
                {
                    NSString* key = [TBXML valueOfAttributeNamed:@"k" forElement:tag];
                    NSString* value = [TBXML valueOfAttributeNamed:@"v" forElement:tag];
                    //NSLog(@"key: %@, value: %@",key,value);
                    [newNode.tags setObject:value forKey:key];
                    tag = [TBXML nextSiblingNamed:@"tag" searchFromElement:tag];
                }
                [allNewNodes setObject:newNode forKey:[NSNumber numberWithInt: newNode.ident]];
                
                OPETagInterpreter * tagInterpreter = [OPETagInterpreter sharedInstance];
    
                if([tagInterpreter getCategoryandType:newNode]) //Checks that node to be added has recognized tags and then adds it to set of all nodes
                {
                    //NSLog(@"New Node Id: %d",newNode.ident);
                    //NSLog(@"all nodes: %@",[self.allNodes objectForKey:[NSNumber numberWithInt:newNode.ident]]);
                    newNode.image = [tagInterpreter getImageForNode:newNode];
                    if ([self.allNodes objectForKey:[NSNumber numberWithInt:newNode.ident]] ==nil && [self.ignoreNodes objectForKey:[NSNumber numberWithInt:newNode.ident]] == nil) 
                    {
                        //NSLog(@"add to node dictionary");
                        [OPEOSMData HTMLFix:newNode];
                        [self.allNodes setObject:newNode forKey:[NSNumber numberWithInt:newNode.ident]];
                        [newNodes setObject:newNode forKey:[NSNumber numberWithInt:newNode.ident]];
                    }
                }
                node = [TBXML nextSiblingNamed:@"node" searchFromElement:node];
            }
            NSLog(@"allNodes size: %d",[allNodes count]);
            
        }
        */
        dispatch_async(dispatch_get_main_queue(), ^{
        
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"DownloadComplete"
         object:self
         userInfo:tempNodes];
        });
        
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

-(NSMutableDictionary *)findNodes:(TBXML *)xml {
    
    NSMutableDictionary * nodeDictionary = [[NSMutableDictionary alloc] init];
    TBXMLElement * root = xml.rootXMLElement;
    if(root)
    {
        TBXMLElement* xmlNode = [TBXML childElementNamed:@"node" parentElement:root];
        while (xmlNode!=nil) {
            OPENode * newNode = [OPENode createPointWithXML:xmlNode];
            newNode.image = [tagInterpreter getImageForNode:newNode];
            [OPEOSMData HTMLFix:newNode];
            [nodeDictionary setObject:newNode forKey:[newNode uniqueIdentifier] ];
            
            
            xmlNode = [TBXML nextSiblingNamed:@"node" searchFromElement:xmlNode];
        }
    }
    return nodeDictionary;
}

-(NSMutableDictionary *)findWays:(TBXML *)xml nodes:(NSDictionary *)nodes{
    NSMutableDictionary * wayDictionary = [[NSMutableDictionary alloc] init];
    TBXMLElement * root = xml.rootXMLElement;
    if(root)
    {
        TBXMLElement* xmlWay = [TBXML childElementNamed:@"way" parentElement:root];
        while (xmlWay!=nil) {
            OPEWay * newWay = [OPEWay createPointWithXML:xmlWay nodes:nodes];
            newWay.image = [tagInterpreter getImageForNode:newWay];
            [OPEOSMData HTMLFix:newWay];
            [wayDictionary setObject:newWay forKey:[newWay uniqueIdentifier]];
            xmlWay = [TBXML nextSiblingNamed:@"way" searchFromElement:xmlWay];
        }
    }
    return wayDictionary;
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
