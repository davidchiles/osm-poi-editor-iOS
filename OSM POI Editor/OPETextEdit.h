//
//  OPETextEdit.h
//  OSM POI Editor
//
//  Created by David Chiles on 2/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol editTagDelegate <NSObject>
@required
- (void) newTag:(NSDictionary *)text;
@end

@interface OPETextEdit : UIViewController <UITextViewDelegate,UITextFieldDelegate, UITableViewDelegate,UITableViewDataSource>
{
    NSMutableArray * phoneTextFieldArray;
}


@property (nonatomic, retain) NSString * osmValue;
@property (nonatomic, retain) IBOutlet UITextView * textView;
@property (nonatomic, strong) NSString * osmKey;
@property (nonatomic, strong) UISegmentedControl * recentControl;
@property (nonatomic, strong) NSSet * osmKeysStoreRecent;
@property (nonatomic, strong) NSString * type;
@property (nonatomic, strong) UITextField * textField;

@property (retain) id delegate;

- (void) saveButtonPressed;

@end
