//
//  OpeTimeRangeCell.h
//  OSM POI Editor
//
//  Created by David on 8/29/13.
//
//

#import <UIKit/UIKit.h>

@class OPEDateRange;

typedef void (^didSelectDateButton)(UITableViewCell * cell,BOOL isStartButton);

@interface OPETimeRangeCell : UITableViewCell
{
    UIButton * startTimeButton;
    UIButton * endTimeButton;
    UILabel * toLabel;
}

@property (nonatomic,strong) OPEDateRange * dateRange;
@property (nonatomic,copy) didSelectDateButton didSelectDateButtonBlock;

-(id)initWithIdentifier:(NSString *)reuseIdentifier;

@end
