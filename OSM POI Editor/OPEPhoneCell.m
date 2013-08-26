//
//  OPEPhoneCell.m
//  OSM POI Editor
//
//  Created by David Chiles on 4/24/12.
//  Copyright (c) 2011 David Chiles. All rights reserved.
//
//  This file is part of POI+.
//
//  POI+ is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  POI+ is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with POI+.  If not, see <http://www.gnu.org/licenses/>.

#import "OPEPhoneCell.h"



@implementation OPEPhoneCell

@synthesize leftLabel,textField,delegate,maxTextFieldLength;

-(id)initWithTextWidth:(CGFloat)newTextWidth reuseIdentifier:(NSString *)identifier
{
    if(self = [super initWithTextWidth:newTextWidth reuseIdentifier:identifier]) {
        
        self.textField = [[UITextField alloc] init];
        self.textField.translatesAutoresizingMaskIntoConstraints = NO;
        self.textField.keyboardType = UIKeyboardTypeNumberPad;
        self.textField.font = [UIFont systemFontOfSize:24.0];
        self.textField.delegate = self;
        [self.contentView addSubview:self.textField];
        self.textField.textAlignment = NSTextAlignmentRight;
        self.maxTextFieldLength = 15;
        [self needsUpdateConstraints];
    }
    return self;
}

-(void)updateConstraints
{
    [super updateConstraints];
    
    NSLayoutConstraint * constraint = [NSLayoutConstraint constraintWithItem:self.textField
                                                                   attribute:NSLayoutAttributeLeft
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:self.leftLabel
                                                                   attribute:NSLayoutAttributeRight
                                                                  multiplier:1.0
                                                                    constant:6];
    [self.contentView addConstraint:constraint];
    
    constraint = [NSLayoutConstraint constraintWithItem:self.textField
                                              attribute:NSLayoutAttributeCenterY
                                              relatedBy:NSLayoutRelationEqual
                                                 toItem:self.leftLabel
                                              attribute:NSLayoutAttributeCenterY
                                             multiplier:1.0
                                               constant:0];
    [self.contentView addConstraint:constraint];
    
    constraint = [NSLayoutConstraint constraintWithItem:self.textField
                                              attribute:NSLayoutAttributeHeight
                                              relatedBy:NSLayoutRelationEqual
                                                 toItem:self.leftLabel
                                              attribute:NSLayoutAttributeHeight
                                             multiplier:1.0
                                               constant:0];
    [self.contentView addConstraint:constraint];
    
    constraint = [NSLayoutConstraint constraintWithItem:self.textField
                                              attribute:NSLayoutAttributeRight
                                              relatedBy:NSLayoutRelationEqual
                                                 toItem:self.contentView
                                              attribute:NSLayoutAttributeRight
                                             multiplier:1.0
                                               constant:-6];
    [self.contentView addConstraint:constraint];
    
    
}
#pragma UITextFieldDelegate
- (BOOL)textField:(UITextField *)tField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSUInteger oldLength = [textField.text length];
    NSUInteger replacementLength = [string length];
    NSUInteger rangeLength = range.length;
    
    NSUInteger newLength = oldLength - rangeLength + replacementLength;
    
    BOOL returnKey = [string rangeOfString: @"\n"].location != NSNotFound;
    
    BOOL result = newLength <= self.maxTextFieldLength || returnKey;
    
    
    if (!result) {
        return NO;
    }
    [self.delegate newValue:[tField.text stringByReplacingCharactersInRange:range withString:string] forCell:self];
    return result;
}

@end
