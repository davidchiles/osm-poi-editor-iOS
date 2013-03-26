//
//  OPERecentlyUsedViewController.h
//  OSM POI Editor
//
//  Created by David on 3/25/13.
//
//

#import "OPETextEditViewController.h"


@interface OPERecentlyUsedViewController : OPETextEditViewController <UITableViewDelegate, UITableViewDataSource>
{
    NSArray * recentValues;
}

@property (nonatomic) BOOL showRecent;


@end
