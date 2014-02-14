//
//  OPEConstants.m
//  OSM POI Editor
//
//  Created by David Chiles on 4/19/12.
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
#import "OPEConstants.h"

NSString *const kTypeText = @"text";
NSString *const KTypeName = @"name";
NSString *const kTypeList = @"list";
NSString *const kTypeLabel = @"label";
NSString *const kTypeNumber = @"number";
NSString *const kTypeUrl = @"url";
NSString *const kTypePhone = @"phone";
NSString *const kTypeEmail = @"email";
NSString *const kTypeHours = @"hours";

NSUInteger const kLeftTextDefaultSize = 76;

NSString *const kOPEAPIURL2 = @"http://www.overpass-api.de/api/xapi?*";
NSString *const kOPEAPIURL4 = @"http://overpass.osm.rambler.ru/cgi/xapi?*";
NSString *const kOPEAPIURL3 = @"http://api.openstreetmap.fr/xapi?*";
NSString *const kOPEAPIURL1 = @"http://api.openstreetmap.org/api/0.6/";
NSString *const kOPEAPIURL5 = @"http://api.openstreetmap.fr/api/0.6/";

NSString *const kOPENominatimURL2 = @"http://open.mapquestapi.com/nominatim/v1/reverse.php";
NSString *const kOPENominatimURL1 = @"http://nominatim.openstreetmap.org/reverse";

NSString *const kPointTypeNode = @"node";
NSString *const kPointTypeWay = @"way";
NSString *const kPointTypePoint = @"point";

NSString *const kLastDownloadedKey = @"lastFileDownload";

NSString *const kLastImportHashKey = @"kLastImportHashKey";
NSString *const kLastImportFileDate = @"kLastImportFileDate";

NSString *const kActionTypeModify = @"update";
NSString *const kActionTypeDelete = @"delete";

NSString *const kOPEOsmElementNode = @"node";
NSString *const kOPEOsmElementWay = @"way";
NSString *const kOPEOsmElementRelation = @"relation";
NSString *const kOPEOsmElementNone = @"none";

//settings key
NSString *const kShowNoNameStreetsKey = @"kShowNoNameStreetsKey";
NSString *const kTileSourceNumber = @"tileSourceNumber";

NSString *const kOTRAppleLanguagesKey = @"AppleLanguages";
NSString *const kOTRUserSetLanguageKey = @"userSetLanguageKey";

@implementation OPEConstants

+ (NSArray *)expandedAddressArray
{
    static NSArray *typesArray = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        typesArray = @[@"addr:housenumber", @"addr:street", @"addr:city", @"addr:postcode", @"addr:state", @"addr:country", @"addr:province"];

    });
    return typesArray;
}
+ (NSArray *)expandedContactArray
{
    static NSArray *typesArray = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        typesArray = @[@"website", @"phone", @"fax", @"email", @"wikipedia", @"opening_hours"];
    });
    return typesArray;
}
+ (NSArray *)highwayTypesArray
{
    static NSArray *typesArray = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        typesArray = @[ @"residential", @"unclassified", @"track", @"tertiary", @"secondary", @"primary", @"trunk", @"footway", @"path", @"cycleway", @"steps", @"bridleway"];
    });
    return typesArray;
}
+ (NSString *)databasePath
{
    static NSString *path = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"spatialdb.sqlite"];
    });
    return path;
}
+ (UIColor *)appleBlueColor
{
    static UIColor *blueColor = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        blueColor = [UIColor colorWithRed:0 green:0.47843137 blue:1 alpha:1];

    });
    return blueColor;
}


@end
