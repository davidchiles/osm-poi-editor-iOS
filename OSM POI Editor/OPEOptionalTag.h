//
//  OPEOptionalTag.h
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

#import <Foundation/Foundation.h>

@interface OPEOptionalTag : NSObject

@property (nonatomic,strong) NSString * displayName;
@property (nonatomic,strong) NSString * name;
@property (nonatomic,strong) NSString * osmKey;
@property (nonatomic,strong) NSString * section;
@property (nonatomic,strong) NSNumber * sectionSortOrder;
@property (nonatomic,strong) NSDictionary * possibleValues;
@property (nonatomic,strong) NSString * displayType;



-(id)initWithName:(NSString *)name dictionary:(NSDictionary *)dict;


@end
