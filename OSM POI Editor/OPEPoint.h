//
//  OPEPoint.h
//  OSM POI Editor
//
//  Created by David Chiles on 7/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TBXML.h"

@protocol OPEPoint <NSObject>

@property int ident;
@property (nonatomic) CLLocationCoordinate2D coordinate;
@property (nonatomic, strong) NSMutableDictionary* tags;
@property int version; 
@property (nonatomic, strong) NSString * image;

- (void) addKey: (NSString *) key value: (NSString *)value;
- (NSString *) name;
- (BOOL) isequaltToPoint:(id <OPEPoint>)point;
- (NSString *)type;
- (NSString *)uniqueIdentifier;

- (NSString *) exportXMLforChangset: (NSInteger) changesetNumber;
- (id)copy;

+ (NSString *)uniqueIdentifierForID:(int)ident;
@end
