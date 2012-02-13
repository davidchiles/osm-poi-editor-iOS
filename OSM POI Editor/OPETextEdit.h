//
//  OPETextEdit.h
//  OSM POI Editor
//
//  Created by David Chiles on 2/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OPETextEdit : UIViewController

@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) IBOutlet UITextView * textView;

- (void) saveButtonPressed;

@end
