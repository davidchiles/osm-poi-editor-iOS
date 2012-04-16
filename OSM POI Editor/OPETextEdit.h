//
//  OPETextEdit.h
//  OSM POI Editor
//
//  Created by David Chiles on 2/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol editTextDelegate <NSObject>
@required
- (void) newTag:(NSDictionary *)text;
@end

@interface OPETextEdit : UIViewController <UITextViewDelegate>


@property (nonatomic, retain) NSString * osmValue;
@property (nonatomic, retain) IBOutlet UITextView * textView;
@property (nonatomic, strong) NSString * osmKey;

@property (retain) id delegate;

- (void) saveButtonPressed;

@end
