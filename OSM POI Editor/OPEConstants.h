//
//  OPEConstants.h
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

typedef NS_ENUM(NSUInteger, OPEOptionalType){
    OPEOptionalTypeNone,
    OPEOptionalTypeList,
    OPEOptionalTypeText,
    OPEOptionalTypeName,
    OPEOptionalTypeLabel,
    OPEOptionalTypeNumber,
    OPEOptionalTypeUrl,
    OPEOptionalTypePhone,
    OPEOptionalTypeEmail,
    OPEOptionalTypeHours
};

extern NSString *const kTypeText;
extern NSString *const KTypeName;
extern NSString *const kTypeList;
extern NSString *const kTypeLabel;
extern NSString *const kTypeNumber;
extern NSString *const kTypeUrl;
extern NSString *const kTypePhone;
extern NSString *const kTypeEmail;
extern NSString *const kTypeHours;

extern NSUInteger const kLeftTextDefaultSize;

extern NSString *const kOPEAPIURL2;
extern NSString *const kOPEAPIURL1;
extern NSString *const kOPEAPIURL3;
extern NSString *const kOPEAPIURL4;
extern NSString *const kOPEAPIURL5;

extern NSString *const kOPENominatimURL2;
extern NSString *const kOPENominatimURL1;

extern NSString *const kPointTypeNode;
extern NSString *const kPointTypeWay;
extern NSString *const kPointTypePoint;

extern NSString *const kLastDownloadedKey;

extern NSString *const kLastImportHashKey;
extern NSString *const kLastImportFileDate;

extern NSString *const kActionTypeModify;
extern NSString *const kActionTypeDelete;

extern NSString *const kOPEOsmElementNode;
extern NSString *const kOPEOsmElementWay;
extern NSString *const kOPEOsmElementRelation;
extern NSString *const kOPEOsmElementNone;

//settings key
extern NSString *const kShowNoNameStreetsKey;
extern NSString *const kTileSourceNumber;

extern NSString *const kOTRAppleLanguagesKey;
extern NSString *const kOTRUserSetLanguageKey;

extern NSString *const kOPEUserOAuthTokenKey;

@interface OPEConstants : NSObject


+ (NSArray *)expandedAddressArray;
+ (NSArray *)expandedContactArray;
+ (NSArray *)highwayTypesArray;
+ (NSString *)databasePath;
+ (UIColor *)appleBlueColor;
                                      
@end
                                      
