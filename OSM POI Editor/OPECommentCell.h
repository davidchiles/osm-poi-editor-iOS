//
//  OPECommentCell.h
//  OSM POI Editor
//
//  Created by David on 7/16/13.
//
//

#import <UIKit/UIKit.h>
#import "TTTAttributedLabel.h"

@class OSMComment;

@interface OPECommentCell : UITableViewCell <TTTAttributedLabelDelegate>
{
    UIImageView * imageView;
    UIView * commentContents;
}

@property (nonatomic, strong) OSMComment * comment;
@property (nonatomic, strong) TTTAttributedLabel * commentTextLabel;
@property (nonatomic, strong) UILabel * commentActionLabel;
@property (nonatomic, strong) UILabel * commentDetailLabel;


+(CGFloat)heightForComment:(OSMComment *)comment;

@end
