//
//  OPEDatePickerCell.h
//  OSM POI Editor
//
//  Created by David Chiles on 11/9/13.
//
//

#import <UIKit/UIKit.h>

@interface OPEDatePickerCell : UITableViewCell {
    UIButton * sunsetButton;
    UIButton * sunriseButton;
    UIDatePicker * datePicker;
}

@property (nonatomic,strong) NSDate * date;

@end
