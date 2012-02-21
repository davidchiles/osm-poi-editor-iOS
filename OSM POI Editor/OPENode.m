//
//  OPENode.m
//  OSM POI Editor
//
//  Created by David Chiles on 2/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "OPENode.h"

@implementation OPENode

@synthesize ident, coordinate, tags, version;

-(id) initWithId: (int) i coordinate: (CLLocationCoordinate2D) newCoordinate keyValues: (NSMutableDictionary *) tag
{
    self = [super init];
    if(self)
    {
        ident = i;
        coordinate = newCoordinate;
        tags = [[NSMutableDictionary alloc] initWithDictionary:tag];
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
    }
    return self;
}

-(void)addKey: (NSString*) key Value: (NSString*) val
{
    [tags setValue:val forKey:key];
}

-(NSString *)getName
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


@end
