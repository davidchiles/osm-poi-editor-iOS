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

@property (nonatomic, retain) NSMutableDictionary * categoryAndType;
@property (nonatomic, retain) NSMutableDictionary * osmKeyandValue;
@property (nonatomic, retain) NSMutableDictionary * osmKVandCategoryType;

- (id) init;
- (BOOL) nodeHasRecognizedTags:(OPENode *)n;
- (NSDictionary *) getPrimaryKeyValue: (OPENode *)n;
- (NSString *) getCategory: (OPENode *)n;
- (NSString *) getType: (OPENode *)n;
- (NSArray *) getOsmKeyValue: (NSDictionary *) catAndTyp;
- (void) readPlist;

+(OPETagInterpreter *)sharedInstance;

@end
