//
//  OPENode.m
//  OSM POI Editor
//
//  Created by David Chiles on 2/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "OPENode.h"
#import "OPEConstants.h"

@implementation OPENode

@synthesize ident, coordinate, tags, version, image;

-(id) initWithId: (int) i coordinate: (CLLocationCoordinate2D) newCoordinate keyValues: (NSMutableDictionary *) tag
{
    self = [super init];
    if(self)
    {
        ident = i;
        coordinate = newCoordinate;
        tags = [[NSMutableDictionary alloc] initWithDictionary:tag];
        image = [[NSString alloc] init];
    }
    return self;
    
}

-(id) initWithId:(int)i latitude:(double) la longitude:(double) lo
{
    self = [super init];
    if (self)
    {
        ident = i;
        coordinate = CLLocationCoordinate2DMake(la,lo);
        tags = [[NSMutableDictionary alloc] init];
        image = [[NSString alloc] init];
    }
    return self;
}

-(id) initWithId:(int)i latitude:(double) la longitude:(double) lo version: (int) v
{
    self = [super init];
    if (self)
    {
        version = v;
        ident = i;
        coordinate = CLLocationCoordinate2DMake(la,lo);
        tags = [[NSMutableDictionary alloc] init];
        image = [[NSString alloc] init];
    }
    return self;
}

-(id) initWithNode: (OPENode *) node
{
    self = [super init];
    if (self)
    {
        version = node.version;
        ident = node.ident;
        coordinate = CLLocationCoordinate2DMake(node.coordinate.latitude, node.coordinate.longitude);
        tags = [[NSMutableDictionary alloc] initWithDictionary:node.tags];
        image = node.image;
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

-(void) addKey:(NSString *)key value:(NSString *)value
{
    [self.tags setValue:value forKey:key];
}

-(NSString *)name
{
    if(tags)
    {
        NSString* name = [tags objectForKey:@"name"];
        if(name)
            return name;
        else
            return @"no name";
    }
    else
        return @"no name";
}

-(BOOL)onlyTagCreatedBy
{
    if(tags.count == 1)
    {
        for(NSString * key in tags)
        {
            if(key == @"created_by")
                return YES;
            else
                return NO;
        }
    }
    else
        return NO;
    
    return NO;
}

-(BOOL) isequaltToPoint:(id<OPEPoint>)point
{
    if(self.ident != point.ident)
        return NO;
    else if (self.coordinate.latitude != point.coordinate.latitude)
        return NO;
    else if (self.coordinate.longitude != point.coordinate.longitude)
        return NO;
    else if (![self.tags isEqualToDictionary:point.tags])
        return NO;
    
    return YES;
    
}

- (NSString *) exportXMLforChangset: (NSInteger) changesetNumber
{
    NSMutableString * xml = [NSMutableString stringWithFormat: @"<?xml version=\"1.0\" encoding=\"UTF-8\" ?>"];
    [xml appendString:@"<osm version=\"0.6\" generator=\"OSMPOIEditor\">"];
    [xml appendFormat:@"<node id=\"%d\" lat=\"%f\" lon=\"%f\" version=\"%d\" changeset=\"%d\">",self.ident,self.coordinate.latitude,self.coordinate.longitude,self.version, changesetNumber];
    
    for(NSString * key in self.tags)
    {
        [xml appendFormat:@"<tag k=\"%@\" v=\"%@\"/>",key,[self.tags objectForKey:key]];
    }
    [xml appendFormat: @"</node> @</osm>"];
    
    
    return xml;
}

-(NSString *)type
{
    return kPointTypeNode;
}

-(BOOL)hasNoTags
{
    if(![self.tags count])
    {
        return YES;
    }
    return NO;
}

-(NSString *)description{
    return [NSString stringWithFormat:@"%@: %@",[self uniqueIdentifier],self.tags];
}

-(NSString *)uniqueIdentifier
{
    return [NSString stringWithFormat:@"%@%d",[self type],self.ident];
}
+(NSString *)uniqueIdentifierForID:(int)ident
{
    return [NSString stringWithFormat:@"%@%d",kPointTypeNode,ident];
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

@end
