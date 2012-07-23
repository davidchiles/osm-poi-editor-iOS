//
//  OPETag.h
//  OSM POI Editor
//
//  Created by David Chiles on 7/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OPETag : NSObject


@property (nonatomic,strong) NSDictionary * osmKeysAndValues;
@property (nonatomic,strong) NSString * imageName;
@property (nonatomic,strong) NSString * category;
@property (nonatomic,strong) NSString * type;
@property (nonatomic,strong) NSArray * optionalOsmTags;

@end
