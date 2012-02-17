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

@synthesize bboxleft, bboxbottom, bboxright, bboxtop, allNodes;


-(id) initWithLeft:(double) lef bottom: (double) bot right: (double) rig top: (double) to
{
    
    self = [super init];
    if(self)
    {
        bboxleft = lef;
        bboxbottom = bot;
        bboxright = rig;
        bboxtop = to;
        NSString *myConsumerKey = @"pJbuoc7SnpLG5DjVcvlmDtSZmugSDWMHHxr17wL3";    // pre-registered with service
        NSString *myConsumerSecret = @"q5qdc9DvnZllHtoUNvZeI7iLuBtp1HebShbCE9Y1"; // pre-assigned by service
        
        auth = [[GTMOAuthAuthentication alloc] initWithSignatureMethod:kGTMOAuthSignatureMethodHMAC_SHA1
                                                           consumerKey:myConsumerKey
                                                            privateKey:myConsumerSecret];
    }
    allNodes = [[NSMutableDictionary alloc] init];
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
        NSLog(@"Changeset finish: %@", [request responseString]);
        
    }
    
    if ([request.userInfo objectForKey:@"type"] == @"download" )
    {
        
        NSData *responseData = [request responseData];
        TBXML* tbxml = [TBXML tbxmlWithXMLData:responseData];
        
        TBXMLElement * root = tbxml.rootXMLElement;
        if(root)
        {
            NSLog(@"root: %@",[TBXML elementName:root]);
            NSLog(@"version: %@",[TBXML valueOfAttributeNamed:@"version" forElement:root]);
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
                
                [self.allNodes setObject:newNode forKey:[NSNumber numberWithInt:newNode.ident]];
                
                for (id key in newNode.tags) { //Used to Log all keys and values stored
                    
                    //NSLog(@"dkey: %@, dvalue: %@", key, [newNode.tags objectForKey:key]);
                }
                node = [TBXML nextSiblingNamed:@"node" searchFromElement:node];
            }
            NSLog(@"allNodes size: %d",[allNodes count]);
            for (id key in self.allNodes) {
                
                //NSLog(@"akey: %@, avalue: %@", key, [self.allNodes objectForKey:key]);
            }
            
        }
        
        
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"DownloadComplete"
         object:self];
    }

}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    NSError *error = [request error];
    if (error) {
        NSLog(@"Error Description: %@",error.description);
    }
}

-(void) getData
{
    NSLog(@"box: %f,%f,%f,%f",bboxleft,bboxbottom,bboxright,bboxtop);
    NSURL* url = [NSURL URLWithString: [NSString stringWithFormat:@"http://www.overpass-api.de/api/xapi?node[amenity=*][bbox=%f,%f,%f,%f][@meta]",bboxleft,bboxbottom,bboxright,bboxtop]];
    NSLog(@"url: %@",[url absoluteString]);
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    request.userInfo = [[NSDictionary alloc] initWithObjectsAndKeys:@"download",@"type", nil];
    [request setDelegate:self];
    [request startAsynchronous];
}

- (NSInteger) openChangeset
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
    [changeset appendData: [[NSString stringWithFormat: @"<tag k=\"comment\" v=\"NewChangeset\"/>"] dataUsingEncoding: NSUTF8StringEncoding]];
    [changeset appendData: [[NSString stringWithFormat: @"</changeset>"] dataUsingEncoding: NSUTF8StringEncoding]];
    [changeset appendData: [[NSString stringWithFormat: @"</osm>"] dataUsingEncoding: NSUTF8StringEncoding]];
    //[changeset appendData: [[NSString stringWithFormat: @"</xml>"] dataUsingEncoding: NSUTF8StringEncoding]];
    
    NSLog(@"Changeset Data: %@",[[NSString alloc] initWithData:changeset encoding:NSUTF8StringEncoding]);
    
    [urlRequest setHTTPBody: changeset];
    [urlRequest setHTTPMethod: @"PUT"];
    [auth authorizeRequest:urlRequest];
    NSData *returnData = [NSURLConnection sendSynchronousRequest: urlRequest returningResponse: nil error: nil];
    NSLog(@"Return Data: %@",[[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding]);
    
    
    return 0;
}

- (void) updateXmlNode: (OPENode *) node withChangeset: (NSInteger *) changesetNumber
{
    
    
}

- (void) createXmlNode: (OPENode *) node withChangeset: (NSInteger *) changesetNumber
{
    double lat = node.coordinate.latitude;
    double lon = node.coordinate.longitude;
    NSLog(@"upload lat: %f",lat);
    NSLog(@"upload lon: %f",lon);
    
    
    
    NSMutableData *nodeXML = [NSMutableData data];
    
    [nodeXML appendData: [[NSString stringWithFormat: @"<?xml version=\"1.0\" encoding=\"UTF-8\" ?>"] dataUsingEncoding: NSUTF8StringEncoding]];
    [nodeXML appendData: [[NSString stringWithFormat: @"<osm version=\"0.6\" generator=\"OSMPOIEditor\">"] dataUsingEncoding: NSUTF8StringEncoding]];
    [nodeXML appendData: [[NSString stringWithFormat: @"<node changeset=\"%d\" lat=\"%f\" lon=\"%f\">",changesetNumber,lat,lon] dataUsingEncoding: NSUTF8StringEncoding]];
    
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
    //NSData *returnData = [NSURLConnection sendSynchronousRequest: urlRequest returningResponse: nil error: nil];
    NSData * returnData = nil;
    NSLog(@"Return Data: %@",[[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding]);
    
}



@end
