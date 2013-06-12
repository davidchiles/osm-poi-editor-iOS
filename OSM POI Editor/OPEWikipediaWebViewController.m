//
//  OPEWikipediaWebViewController.m
//  OSM POI Editor
//
//  Created by David on 6/11/13.
//
//

#import "OPEWikipediaWebViewController.h"

@interface OPEWikipediaWebViewController ()

@end

@implementation OPEWikipediaWebViewController

-(id)initWithWikipediaArticaleTitle:(NSString *)titleString withLocale:(NSString *)newLocale
{
    if (self = [super init]) {
        locale = newLocale;
        articleTitleString = titleString;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = articleTitleString;
	
    UIWebView * webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    webView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    NSString * urlString = [NSString stringWithFormat:@"http://%@.wikipedia.org/wiki/%@",locale,articleTitleString];
    NSURLRequest * requeset = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    [webView loadRequest:requeset];
    
    [self.view addSubview:webView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
