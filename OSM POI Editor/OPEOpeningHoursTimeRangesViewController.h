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

- (BOOL)hasInlineDatePicker;
- (BOOL)hasPickerForIndexPath:(NSIndexPath *)indexPath;
- (void)displayInlineDatePickerForRowAtIndexPath:(NSIndexPath *)indexPath;
- (NSInteger)indexForPropertiesFromIndexPath:(NSIndexPath *)indexPath;
-(void)showDatePickerForIndexPath:(NSIndexPath *)indexPath withDateComponent:(OPEDateComponents *)dateComponent;
@end
