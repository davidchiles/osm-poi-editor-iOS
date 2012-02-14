//
//  OPETypeViewController.h
//  OSM POI Editor
//
//  Created by David Chiles on 2/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PassCategoryAndType <NSObject>
@required
- (void) setCategoryAndType:(NSArray *)cAndT;
@end

@interface OPETypeViewController : UITableViewController

@property (nonatomic,retain) NSString * category;
@property (retain) id delagate;

@end
