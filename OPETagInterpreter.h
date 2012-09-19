//
//  OPETagInterpreter.h
//  OSM POI Editor
//
//  Created by David Chiles on 2/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

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
+ (OPETagInterpreter *)sharedInstance;

@end
