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
        
        self.leftLabel = [[UILabel alloc] init];
        self.leftLabel.translatesAutoresizingMaskIntoConstraints = NO;
        self.leftLabel.backgroundColor = [UIColor clearColor];
        //leftLabel.text = leftText;
        self.leftLabel.font = [UIFont systemFontOfSize:[UIFont systemFontSize]];
        self.leftLabel.textColor = [UIColor colorWithRed:0 green:0.47843137 blue:1 alpha:1];
        self.leftLabel.textAlignment = NSTextAlignmentRight;
        [self.contentView addSubview:self.leftLabel];
        
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
