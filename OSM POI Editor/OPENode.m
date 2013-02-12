//
//  OPENode.m
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

#import "OPENode.h"
#import "OPEConstants.h"
#import "OPETagInterpreter.h"

@implementation OPENode

-(id) initWithId: (int64_t) i coordinate: (CLLocationCoordinate2D) newCoordinate keyValues: (NSMutableDictionary *) tag
{
    self = [super init];
    if(self)
    {
        self.ident = i;
        self.coordinate = newCoordinate;
        self.tags = [[NSMutableDictionary alloc] initWithDictionary:tag];
        self.image = [[NSString alloc] init];
    }
    return self;
    
}

-(id) initWithId:(int64_t)i latitude:(double) la longitude:(double) lo
{
    self = [super init];
    if (self)
    {
        self.ident = i;
        self.coordinate = CLLocationCoordinate2DMake(la,lo);
        self.tags = [[NSMutableDictionary alloc] init];
        self.image = [[NSString alloc] init];
    }
    return self;
}

-(id) initWithId:(int64_t)i latitude:(double) la longitude:(double) lo version: (int) v
{
    self = [super init];
    if (self)
    {
        self.version = v;
        self.ident = i;
        self.coordinate = CLLocationCoordinate2DMake(la,lo);
        self.tags = [[NSMutableDictionary alloc] init];
        self.image = [[NSString alloc] init];
    }
    return self;
}

-(id) initWithNode: (OPENode *) node
{
    self = [super init];
    if (self)
    {
        self.version = node.version;
        self.ident = node.ident;
        self.coordinate = CLLocationCoordinate2DMake(node.coordinate.latitude, node.coordinate.longitude);
        self.tags = [[NSMutableDictionary alloc] initWithDictionary:node.tags];
        self.image = node.image;
    }
    return self;
}

+ (id) createPointWithXML:(TBXMLElement *)xml
{
    NSString* identString = [TBXML valueOfAttributeNamed:@"id" forElement:xml];
    NSString* latString = [TBXML valueOfAttributeNamed:@"lat" forElement:xml];
    NSString* lonString = [TBXML valueOfAttributeNamed:@"lon" forElement:xml];
    NSString* verString = [TBXML valueOfAttributeNamed:@"version" forElement:xml];
    
    double ident = [identString doubleValue];
    double lat = [latString doubleValue];
    double lon = [lonString doubleValue];
    int ver = [verString intValue];
    
    OPENode * newNode = [[OPENode alloc] initWithId:ident latitude:lat longitude:lon version:ver];
    
    TBXMLElement* tag = [TBXML childElementNamed:@"tag" parentElement:xml];
    
    while (tag!=nil) //Takes in tags and adds them to newNode
    {
        NSString* key = [TBXML valueOfAttributeNamed:@"k" forElement:tag];
        NSString* value = [TBXML valueOfAttributeNamed:@"v" forElement:tag];
        [newNode.tags setObject:value forKey:key];
        tag = [TBXML nextSiblingNamed:@"tag" searchFromElement:tag];
    }
    
    return newNode;
}

- (NSData *) updateXMLforChangset: (NSInteger) changesetNumber
{
    NSMutableString * xml = [NSMutableString stringWithFormat: @"<?xml version=\"1.0\" encoding=\"UTF-8\" ?>"];
    [xml appendString:@"<osm version=\"0.6\" generator=\"OSMPOIEditor\">"];
    [xml appendFormat:@"<node id=\"%lld\" lat=\"%f\" lon=\"%f\" version=\"%d\" changeset=\"%d\">",self.ident,self.coordinate.latitude,self.coordinate.longitude,self.version, changesetNumber];
    
    for(NSString * key in self.tags)
    {
        [xml appendFormat:@"<tag k=\"%@\" v=\"%@\"/>",key,[self.tags objectForKey:key]];
    }
    [xml appendFormat: @"</node> @</osm>"];
    
    
    return [xml dataUsingEncoding:NSUTF8StringEncoding];
}

- (NSData *) createXMLforChangset: (NSInteger) changesetNumber
{
    double lat = self.coordinate.latitude;
    double lon = self.coordinate.longitude;
    NSLog(@"upload lat: %f",lat);
    NSLog(@"upload lon: %f",lon);
    NSLog(@"changeset number: %d",changesetNumber);
    
    NSMutableData *nodeXML = [NSMutableData data];
    
    [nodeXML appendData: [[NSString stringWithFormat: @"<?xml version=\"1.0\" encoding=\"UTF-8\" ?>"] dataUsingEncoding: NSUTF8StringEncoding]];
    [nodeXML appendData: [[NSString stringWithFormat: @"<osm version=\"0.6\" generator=\"OSMPOIEditor\">"] dataUsingEncoding: NSUTF8StringEncoding]];
    [nodeXML appendData: [[NSString stringWithFormat: @"<node lat=\"%f\" lon=\"%f\" changeset=\"%d\">",lat,lon, changesetNumber] dataUsingEncoding: NSUTF8StringEncoding]];
    
    for (NSString *k in self.tags)
    {
        [nodeXML appendData: [[NSString stringWithFormat: @"<tag k=\"%@\" v=\"%@\"/>",k,[self.tags objectForKey:k]] dataUsingEncoding: NSUTF8StringEncoding]];
    }
    
    [nodeXML appendData: [[NSString stringWithFormat: @"</node>"] dataUsingEncoding: NSUTF8StringEncoding]];
    [nodeXML appendData: [[NSString stringWithFormat: @"</osm>"] dataUsingEncoding: NSUTF8StringEncoding]];
    
    return nodeXML;
    
}

- (NSData *) deleteXMLforChangset: (NSInteger) changesetNumber
{
    double lat = self.coordinate.latitude;
    double lon = self.coordinate.longitude;
    NSLog(@"upload lat: %f",lat);
    NSLog(@"upload lon: %f",lon);
    NSLog(@"changeset number: %d",changesetNumber);
    
    NSMutableData *nodeXML = [NSMutableData data];
    
    [nodeXML appendData: [[NSString stringWithFormat: @"<?xml version=\"1.0\" encoding=\"UTF-8\" ?>"] dataUsingEncoding: NSUTF8StringEncoding]];
    [nodeXML appendData: [[NSString stringWithFormat: @"<osm version=\"0.6\" generator=\"OSMPOIEditor\">"] dataUsingEncoding: NSUTF8StringEncoding]];
    [nodeXML appendData: [[NSString stringWithFormat: @"<node id=\"%lld\" lat=\"%f\" lon=\"%f\" version=\"%d\" changeset=\"%d\"/>",self.ident,lat,lon,self.version, changesetNumber] dataUsingEncoding: NSUTF8StringEncoding]];
    [nodeXML appendData: [[NSString stringWithFormat: @"</osm>"] dataUsingEncoding: NSUTF8StringEncoding]];
    
    return nodeXML;
    
}

-(NSString *)type
{
    return kPointTypeNode;
}

-(id)copy
{
    OPENode * nodeCopy = [[OPENode alloc] init];
    nodeCopy.coordinate = self.coordinate;
    nodeCopy.ident = self.ident;
    nodeCopy.tags = [self.tags mutableCopy];
    nodeCopy.version = self.version;
    nodeCopy.image = [self.image mutableCopy];
    
    return nodeCopy;
}

+ (NSString *)uniqueIdentifierForID:(int)ident
{
    return [NSString stringWithFormat:@"%@%d",kPointTypeNode,ident];
}

@end
