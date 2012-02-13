//
//  OPENodeViewController.h
//  OSM POI Editor
//
//  Created by David Chiles on 2/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OPENode.h"
#import "OPETagInterpreter.h"

@interface OPENodeViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
{
    UITableView *tableView;
}

@property (nonatomic, retain) OPENode * node;
@property (nonatomic, retain) IBOutlet UITableView* tableView;

- (void) saveButtonPressed;
- (void) setupTags;



@end
