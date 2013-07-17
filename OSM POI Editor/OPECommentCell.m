//
//  OPECommentCell.m
//  OSM POI Editor
//
//  Created by David on 7/16/13.
//
//

#import "OPECommentCell.h"

#define MESSAGE_TEXT_WIDTH_MAX 200

@implementation OPECommentCell

@synthesize comment = _comment,commentTextLabel,commentDetailLabel,commentActionLabel;

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        //text label
        self.commentTextLabel = [[self class] defaultLabel];
        self.commentTextLabel.delegate = self;
        [self.contentView addSubview:commentTextLabel];
        
        //detail label
        self.commentDetailLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.commentDetailLabel.font = [UIFont systemFontOfSize:14.0];
        [self.contentView addSubview:self.commentDetailLabel];
        
        //action label
        self.commentActionLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.commentActionLabel.font = [UIFont systemFontOfSize:14.0];
        self.commentActionLabel.textAlignment = UITextAlignmentRight;
        [self.contentView addSubview:self.commentActionLabel];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setComment:(Comment *)comment
{
    _comment = comment;
    
    CGFloat width = self.contentView.frame.size.width;
    
    self.commentTextLabel.text = self.comment.text;
    self.commentActionLabel.text = @"Action";
    self.commentDetailLabel.text = [NSString stringWithFormat:@"%@ %@",self.comment.username,self.comment.date];
    CGSize messageTextLabelSize = [self.commentTextLabel sizeThatFits:CGSizeMake(MESSAGE_TEXT_WIDTH_MAX, CGFLOAT_MAX)];
    self.commentTextLabel.frame = CGRectMake(0, 0, messageTextLabelSize.width, messageTextLabelSize.height);
    
    CGSize actionTextLabelSize = [self.commentActionLabel sizeThatFits:CGSizeMake(width, CGFLOAT_MAX)];
    self.commentActionLabel.frame = CGRectMake(width-actionTextLabelSize.width, messageTextLabelSize.height, actionTextLabelSize.width, actionTextLabelSize.height);
    
    CGSize detailTextLabelSize = [self.commentDetailLabel sizeThatFits:CGSizeMake(width, CGFLOAT_MAX)];
    self.commentDetailLabel.frame = CGRectMake(0, messageTextLabelSize.height, detailTextLabelSize.width, detailTextLabelSize.height);
        
}

+(CGFloat)heightForComment:(Comment *)comment
{
    TTTAttributedLabel * label = [OPECommentCell defaultLabel];
    label.text = comment.text;
    
    UILabel * detailLabel = [[UILabel alloc] init];
    detailLabel.text = comment.username;
    CGSize detailTextLabelSize = [detailLabel sizeThatFits:CGSizeMake(240, CGFLOAT_MAX)];
    
    return  [label sizeThatFits:CGSizeMake(MESSAGE_TEXT_WIDTH_MAX, CGFLOAT_MAX)].height+detailTextLabelSize.height;
}

+(TTTAttributedLabel *)defaultLabel
{
    TTTAttributedLabel * messageTextLabel = [[TTTAttributedLabel alloc] initWithFrame:CGRectZero];
    messageTextLabel.backgroundColor = [UIColor clearColor];
    messageTextLabel.numberOfLines = 0;
    //messageTextLabel.dataDetectorTypes = UIDataDetectorTypeLink;
    messageTextLabel.lineBreakMode = UILineBreakModeWordWrap;
    messageTextLabel.font = [UIFont systemFontOfSize:16.0];
    
    return messageTextLabel;
    
}

@end
