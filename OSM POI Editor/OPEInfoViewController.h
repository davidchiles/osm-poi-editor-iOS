//
//  OPEInfoViewController.h
//  OSM POI Editor
//
//  Created by David Chiles on 2/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GTMOAuthViewControllerTouch.h"
#import "RMMapView.h"
#import "OPECreditViewController.h"

@protocol OPEInfoViewControllerDelegate
@optional
-(void)setTileSource:(id)tileSource at:(int)number;

@end

@interface OPEInfoViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UIButton * loginButton;
@property (nonatomic, strong) IBOutlet UIButton * logoutButton;
@property (nonatomic, strong) IBOutlet UITextView * textBox;
@property (nonatomic, strong) id<OPEInfoViewControllerDelegate> delegate;
@property (nonatomic) int currentNumber;

- (IBAction)doneButtonPressed:(id)sender;
- (IBAction)loginButtonPressed:(id)sender;
- (IBAction)logoutButtonPressed:(id)sender;

-(void)osmButtonPressed:(id)sender;
-(void)infoButtonPressed:(id)sender;

- (void) signInToOSM;
- (GTMOAuthAuthentication *)osmAuth;
- (void) signOutOfOSM;

+ (id)getTileSourceFromNumber:(int) num;

@end
