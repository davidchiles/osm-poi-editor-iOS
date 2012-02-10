//
//  OPENodeViewController.h
//  OSM POI Editor
//
//  Created by David Chiles on 2/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OPENode.h"

@interface OPENodeViewController : UIViewController

@property (nonatomic, retain) OPENode * node;
@property (nonatomic, retain) IBOutlet UITableView* tableView;

- (void) saveButtonPressed;
- (void) setupTags;



@end
