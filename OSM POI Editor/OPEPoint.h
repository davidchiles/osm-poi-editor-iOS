//
//  OPEPoint.h
//  OSM POI Editor
//
//  Created by David Chiles on 7/10/12.
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
#import "TBXML.h"
#import "CoreLocation/CoreLocation.h"

@interface OPEPoint : NSObject

@property (nonatomic,assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, strong) NSMutableDictionary* tags;
@property int version;
@property (nonatomic, strong) NSString * image;
@property int ident;
@property (nonatomic,strong) NSString * name;

- (void) addKey: (NSString *) key value: (NSString *)value;
- (BOOL) isequaltToPoint:(OPEPoint*)point;
- (NSString *)type;
- (NSString *)uniqueIdentifier;
- (BOOL)hasNoTags;
- (NSData *) updateXMLforChangset: (NSInteger) changesetNumber;
- (id)copy;
- (NSData *) createXMLforChangset: (NSInteger) changesetNumber;
- (NSData *) deleteXMLforChangset: (NSInteger) changesetNumber;

+ (NSString *)uniqueIdentifierForID:(int)ident;


@end
