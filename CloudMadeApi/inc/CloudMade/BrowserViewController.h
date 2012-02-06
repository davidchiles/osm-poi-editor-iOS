//
//  BrowserViewController.h
//  
//
//  Created by Dmytro Golub on 9/4/09.
//  Copyright 2009 CloudMade. All rights reserved
//

#import <UIKit/UIKit.h>


@interface BrowserViewController : UIViewController <UIWebViewDelegate>
{
	NSString* _url;
	NSMutableArray* _urlHistory;
	int currentPageIdx;
	UIBarButtonItem* goBackBtn;
	UIBarButtonItem* goForwardBtn;
	UIWebView* _webView;
}

-(id) initWithUrl:(NSString*) url;

@end
