//
//  OPETagInterpreter.h
//  OSM POI Editor
//
//  Created by David Chiles on 2/9/12.
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
#import "OPEpoint.h"
#import "OPECategory.h"
#import "OPEType.h"

@interface OPETagInterpreter : NSObject

@property (nonatomic, strong) NSMutableDictionary * nameAndCategory;
@property (nonatomic, strong) NSMutableDictionary * nameAndType;
@property (nonatomic, strong) NSMutableDictionary * osmKeyandValue;
@property (nonatomic, strong) NSMutableDictionary * osmKeyValueAndType;
@property (nonatomic, strong) NSMutableDictionary * typeAndOsmKeyValue;
@property (nonatomic, strong) NSMutableDictionary * typeAndImg;
@property (nonatomic, strong) NSMutableDictionary * typeandOptionalTags;

- (id) init;
//- (BOOL) nodeHasRecognizedTags:(OPENode *)n;
//- (NSDictionary *) getPrimaryKeyValue: (OPENode *)n;
- (NSString *) category: (id<OPEPoint>)n; //getCategory
- (OPEType *) type: (id<OPEPoint>)n; //getType
- (void) readPlist;
- (NSString *) getName: (id<OPEPoint>) node;
- (NSString *) getImageForNode: (id<OPEPoint>) node;
- (void)removeTagsForType:(OPEType *)type withNode:(id<OPEPoint>)node;
- (BOOL)isSupported:(id<OPEPoint>)node;
- (NSDictionary *) allCategories;
- (NSDictionary *) allTypes;

//- (NSDictionary *)getCategoryandType:(OPENode *)node;
//- (NSDictionary *) getOSmKeysValues: (NSDictionary *) catAndType;

+ (NSArray *) getOptionalTagsDictionaries: (NSArray *) array;
+ (NSArray *) getOptionalTagsKeys:(NSArray *)array;
+ (OPETagInterpreter *)sharedInstance;

@end
