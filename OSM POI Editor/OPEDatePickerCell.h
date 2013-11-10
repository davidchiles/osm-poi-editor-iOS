//
//  OPEDatePickerCell.h
//  OSM POI Editor
//
//  Created by David Chiles on 11/9/13.
//
//

#import <UIKit/UIKit.h>
#import "OPEOpeningHoursParser.h"

@protocol OPEDatePickerCellDelegate <NSObject>

- (void)didSelectDate:(OPEDateComponents *)dateComponent withCell:(UITableViewCell *)cell;

@end


@interface OPEDatePickerCell : UITableViewCell {
    UIButton * sunsetButton;
    UIButton * sunriseButton;
    UIDatePicker * datePicker;
}

@property (nonatomic,strong) NSDate * date;
@property (nonatomic,weak) id<OPEDatePickerCellDelegate> delegate;

-(void)setDate:(NSDate *)date animated:(BOOL)animated;

@end


