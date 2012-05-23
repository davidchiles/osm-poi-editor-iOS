//
//  OPETagValueList.h
//  OSM POI Editor
//
//  Created by David Chiles on 4/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OPETextEdit.h"

@interface OPETagValueList : UITableViewController 

@property (nonatomic, strong) NSDictionary * values;
@property (nonatomic, strong) NSArray * valuesCheckmarkArray;
@property (nonatomic, strong) NSMutableArray * selectedArray;
@property (nonatomic, strong) NSArray * osmValues;
@property (nonatomic, strong) NSString * osmKey;
@property (nonatomic, strong) NSString * osmValue;
@property (nonatomic, strong) id <editTagDelegate> delegate;


@end
