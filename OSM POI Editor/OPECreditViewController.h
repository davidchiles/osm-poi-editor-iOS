//
//  OPECreditViewController.h
//  OSM POI Editor
//
//  Created by David Chiles on 4/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OPECreditViewController : UIViewController <UIWebViewDelegate>

@property (nonatomic, strong) IBOutlet UIWebView * webView;

-(IBAction)doneButtonPressed:(id)sender;

@end
