//
//  OPETagInterpreter.h
//  OSM POI Editor
//
//  Created by David Chiles on 2/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OPENode.h"

@interface OPETagInterpreter : NSObject

@property (nonatomic, strong) NSMutableDictionary * categoryAndType;
@property (nonatomic, strong) NSMutableDictionary * osmKeyandValue;
@property (nonatomic, strong) NSMutableDictionary * osmKVandCategoryType;
@property (nonatomic, strong) NSMutableDictionary * CategoryTypeandOsmKV;
@property (nonatomic, strong) NSMutableDictionary * CategoryTypeandImg;
@property (nonatomic, strong) NSMutableDictionary * CategoryTypeandOptionalTags;

- (id) init;
//- (BOOL) nodeHasRecognizedTags:(OPENode *)n;
//- (NSDictionary *) getPrimaryKeyValue: (OPENode *)n;
- (NSString *) getCategory: (OPENode *)n;
- (NSString *) getType: (OPENode *)n;
- (void) readPlist;
- (NSString *) getName: (OPENode *) node;
- (NSString *) getImageForNode: (OPENode *) node;
- (void)removeCatAndType:(NSDictionary *) catType fromNode:(OPENode *)node;
- (NSDictionary *)getCategoryandType:(OPENode *)node;
- (NSDictionary *) getOSmKeysValues: (NSDictionary *) catAndType;

+ (NSArray *) getOptionalTagsDictionaries: (NSArray *) array;
+ (OPETagInterpreter *)sharedInstance;

@end
