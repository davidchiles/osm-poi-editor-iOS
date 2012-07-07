//
//  OPEWay.h
//  OSM POI Editor
//
//  Created by David Chiles on 7/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "OPENode.h"

@interface OPEWay : OPENode

@property (nonatomic,strong) NSArray * nodes;


-(id)initWithArrayOfNodes:(NSArray *)arrayOfNodes tags:(NSMutableDictionary *)tagDictioanry ID: (int) i version:(int) version ;
-(id)initWithArrayOfNodes:(NSArray *)arrayOfNodes ID: (int) i version:(int) version ;


@end
