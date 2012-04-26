//
//  OPEBinaryCell.h
//  OSM POI Editor
//
//  Created by David Chiles on 4/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OPEBinaryCell : UITableViewCell
{
    UILabel * leftLabel;
}


@property (nonatomic,strong) NSString * leftText;
@property (nonatomic,strong) UISegmentedControl * binaryControl;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier array:(NSArray *)array;
-(void)selectSegmentWithTitle:(NSString *)title;

@end
