//
//  OPETypeViewController.h
//  OSM POI Editor
//
//  Created by David Chiles on 2/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OPECategory.h"
#import "OPEType.h"

@protocol PassCategoryAndType <NSObject>
@required
- (void) setNewType:(OPEType *)type;
@end

@interface OPETypeViewController : UITableViewController

@property (nonatomic, strong) OPECategory * category;
@property (nonatomic, strong) NSArray * typeArray;
@property (nonatomic, strong) id delegate;

@end
