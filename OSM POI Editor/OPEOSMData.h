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
#import "GTMOAuthViewControllerTouch.h"
#import "AFNetworking.h"
#import "FMDatabaseQueue.h"
#import "OSMDAO.h"
#import "OPEManagedReferencePoi.h"
#import "OPEOSMAPIManager.h"

@class OPEManagedOsmNode;
@class OPEManagedOsmElement;
@class OPEManagedOsmRelation;
@class OPEManagedOsmWay;
@class OPEChangeset;

@interface OPEOSMData : NSObject <OSMDAODelegate>
{
    NSMutableDictionary * typeDictionary;
    OPEOSMAPIManager * apiManager;
}

@property (nonatomic,strong) FMDatabaseQueue * databaseQueue;


-(BOOL)findType:(OPEManagedOsmElement *)element;
-(BOOL)isNoNameStreet:(OPEManagedOsmWay *)way;

- (NSString *)changesetCommentfor:(OPEManagedOsmElement *)element;
- (NSString *)nameWithElement: (OPEManagedOsmElement *) element;

-(void)removeOsmKey:(NSString *)osmKey forElement:(OPEManagedOsmElement *)element;
-(void)setOsmKey:(NSString *)osmKey andValue:(NSString *)osmValue forElement:(OPEManagedOsmElement *)element;
-(void)setNewType:(OPEManagedReferencePoi *)type forElement:(OPEManagedOsmElement *)element;
-(void)getMetaDataForType:(OPEManagedReferencePoi *)poi;
-(void)getTagsForType:(OPEManagedReferencePoi *)poi;

-(void)getTypeFor:(OPEManagedOsmElement *)element;
-(NSString *)nameForElement:(OPEManagedOsmElement *)element;
-(CLLocationCoordinate2D)centerForElement:(OPEManagedOsmElement *)element;
-(NSArray *)pointsForWay:(OPEManagedOsmWay *)way;
-(NSArray *)outerPolygonsForRelation:(OPEManagedOsmRelation *)relation;
-(NSArray *)innerPolygonsForRelation:(OPEManagedOsmRelation *)relation;
-(NSArray *)allMembersOfRelation:(OPEManagedOsmRelation *)relation;
-(void)getTagsForElement:(OPEManagedOsmElement *)element;
-(void)updateLegacyTags:(OPEManagedOsmElement *)element;

-(void)updateElements:(NSArray *)elementsArray;

-(void)getOptionalsFor:(OPEManagedReferencePoi *)poi;
-(NSDictionary *)optionalSectionSortOrder;

-(NSArray *)allSortedCategories;
-(NSArray *)allSortedTypesWithCategory:(NSString *)category;
-(NSArray *)allTypesIncludeLegacy:(BOOL)includeLegacy;

-(int64_t)newElementId;
-(BOOL)hasParentElement:(OPEManagedOsmElement *)element;
-(NSString *)highwayTypeForOsmWay:(OPEManagedOsmWay *)way;

-(void)saveDate:(NSDate *)date forType:(OPEManagedReferencePoi *)poi;
-(BOOL)isArea:(OPEManagedOsmElement *)element;

-(Note *)createNoteWithJSONDictionary:(NSDictionary *)noteDictionary;

-(NSArray *)allElementsWithType:(BOOL)withType;

@end
