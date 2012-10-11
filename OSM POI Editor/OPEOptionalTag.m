//
//  OPEOptionalTag.m
//  OSM POI Editor
//
//  Created by David Chiles on 7/23/12.
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
