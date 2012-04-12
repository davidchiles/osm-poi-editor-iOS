//
//  OSMData.m
//  OSM POI Editor
//
//  Created by David Chiles on 2/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "OPEOSMData.h"
#import "TBXML.h"
#import "OPENode.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "GTMOAuthViewControllerTouch.h"

@implementation OPEOSMData

@synthesize allNodes;
@synthesize ignoreNodes;
@synthesize auth;


-(id) init
{
    self = [super init];
    if(self)
    {
        NSString *myConsumerKey = @"pJbuoc7SnpLG5DjVcvlmDtSZmugSDWMHHxr17wL3";    // pre-registered with service
        NSString *myConsumerSecret = @"q5qdc9DvnZllHtoUNvZeI7iLuBtp1HebShbCE9Y1"; // pre-assigned by service
        
        auth = [[GTMOAuthAuthentication alloc] initWithSignatureMethod:kGTMOAuthSignatureMethodHMAC_SHA1
                                                           consumerKey:myConsumerKey
                                                            privateKey:myConsumerSecret];
        allNodes = [[NSMutableDictionary alloc] init];
        ignoreNodes = [[NSMutableDictionary alloc] init];
    }
    
    return self;
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    NSLog(@"Request Type: %@",[request.userInfo objectForKey:@"type"]);
    // Use when fetching text data
    //NSString *responseString = [request responseString];
    
    // Use when fetching binary data
    if ([request.userInfo objectForKey:@"type"] == @"download" )
    {
        NSMutableDictionary * newNodes = [[NSMutableDictionary alloc] init];
        NSData *responseData = [request responseData];
        TBXML* tbxml = [TBXML tbxmlWithXMLData:responseData];
        
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
                OPETagInterpreter * tagInterpreter = [OPETagInterpreter sharedInstance];
    
                if([tagInterpreter getCategoryandType:newNode]) //Checks that node to be added has recognized tags and then adds it to set of all nodes
                {
                    //NSLog(@"New Node Id: %d",newNode.ident);
                    //NSLog(@"all nodes: %@",[self.allNodes objectForKey:[NSNumber numberWithInt:newNode.ident]]);
                    newNode.image = [tagInterpreter getImageForNode:newNode];
                    if ([self.allNodes objectForKey:[NSNumber numberWithInt:newNode.ident]] ==nil && [self.ignoreNodes objectForKey:[NSNumber numberWithInt:newNode.ident]] == nil) 
                    {
                        //NSLog(@"add to node dictionary");
                        if([newNode.tags objectForKey:@"name"])
                        {
                            //NSLog(@"Name: %@",[newNode.tags objectForKey:@"name"]);
                            NSString * newName = [OPEOSMData HTMLFix:[newNode.tags objectForKey:@"name"]];
                            //NSLog(@"New Name: %@",newName);
                            [newNode.tags setObject:newName forKey:@"name"];
                        }
                        [self.allNodes setObject:newNode forKey:[NSNumber numberWithInt:newNode.ident]];
                        [newNodes setObject:newNode forKey:[NSNumber numberWithInt:newNode.ident]];
                    }
                }
                node = [TBXML nextSiblingNamed:@"node" searchFromElement:node];
            }
            NSLog(@"allNodes size: %d",[allNodes count]);
            
        }
        
        
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"DownloadComplete"
         object:self
         userInfo:newNodes];
    }

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
/*
-(void) getData
{
    NSLog(@"box: %f,%f,%f,%f",bboxleft,bboxbottom,bboxright,bboxtop);
    NSURL* url = [NSURL URLWithString: [NSString stringWithFormat:@"http://www.overpass-api.de/api/xapi?node[bbox=%f,%f,%f,%f][@meta]",bboxleft,bboxbottom,bboxright,bboxtop]];
    NSLog(@"url: %@",[url absoluteString]);
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    request.userInfo = [[NSDictionary alloc] initWithObjectsAndKeys:@"download",@"type", nil];
    [request setDelegate:self];
    [request startAsynchronous];
}
*/
 
