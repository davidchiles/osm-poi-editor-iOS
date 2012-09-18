//
//  OPEOptionalTag.h
//  OSM POI Editor
//
//  Created by David Chiles on 7/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OPEOptionalTag : NSObject

@property (nonatomic,strong) NSString * displayName;
@property (nonatomic,strong) NSString * name;
@property (nonatomic,strong) NSString * osmKey;
@property (nonatomic,strong) NSString * section;
@property (nonatomic,strong) NSNumber * sectionSortOrder;
@property (nonatomic,strong) NSDictionary * possibleValues;
@property (nonatomic,strong) NSString * displayType;



-(id)initWithName:(NSString *)name dictionary:(NSDictionary *)dict;


@end
