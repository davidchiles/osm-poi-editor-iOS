//
//  OPECommentCell.h
//  OSM POI Editor
//
//  Created by David on 7/16/13.
//
//

#import <UIKit/UIKit.h>
#import "Comment.h"
#import "TTTAttributedLabel.h"

@interface OPECommentCell : UITableViewCell <TTTAttributedLabelDelegate>
{
    UIImageView * imageView;
    UIView * commentContents;
}

@property (nonatomic, strong) Comment * comment;
@property (nonatomic, strong) TTTAttributedLabel * commentTextLabel;
@property (nonatomic, strong) UILabel * commentActionLabel;
@property (nonatomic, strong) UILabel * commentDetailLabel;


+(CGFloat)heightForComment:(Comment *)comment;

@end
