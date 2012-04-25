//
//  OPEPhoneCell.h
//  OSM POI Editor
//
//  Created by David Chiles on 4/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OPEPhoneCell : UITableViewCell
{
    UILabel * leftLabel;
}

@property (nonatomic,strong) NSString * leftText;
@property (nonatomic,strong) UITextField * textField;

@end
