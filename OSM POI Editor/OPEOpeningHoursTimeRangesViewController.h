//
//  OPEOpeningHoursTimeRangesViewController.h
//  OSM POI Editor
//
//  Created by David on 8/29/13.
//
//

#import "OPEOpeningHoursBaseTimeEditViewController.h"
#import "OPEDatePickerCell.h"

@class OPEDateComponents;

@interface OPEOpeningHoursTimeRangesViewController : OPEOpeningHoursBaseTimeEditViewController <OPEDatePickerCellDelegate>
{
    OPEDateComponents * currentDateComponent;
    NSIndexPath * datePickerPath;
}

-(void)showDatePickerWithTitle:(NSString *)pickerTitle withDate:(NSDate *)currentDate withIndex:(NSInteger)index;

@end
