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
    //CGSize startButtonSize;
    //CGSize endButtonSize;
}

@property (nonatomic,strong) OPEDateRange * dateRange;
@property (nonatomic,copy) didSelectDateButton didSelectDateButtonBlock;


-(void)setEndButtonSelected;
-(void)setStartButtonSelected;
-(void)setSelectedButtonNone;

-(id)initWithIdentifier:(NSString *)reuseIdentifier;

@end
