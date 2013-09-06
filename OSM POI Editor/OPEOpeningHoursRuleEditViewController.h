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

typedef void (^ruleEditCompleteBlock)(OPEOpeningHourRule *);

typedef enum {
    OPERuleEditTypeDefault = 0,
    OPERuleEditTypeTime,
    OPERuleEditTypeTimeRange
} OPERuleEditType;

@interface OPEOpeningHoursRuleEditViewController : OPEDone_CancelViewController <UITableViewDataSource, UITableViewDelegate>
{
    OPEOpeningHourRule * originalRule;
    UISwitch * twentyFourSevenSwitch;
    UITableView * ruleTableView;
    OPEOpeningHoursParser * openingHoursParser;
    UISegmentedControl * openCloseSegmentedControl;
    
}


@property (nonatomic,strong) OPEOpeningHourRule * rule;
@property (nonatomic) OPERuleEditType ruleEditType;
@property (nonatomic,copy) ruleEditCompleteBlock doneBlock;

- (id)initWithRule:(OPEOpeningHourRule *)newRule;

@end
