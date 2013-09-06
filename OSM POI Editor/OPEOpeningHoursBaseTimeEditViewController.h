//
//  OPEOpeningHoursBaseTimeEditViewController.h
//  OSM POI Editor
//
//  Created by David on 9/3/13.
//
//

#import "OPEDone+CancelViewController.h"

typedef void (^ruleEditPropertyCompleteBlock)(NSOrderedSet *);

@interface OPEOpeningHoursBaseTimeEditViewController : OPEDone_CancelViewController <UITableViewDataSource,UITableViewDelegate>

@property (nonatomic,strong) NSMutableArray * propertiesArray;
@property (nonatomic,copy) ruleEditPropertyCompleteBlock doneBlock;
@property (nonatomic,strong) UITableView * propertiesTableView;


-(id)initWithOrderedSet:(NSOrderedSet *)orderedSet;


-(NSIndexPath *)lastIndexPathForTableView:(UITableView *)tableView;
@end
