//
//  OPETagInterpreter.h
//  OSM POI Editor
//
//  Created by David Chiles on 2/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OPENode.h"
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
- (NSString *) category: (OPENode *)n; //getCategory
- (OPEType *) type: (OPENode *)n; //getType
- (void) readPlist;
- (NSString *) getName: (OPENode *) node;
- (NSString *) getImageForNode: (OPENode *) node;
- (void)removeTagsForType:(OPEType *)type withNode:(OPENode *)node;
- (BOOL)isSupported:(OPENode *)node;
- (NSDictionary *) allCategories;
- (NSDictionary *) allTypes;

//- (NSDictionary *)getCategoryandType:(OPENode *)node;
//- (NSDictionary *) getOSmKeysValues: (NSDictionary *) catAndType;

+ (NSArray *) getOptionalTagsDictionaries: (NSArray *) array;
+ (OPETagInterpreter *)sharedInstance;

@end
