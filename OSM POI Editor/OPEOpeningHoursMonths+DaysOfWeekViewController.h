//
//  OPEOpeningHoursMonths+DaysOfWeekViewController.h
//  OSM POI Editor
//
//  Created by David on 8/29/13.
//
//

#import "OPEDone+CancelViewController.h"
#import "OPEOpeningHoursRuleEditViewController.h"

typedef enum : NSUInteger {
    OPETypeMonth = 0,
    OPETypeDaysOfWeek = 1
} OPEType;

@interface OPEOpeningHoursMonths_DaysOfWeekViewController : OPEDone_CancelViewController <UITableViewDataSource,UITableViewDelegate>
{
    NSOrderedSet * originalOrderedSet;
}

@property (nonatomic) OPEType type;
@property (nonatomic,strong) NSMutableOrderedSet * dateComponentsOrderedSet;
@property (nonatomic,copy) ruleEditPropertyCompleteBlock doneBlock;

-(id)initWithType:(OPEType)type forDateComponents:(NSOrderedSet *)dateComponentsOrderedSet;

@end
