//
//  OPECommentCell.m
//  OSM POI Editor
//
//  Created by David on 7/16/13.
//
//

#import "OPECommentCell.h"
#import "OPEUtility.h"
#import "OSMComment.h"
#import "OPEOSMUser.h"

#define MESSAGE_TEXT_WIDTH_MAX 240
#define EDGE_MARGIN 20
#define OPPOSITE_MARGIN 10
#define BUBBLE_MARGIN 4

@implementation OPECommentCell

@synthesize comment = _comment,commentTextLabel,commentDetailLabel,commentActionLabel;

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        //
        imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        
        [self.contentView addSubview:imageView];
        
        commentContents = [[UIView alloc] initWithFrame:CGRectZero];
        commentContents.backgroundColor = [UIColor clearColor];
        //commentContents.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth;
        [imageView addSubview:commentContents];
        
        //text label
        self.commentTextLabel = [[self class] defaultLabel];
        self.commentTextLabel.delegate = self;
        [commentContents addSubview:commentTextLabel];
        
        //detail label
        self.commentDetailLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.commentDetailLabel.font = [UIFont systemFontOfSize:14.0];
        self.commentDetailLabel.backgroundColor = [UIColor clearColor];
        [commentContents addSubview:self.commentDetailLabel];
        
        //action label
        self.commentActionLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.commentActionLabel.font = [UIFont systemFontOfSize:14.0];
        self.commentActionLabel.textAlignment = NSTextAlignmentRight;
        self.commentActionLabel.backgroundColor = [UIColor clearColor];
        [commentContents addSubview:self.commentActionLabel];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setComment:(OSMComment *)comment
{
    _comment = comment;
    
    //CGFloat width = self.contentView.frame.size.width;
    
    
    self.commentTextLabel.text = self.comment.text;
    self.commentActionLabel.text = self.comment.action;
    self.commentDetailLabel.text = [NSString stringWithFormat:@"%@ %@",self.comment.username,[OPEUtility displayFormatDate:self.comment.date]];
    CGSize messageTextLabelSize = [self.commentTextLabel sizeThatFits:CGSizeMake(MESSAGE_TEXT_WIDTH_MAX, CGFLOAT_MAX)];
    
    CGFloat width = MESSAGE_TEXT_WIDTH_MAX;
    
    CGSize actionTextLabelSize = [self.commentActionLabel sizeThatFits:CGSizeMake(width, CGFLOAT_MAX)];
    CGSize detailTextLabelSize = [self.commentDetailLabel sizeThatFits:CGSizeMake(width, CGFLOAT_MAX)];
    
    
    
    self.commentActionLabel.frame = CGRectMake(width-actionTextLabelSize.width, messageTextLabelSize.height, actionTextLabelSize.width, actionTextLabelSize.height);
    
    self.commentDetailLabel.frame = CGRectMake(0, messageTextLabelSize.height, detailTextLabelSize.width, detailTextLabelSize.height);
    self.commentActionLabel.frame = CGRectMake(width-actionTextLabelSize.width, messageTextLabelSize.height+detailTextLabelSize.height, actionTextLabelSize.width, actionTextLabelSize.height);
    
    self.commentTextLabel.frame = CGRectMake(0, 0, messageTextLabelSize.width, messageTextLabelSize.height);
    CGFloat height = messageTextLabelSize.height+actionTextLabelSize.height+detailTextLabelSize.height;
    
    //FIXME hard coding finding self
    OPEOSMUser *currentUser = [OPEOSMUser currentUser];
    if (self.comment.userID == [currentUser.userId longLongValue]) {
        CGFloat newWidth = width+EDGE_MARGIN+OPPOSITE_MARGIN;
        commentContents.frame = CGRectMake(OPPOSITE_MARGIN, 0, width, height);
        UIEdgeInsets insets = UIEdgeInsetsMake(2, 2, 12, 12);
        imageView.image = [[UIImage imageNamed:@"bubble_right"] resizableImageWithCapInsets:insets];
        //CGFloat newWidth = width+EDGE_MARGIN+OPPOSITE_MARGIN;
        imageView.frame = CGRectMake(self.contentView.frame.size.width - newWidth-BUBBLE_MARGIN, BUBBLE_MARGIN,newWidth, height);
    }
    else
    {
        
        commentContents.frame = CGRectMake(EDGE_MARGIN, 0, width, height);
        UIEdgeInsets insets = UIEdgeInsetsMake(2, 12, 12, 2);
        imageView.image = [[UIImage imageNamed:@"bubble_left"] resizableImageWithCapInsets:insets];
        imageView.frame = CGRectMake(BUBBLE_MARGIN, BUBBLE_MARGIN, width+EDGE_MARGIN+OPPOSITE_MARGIN,height );
    }
    
    
        
}

+(CGFloat)heightForComment:(OSMComment *)comment
{
    TTTAttributedLabel * label = [OPECommentCell defaultLabel];
    label.text = comment.text;
    
    UILabel * detailLabel = [[UILabel alloc] init];
    detailLabel.text = comment.username;
    CGSize detailTextLabelSize = [detailLabel sizeThatFits:CGSizeMake(240, CGFLOAT_MAX)];
    
    return  [label sizeThatFits:CGSizeMake(MESSAGE_TEXT_WIDTH_MAX, CGFLOAT_MAX)].height+detailTextLabelSize.height*2;
}

+(TTTAttributedLabel *)defaultLabel
{
    TTTAttributedLabel * messageTextLabel = [[TTTAttributedLabel alloc] initWithFrame:CGRectZero];
    messageTextLabel.backgroundColor = [UIColor clearColor];
    messageTextLabel.numberOfLines = 0;
    //messageTextLabel.dataDetectorTypes = UIDataDetectorTypeLink;
    messageTextLabel.lineBreakMode = NSLineBreakByWordWrapping;
    messageTextLabel.font = [UIFont systemFontOfSize:16.0];
    
    return messageTextLabel;
    
}

@end
