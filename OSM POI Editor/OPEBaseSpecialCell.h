//
//  OPEBaseSpecialCell.h
//  OSM POI Editor
//
//  Created by David on 8/23/13.
//
//

#import <UIKit/UIKit.h>

@interface OPEBaseSpecialCell : UITableViewCell
{
    CGFloat textWidth;
}

@property (nonatomic,strong)UILabel * leftLabel;

-(id)initWithTextWidth:(CGFloat)textWidth reuseIdentifier:(NSString *)identifier;

@end
