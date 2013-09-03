//
//  OPEOpeningHoursTimeRangesViewController.h
//  OSM POI Editor
//
//  Created by David on 8/29/13.
//
//

#import "OPEDone+CancelViewController.h"
#import "OPEOpeningHoursRuleEditViewController.h"

@class OPEDateComponents;

@interface OPEOpeningHoursTimeRangesViewController : OPEDone_CancelViewController <UITableViewDataSource,UITableViewDelegate>
{
    NSOrderedSet * originalOrderedSet;
    OPEDateComponents * currentDateComponent;
    UITableView * timeRangesTableView;
}

@property (nonatomic,strong) NSMutableOrderedSet * timeRangesOrderedSet;
@property (nonatomic,copy) ruleEditPropertyCompleteBlock doneBlock;

-(id)initWithTimeRanges:(NSOrderedSet *)timeRanges;

@end
