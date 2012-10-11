//
//  OPECreditViewController.h
//  OSM POI Editor
//
//  Created by David Chiles on 4/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OPECreditViewController : UIViewController <UIWebViewDelegate, UIActionSheetDelegate>

@property (nonatomic, strong) UIWebView * webView;
@property (nonatomic, strong) NSURL * lastURL;

-(IBAction)doneButtonPressed:(id)sender;

@end
