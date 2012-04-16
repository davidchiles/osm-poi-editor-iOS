//
//  OPENodeViewController.h
//  OSM POI Editor
//
//  Created by David Chiles on 2/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OPENode.h"
#import "OPETagInterpreter.h"
#import "OPETextEdit.h"
#import "OPETypeViewController.h"
#import "MBProgressHUD.h"

@protocol OPENodeViewDelegate
@optional
-(void)createdNode:(OPENode *)newNode;
-(void)updatedNode:(OPENode *)newNode;
-(void)deletedNode:(OPENode *)newNode;
@end


@interface OPENodeViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate, editTextDelegate, PassCategoryAndType, MBProgressHUDDelegate, UIAlertViewDelegate>
{
    UITableView *tableView;
    OPETagInterpreter * tagInterpreter;
    NSDictionary * osmKeyValue;
}

@property (nonatomic, strong) OPENode * node;
@property (nonatomic, strong) OPENode * theNewNode;
@property (nonatomic, strong) IBOutlet UITableView* tableView;
@property (nonatomic, strong) NSArray * catAndType;
@property (nonatomic, strong) NSString * type;
@property (nonatomic, strong) IBOutlet UIButton * deleteButton;
@property (nonatomic, strong) UIBarButtonItem * saveButton;
@property (nonatomic, strong) id <OPENodeViewDelegate> delegate;
@property (nonatomic) BOOL nodeIsEdited;
@property (nonatomic, strong) MBProgressHUD * HUD;

- (void) saveButtonPressed;
- (void) deleteButtonPressed;
- (void) checkSaveButton;
- (void) uploadComplete:(NSNotification *)notification;



@end
