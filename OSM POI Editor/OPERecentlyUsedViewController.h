//
//  OPERecentlyUsedViewController.h
//  OSM POI Editor
//
//  Created by David on 3/25/13.
//
//

#import "OPETextEditViewController.h"

#define kTableViewTag 101

@interface OPERecentlyUsedViewController : OPETextEditViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>
{
    NSArray * recentValues;
}

@property (nonatomic) BOOL showRecent;


@end
