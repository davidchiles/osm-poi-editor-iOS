//
//  OPESpecialCell2.h
//  OSM POI Editor
//
//  Created by David Chiles on 5/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OPESpecialCell2 : UITableViewCell
{
    UILabel * leftLabel;
    UILabel * rightLabel;
}

@property (nonatomic, strong) NSString * leftText;
@property (nonatomic, strong) NSString * rightText;

@end
