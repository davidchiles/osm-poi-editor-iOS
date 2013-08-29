//
//  OPEOpeningHoursRuleEditViewController.h
//  OSM POI Editor
//
//  Created by David on 8/29/13.
//
//

#import "OPEDone+CancelViewController.h"

@class OPEOpeningHourRule;
@class OPEOpeningHoursParser;

@interface OPEOpeningHoursRuleEditViewController : OPEDone_CancelViewController <UITableViewDataSource, UITableViewDelegate>
{
    OPEOpeningHourRule * originalRule;
    UISwitch * twentyFourSevenSwitch;
    UITableView * ruleTableView;
    OPEOpeningHoursParser * openingHoursParser;
    UISegmentedControl * openCloseSegmentedControl;
    
}


@property (nonatomic,strong) OPEOpeningHourRule * rule;

- (id)initWithRule:(OPEOpeningHourRule *)newRule;

@end
