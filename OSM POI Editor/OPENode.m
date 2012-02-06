//
//  OPENode.m
//  OSM POI Editor
//
//  Created by David Chiles on 2/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "OPENode.h"

@implementation OPENode

@synthesize ident, coordinates, tags;

-(id) initWithId: (int) i coordinates: (CLLocation *) coordinate keyValues: (NSMutableDictionary *) tag
{
    self = [super init];
    if(self)
    {
        ident = i;
        coordinates = coordinate;
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
        coordinates = [[CLLocation alloc] initWithLatitude:la longitude:lo];
        tags = [[NSMutableDictionary alloc] init];
    }
    return self;
}

-(void)addKey: (NSString*) key Value: (NSString*) val
{
    [tags setValue:val forKey:key];
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
