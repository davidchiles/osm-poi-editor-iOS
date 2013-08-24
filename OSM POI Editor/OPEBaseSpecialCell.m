//
//  OPEBaseSpecialCell.m
//  OSM POI Editor
//
//  Created by David on 8/23/13.
//
//

#import "OPEBaseSpecialCell.h"
#import "OPEConstants.h"

@implementation OPEBaseSpecialCell

@synthesize leftLabel;

-(id)initWithTextWidth:(CGFloat)newTextWidth reuseIdentifier:(NSString *)identifier
{
    if (self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier]) {
        
        textWidth = MAX(newTextWidth, kLeftTextDefaultSize);
        
        /*
        if(textWidth > kLeftTextDefaultSize)
        {
            leftLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 7, textWidth, 30)];
        }
        else {
            leftLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 7, kLeftTextDefaultSize, 30)];
        }
         */
        
        leftLabel = [[UILabel alloc] init];
        leftLabel.translatesAutoresizingMaskIntoConstraints = NO;
        leftLabel.backgroundColor = [UIColor clearColor];
        //leftLabel.text = leftText;
        leftLabel.font = [UIFont systemFontOfSize:[UIFont systemFontSize]];
        leftLabel.textColor = [UIColor colorWithRed:0 green:0.47843137 blue:1 alpha:1];
        leftLabel.textAlignment = NSTextAlignmentRight;
        [self.contentView addSubview:leftLabel];
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self setNeedsUpdateConstraints];
    }
    return self;
}

-(void)updateConstraints
{
    [super updateConstraints];
    NSLayoutConstraint * constraint = [NSLayoutConstraint constraintWithItem:self.leftLabel
                                                                   attribute:NSLayoutAttributeLeft
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:self.contentView
                                                                   attribute:NSLayoutAttributeLeft
                                                                  multiplier:1.0
                                                                    constant:10];
    [self.contentView addConstraint:constraint];
    
    constraint = [NSLayoutConstraint constraintWithItem:self.leftLabel
                                              attribute:NSLayoutAttributeTop
                                              relatedBy:NSLayoutRelationEqual
                                                 toItem:self.contentView
                                              attribute:NSLayoutAttributeTop
                                             multiplier:1.0
                                               constant:7];
    [self.contentView addConstraint:constraint];
    
    constraint = [NSLayoutConstraint constraintWithItem:self.leftLabel
                                              attribute:NSLayoutAttributeHeight
                                              relatedBy:NSLayoutRelationEqual
                                                 toItem:nil
                                              attribute:NSLayoutAttributeNotAnAttribute
                                             multiplier:1.0
                                               constant:30];
    [self.contentView addConstraint:constraint];
    
    constraint = [NSLayoutConstraint constraintWithItem:self.leftLabel
                                              attribute:NSLayoutAttributeWidth
                                              relatedBy:NSLayoutRelationEqual
                                                 toItem:nil
                                              attribute:NSLayoutAttributeNotAnAttribute
                                             multiplier:1.0
                                               constant:textWidth+1];
    [self.contentView addConstraint:constraint];
}

-(void) prepareForReuse
{
    //[self setNeedsUpdateConstraints];
}

@end
