//
//  OPEOpeningHoursMonths+DaysOfWeekViewController.h
//  OSM POI Editor
//
//  Created by David on 8/29/13.
//
//

#import "OPEOpeningHoursBaseTimeEditViewController.h"

typedef enum : NSUInteger {
    OPETypeMonth = 0,
    OPETypeDaysOfWeek = 1
} OPEType;

@interface OPEOpeningHoursMonths_DaysOfWeekViewController : OPEOpeningHoursBaseTimeEditViewController

@property (nonatomic) OPEType type;

-(id)initWithType:(OPEType)type forDateComponents:(NSOrderedSet *)dateComponentsOrderedSet;

@end
