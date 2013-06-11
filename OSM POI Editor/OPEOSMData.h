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

@class OPEManagedOsmNode;
@class OPEManagedOsmElement;
@class OPEManagedOsmRelation;
@class OPEManagedOsmWay;
@class OPEChangeset;

@protocol OPEOSMDataControllerDelegate <NSObject>

@optional
-(void)didOpenChangeset:(int64_t)changesetNumber withMessage:(NSString *)message;
-(void)didCloseChangeset:(int64_t)changesetNumber;
-(void)uploadFailed:(NSError *)error;

-(void)willStartDownloading;
-(void)didEndDownloading;

-(void)willStartParsing:(NSString *)typeString;
-(void)didEndParsing:(NSString *)typeString;
-(void)didEndParsing;

-(void) downloadFailed:(NSError *)error;

-(void) didFindNewElements:(NSArray *)newElementsArray updatedElements:(NSArray *)updatedElementsArray;

@end

@interface OPEOSMData : NSObject <OSMDAODelegate>
{
    dispatch_queue_t q;
    NSMutableDictionary * typeDictionary;
}

@property (nonatomic, strong) GTMOAuthAuthentication * auth;
@property (nonatomic, weak) id <OPEOSMDataControllerDelegate> delegate;
@property (nonatomic,strong) FMDatabaseQueue * databaseQueue;
@property (nonatomic,strong) AFHTTPClient * httpClient;

- (void) getDataWithSW:(CLLocationCoordinate2D)southWest NE: (CLLocationCoordinate2D) northEast;
- (void) openChangeset:(OPEChangeset *)changeset;
- (void) closeChangeset: (int64_t) changesetNumber;

- (void) uploadElement: (OPEManagedOsmElement *) element;
- (void) deleteElement: (OPEManagedOsmElement *) element;

- (NSString *)nameWithElement: (OPEManagedOsmElement *) element;

-(void)removeOsmKey:(NSString *)osmKey forElement:(OPEManagedOsmElement *)element;
-(void)setOsmKey:(NSString *)osmKey andValue:(NSString *)osmValue forElement:(OPEManagedOsmElement *)element;
-(void)setNewType:(OPEManagedReferencePoi *)type forElement:(OPEManagedOsmElement *)element;
-(void)getTagsForType:(OPEManagedReferencePoi *)poi;

-(void)getTypeFor:(OPEManagedOsmElement *)element;
-(NSString *)nameForElement:(OPEManagedOsmElement *)element;
-(CLLocationCoordinate2D)centerForElement:(OPEManagedOsmElement *)element;
-(NSArray *)pointsForWay:(OPEManagedOsmWay *)way;
-(NSArray *)outerPolygonsForRelation:(OPEManagedOsmRelation *)relation;
-(NSArray *)innerPolygonsForRelation:(OPEManagedOsmRelation *)relation;
-(void)getTagsForElement:(OPEManagedOsmElement *)element;
-(void)updateLegacyTags:(OPEManagedOsmElement *)element;

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



-(NSArray *)allElementsWithType:(BOOL)withType;

-(BOOL) canAuth;

+(GTMOAuthAuthentication *)osmAuth;

@end
