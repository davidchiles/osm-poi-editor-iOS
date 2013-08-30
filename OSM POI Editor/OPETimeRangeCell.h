//
//  OpeTimeRangeCell.h
//  OSM POI Editor
//
//  Created by David on 8/29/13.
//
//

#import <UIKit/UIKit.h>

@class OPEDateRange;

@protocol OPETimeRangeCellDelegate <NSObject>

-(void)newTimeRange:(OPEDateRange *)dateRange forCell:(UITableViewCell *)cell;

@end

@interface OPETimeRangeCell : UITableViewCell
{
    UIButton * startTimeButton;
    UIButton * endTimeButton;
    UILabel * toLabel;
}

@property (nonatomic,weak) id <OPETimeRangeCellDelegate> delegate;
@property (nonatomic,strong) OPEDateRange * dateRange;

-(id)initWithTimeRange:(OPEDateRange *)dateRange withDelegate:(id<OPETimeRangeCellDelegate>)delegate reuseIdentifier:(NSString *)reuseIdentifier;

@end
