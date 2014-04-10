//
//  OSMData.h
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

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "AFNetworking.h"

#import "OSMDatabaseManager.h"
#import "OPEReferencePoi.h"
#import "OPEOSMAPIManager.h"

@class OPEOsmNode;
@class OPEOsmElement;
@class OPEOsmRelation;
@class OPEOsmWay;
@class OPEChangeset;

@interface OPEOSMData : NSObject

@property (nonatomic, strong) FMDatabaseQueue * databaseQueue;

- (void)findType:(NSArray *)elements completion:(void (^)(NSArray * foundElements))completion;
- (BOOL)isNoNameStreet:(OPEOsmWay *)way;

- (NSString *)changesetCommentfor:(OPEOsmElement *)element;
- (NSString *)nameWithElement:(OPEOsmElement *) element;

-(void)removeOsmKey:(NSString *)osmKey forElement:(OPEOsmElement *)element;
-(void)setOsmKey:(NSString *)osmKey andValue:(NSString *)osmValue forElement:(OPEOsmElement *)element;
-(void)setNewType:(OPEReferencePoi *)type forElement:(OPEOsmElement *)element;
-(void)getMetaDataForType:(OPEReferencePoi *)poi;
-(void)getTagsForType:(OPEReferencePoi *)poi;

-(void)getTypeFor:(OPEOsmElement *)element;
-(NSString *)nameForElement:(OPEOsmElement *)element;
-(CLLocationCoordinate2D)centerForElement:(OPEOsmElement *)element;
-(NSArray *)pointsForWay:(OPEOsmWay *)way;
-(NSArray *)outerPolygonsForRelation:(OPEOsmRelation *)relation;
-(NSArray *)innerPolygonsForRelation:(OPEOsmRelation *)relation;
-(NSArray *)allMembersOfRelation:(OPEOsmRelation *)relation;
-(void)getTagsForElement:(OPEOsmElement *)element;
-(void)updateLegacyTags:(OPEOsmElement *)element;

-(void)updateElements:(NSArray *)elementsArray;

-(void)getOptionalsFor:(OPEReferencePoi *)poi;
-(NSDictionary *)optionalSectionSortOrder;

-(NSArray *)allSortedCategories;
-(NSArray *)allSortedTypesWithCategory:(NSString *)category;
-(NSArray *)allTypesIncludeLegacy:(BOOL)includeLegacy;

-(int64_t)newElementId;
-(BOOL)hasParentElement:(OPEOsmElement *)element;
-(NSString *)highwayTypeForOsmWay:(OPEOsmWay *)way;

-(void)saveDate:(NSDate *)date forType:(OPEReferencePoi *)poi;
-(BOOL)isArea:(OPEOsmElement *)element;

-(OSMNote *)createNoteWithJSONDictionary:(NSDictionary *)noteDictionary;

-(NSArray *)allElementsWithType:(BOOL)withType;

@end
