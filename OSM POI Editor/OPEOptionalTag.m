//
//  OPEOptionalTag.m
//  OSM POI Editor
//
//  Created by David Chiles on 7/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "OPEOptionalTag.h"
#import "OPEConstants.h"

@implementation OPEOptionalTag

@synthesize name,osmKey,section,sectionSortOrder,possibleValues,displayType,displayName;

-(id)initWithName:(NSString *)newName dictionary:(NSDictionary *)dict
{
    self = [super init];
    if(self)
    {
        self.name = newName;
        self.displayName = [dict objectForKey:@"name"];
        self.osmKey = [dict objectForKey:@"osmKey"];
        self.section = [dict objectForKey:@"section"];
        self.sectionSortOrder = [dict objectForKey:@"section_order"];
        
        if([[dict objectForKey:@"values"] isKindOfClass:[NSString class]])
        {
            self.displayType = [dict objectForKey:@"values"];
        }
        else
        {
            self.displayType = kTypeList;
            self.possibleValues = [dict objectForKey:@"values"];
        }
            
    }
    return self;
}


@end