-(void) getDataWithSW:(CLLocationCoordinate2D)southWest NE: (CLLocationCoordinate2D) northEast
{
    double boxleft = southWest.longitude;
    double boxbottom = southWest.latitude;
    double boxright = northEast.longitude;
    double boxtop = northEast.latitude;
    
    NSURL* url = [NSURL URLWithString: [NSString stringWithFormat:@"http://www.overpass-api.de/api/xapi?node[bbox=%f,%f,%f,%f][@meta]",boxleft,boxbottom,boxright,boxtop]];
    NSLog(@"Download URL %@",url);
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    request.userInfo = [[NSDictionary alloc] initWithObjectsAndKeys:@"download",@"type", nil];
    [request setDelegate:self];
    [request startAsynchronous];
}

- (int) createNode: (OPENode *) node
{
    OPETagInterpreter * tagInterpreter = [OPETagInterpreter sharedInstance];
    NSInteger changeset = [self openChangesetWithMessage:[NSString stringWithFormat:@"Created new POI: %@",[tagInterpreter getName:node]]];
    int newIdent = [self createXmlNode:node withChangeset:changeset];
    [self closeChangeset:changeset];
    return newIdent;
    
}
- (int) updateNode: (OPENode *) node
{
    OPETagInterpreter * tagInterpreter = [OPETagInterpreter sharedInstance];
    NSInteger changeset = [self openChangesetWithMessage:[NSString stringWithFormat:@"Updated existing POI: %@",[tagInterpreter getName:node]]];
    int version = [self updateXmlNode:node withChangeset:changeset];
    [self closeChangeset:changeset];
    [ignoreNodes setObject:node forKey:[NSNumber numberWithInt:node.ident]];
    return version;
    
}
- (int) deleteNode: (OPENode *) node
{
    OPETagInterpreter * tagInterpreter = [OPETagInterpreter sharedInstance];
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

- (int) updateXmlNode: (OPENode *) node withChangeset: (NSInteger) changesetNumber
{
    double lat = node.coordinate.latitude;
    double lon = node.coordinate.longitude;
    NSLog(@"upload lat: %f",lat);
    NSLog(@"upload lon: %f",lon);
    NSLog(@"changeset number: %d",changesetNumber);
    
    NSMutableData *nodeXML = [NSMutableData data];
    
    [nodeXML appendData: [[NSString stringWithFormat: @"<?xml version=\"1.0\" encoding=\"UTF-8\" ?>"] dataUsingEncoding: NSUTF8StringEncoding]];
    [nodeXML appendData: [[NSString stringWithFormat: @"<osm version=\"0.6\" generator=\"OSMPOIEditor\">"] dataUsingEncoding: NSUTF8StringEncoding]];
    [nodeXML appendData: [[NSString stringWithFormat: @"<node id=\"%d\" lat=\"%f\" lon=\"%f\" version=\"%d\" changeset=\"%d\">",node.ident,lat,lon,node.version, changesetNumber] dataUsingEncoding: NSUTF8StringEncoding]];
    
    for (NSString *k in node.tags)
    {
        [nodeXML appendData: [[NSString stringWithFormat: @"<tag k=\"%@\" v=\"%@\"/>",k,[node.tags objectForKey:k]] dataUsingEncoding: NSUTF8StringEncoding]];
    }
    
    [nodeXML appendData: [[NSString stringWithFormat: @"</node>"] dataUsingEncoding: NSUTF8StringEncoding]];
    [nodeXML appendData: [[NSString stringWithFormat: @"</osm>"] dataUsingEncoding: NSUTF8StringEncoding]];
    
    NSLog(@"Node Data: %@",[[NSString alloc] initWithData:nodeXML encoding:NSUTF8StringEncoding]);
    
    NSURL * url = [NSURL URLWithString:[NSString stringWithFormat:@"http://api.openstreetmap.org/api/0.6/node/%d",node.ident]];
    NSLog(@"URL: %@",[url absoluteURL]);
    NSMutableURLRequest * urlRequest = [NSMutableURLRequest requestWithURL:url];
    [urlRequest setHTTPBody: nodeXML];
    [urlRequest setHTTPMethod: @"PUT"];
    [auth authorizeRequest:urlRequest];
    NSData *returnData = [NSURLConnection sendSynchronousRequest: urlRequest returningResponse: nil error: nil];
    //NSData * returnData = nil;
    NSLog(@"Return Data: %@",[[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding]);
    return [[[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding] intValue];
    
}

- (int) createXmlNode: (OPENode *) node withChangeset: (NSInteger) changesetNumber
{
    double lat = node.coordinate.latitude;
    double lon = node.coordinate.longitude;
    NSLog(@"upload lat: %f",lat);
    NSLog(@"upload lon: %f",lon);
    NSLog(@"changeset number: %d",changesetNumber);
    
    NSMutableData *nodeXML = [NSMutableData data];
    
    [nodeXML appendData: [[NSString stringWithFormat: @"<?xml version=\"1.0\" encoding=\"UTF-8\" ?>"] dataUsingEncoding: NSUTF8StringEncoding]];
    [nodeXML appendData: [[NSString stringWithFormat: @"<osm version=\"0.6\" generator=\"OSMPOIEditor\">"] dataUsingEncoding: NSUTF8StringEncoding]];
    [nodeXML appendData: [[NSString stringWithFormat: @"<node lat=\"%f\" lon=\"%f\" changeset=\"%d\">",lat,lon, changesetNumber] dataUsingEncoding: NSUTF8StringEncoding]];
    
    for (NSString *k in node.tags)
    {
        [nodeXML appendData: [[NSString stringWithFormat: @"<tag k=\"%@\" v=\"%@\"/>",k,[node.tags objectForKey:k]] dataUsingEncoding: NSUTF8StringEncoding]];
    }
    
    [nodeXML appendData: [[NSString stringWithFormat: @"</node>"] dataUsingEncoding: NSUTF8StringEncoding]];
    [nodeXML appendData: [[NSString stringWithFormat: @"</osm>"] dataUsingEncoding: NSUTF8StringEncoding]];
    
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
    
- (int) deleteXmlNode: (OPENode *) node withChangeset: (NSInteger) changesetNumber
{
    double lat = node.coordinate.latitude;
    double lon = node.coordinate.longitude;
    NSLog(@"upload lat: %f",lat);
    NSLog(@"upload lon: %f",lon);
    NSLog(@"changeset number: %d",changesetNumber);
    
    NSMutableData *nodeXML = [NSMutableData data];
    
    [nodeXML appendData: [[NSString stringWithFormat: @"<?xml version=\"1.0\" encoding=\"UTF-8\" ?>"] dataUsingEncoding: NSUTF8StringEncoding]];
    [nodeXML appendData: [[NSString stringWithFormat: @"<osm version=\"0.6\" generator=\"OSMPOIEditor\">"] dataUsingEncoding: NSUTF8StringEncoding]];
    [nodeXML appendData: [[NSString stringWithFormat: @"<node id=\"%d\" lat=\"%f\" lon=\"%f\" version=\"%d\" changeset=\"%d\"/>",node.ident,lat,lon,node.version, changesetNumber] dataUsingEncoding: NSUTF8StringEncoding]];
    [nodeXML appendData: [[NSString stringWithFormat: @"</osm>"] dataUsingEncoding: NSUTF8StringEncoding]];
    
    NSLog(@"Node Data: %@",[[NSString alloc] initWithData:nodeXML encoding:NSUTF8StringEncoding]);
    
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
+(NSString *)backToHTML:(NSString *)string
{
    
    string = [string stringByReplacingOccurrencesOfString:@"&" withString:@"&amp;"];
    return string;
}


+(NSString *)HTMLFix:(NSString *)string
{
    string = [string stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"];
    //string = [string stringByReplacingOccurrencesOfString:@"&apos;" withString:@"'"];
    //string = [string stringByReplacingOccurrencesOfString:@"&quot;" withString:@"\""];
    //string = [string stringByReplacingOccurrencesOfString:@"&lt;" withString:@"<"];
    //string = [string stringByReplacingOccurrencesOfString:@"&gt;" withString:@">"];
    return string;

}
@end
