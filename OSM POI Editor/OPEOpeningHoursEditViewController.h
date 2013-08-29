//
//  OPEOpeningHoursEditViewController.h
//  OSM POI Editor
//
//  Created by David on 8/29/13.
//
//

#import "OPETagEditViewController.h"
#import "OPEOpeningHoursParser.h"

@interface OPEOpeningHoursEditViewController : OPETagEditViewController <UITableViewDataSource,UITableViewDelegate>

{
    UITableView * rulesTableView;
}

@property (nonatomic,strong) NSMutableArray * rulesArray;
@property (nonatomic,strong) OPEOpeningHoursParser * openingHoursParser;

@end
