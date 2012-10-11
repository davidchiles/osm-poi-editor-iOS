//
//  OPEType.m
//  OSM POI Editor
//
//  Created by David on 8/24/12.
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

#import "OPEType.h"

@implementation OPEType

@synthesize displayName;
@synthesize imageString;
@synthesize tags;
@synthesize optionalTags;
@synthesize categoryName;

-(id)initWithName:(NSString *)name categoryName:(NSString *)catName dictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if(self)
    {
        self.categoryName = catName;
        self.displayName = name;
        self.imageString = [dictionary objectForKey:@"image"];
        self.tags = [dictionary objectForKey:@"tags"];
        self.optionalTags = [dictionary objectForKey:@"optional"];
    }
    return self;
}

-(BOOL)isEqual:(OPEType *)otherType
{
    if ([self.categoryName isEqualToString:otherType.categoryName] && [self.displayName isEqualToString:otherType.displayName]) {
        return YES;
    }
    else
        return NO;
}

-(NSString *) description
{
    return [NSString stringWithFormat:@"Type: %@\nCategory: %@\nImage: %@Tags: %@",self.displayName,self.categoryName,self.imageString,self.tags];
}


@end
