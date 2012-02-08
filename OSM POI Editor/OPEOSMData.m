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
    }
    allNodes = [[NSMutableDictionary alloc] init];
    return self;
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    // Use when fetching text data
    //NSString *responseString = [request responseString];
    
    // Use when fetching binary data
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
            
            double ident = [identS doubleValue];
            double lat = [latS doubleValue];
            double lon = [lonS doubleValue];
            
            OPENode * newNode = [[OPENode alloc] initWithId:ident latitude:lat longitude:lon];
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
    NSURL* url = [NSURL URLWithString: [NSString stringWithFormat:@"http://www.overpass-api.de/api/xapi?node[amenity=*][bbox=%f,%f,%f,%f]",bboxleft,bboxbottom,bboxright,bboxtop]];
    NSLog(@"url: %@",[url absoluteString]);
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [request setDelegate:self];
    [request startAsynchronous];
    
        
    
    
}



@end
