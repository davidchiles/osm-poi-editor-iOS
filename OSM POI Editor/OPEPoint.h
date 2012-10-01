//
//  OPEPoint.h
//  OSM POI Editor
//
//  Created by David Chiles on 7/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TBXML.h"
#import "CoreLocation/CoreLocation.h"

@protocol OPEPoint <NSObject>


@property (nonatomic,assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, strong) NSMutableDictionary* tags;
@property int version;
@property (nonatomic, strong) NSString * image;
@property int ident;

- (void) addKey: (NSString *) key value: (NSString *)value;
- (NSString *) name;
- (BOOL) isequaltToPoint:(id <OPEPoint>)point;
- (NSString *)type;
- (NSString *)uniqueIdentifier;
- (BOOL)hasNoTags;


- (NSData *) updateXMLforChangset: (NSInteger) changesetNumber;



- (id)copy;

+ (NSString *)uniqueIdentifierForID:(int)ident;

@optional
- (NSData *) createXMLforChangset: (NSInteger) changesetNumber;
- (NSData *) deleteXMLforChangset: (NSInteger) changesetNumber;
@end
