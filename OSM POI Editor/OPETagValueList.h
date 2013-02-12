//
//  OPETagValueList.h
//  OSM POI Editor
//
//  Created by David Chiles on 4/16/12.
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

#import <UIKit/UIKit.h>
#import "OPETextEdit.h"

@interface OPETagValueList : UITableViewController 

@property (nonatomic, strong) NSArray * valuesArray;
@property (nonatomic, strong) NSArray * valuesCheckmarkArray;
@property (nonatomic, strong) NSMutableArray * selectedArray;
@property (nonatomic, strong) NSArray * osmValues;
@property (nonatomic, strong) NSString * osmKey;
@property (nonatomic, strong) NSString * osmValue;
@property (nonatomic, strong) id <editTagDelegate> delegate;

@property (nonatomic, strong) NSManagedObjectID * referenceOptionalID;


@end
