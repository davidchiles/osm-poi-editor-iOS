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

@property (nonatomic, retain) NSDictionary * categoryAndType;
@property (nonatomic, retain) NSDictionary * osmKeyandValue;

- (id) init;
- (BOOL) nodeHasRecognizedTags:(OPENode *)node;
- (void) readPlist;

@end
