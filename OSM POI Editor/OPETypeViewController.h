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
- (void) setCategoryAndType:(NSDictionary *)cAndT;
@end

@interface OPETypeViewController : UITableViewController

@property (nonatomic,retain) NSString * category;
@property (nonatomic, strong) id delegate;

@end
