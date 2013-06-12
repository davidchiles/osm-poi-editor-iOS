//
//  OPEWikipediaWebViewController.h
//  OSM POI Editor
//
//  Created by David on 6/11/13.
//
//

#import <UIKit/UIKit.h>

@interface OPEWikipediaWebViewController : UIViewController <UIWebViewDelegate>
{
    NSString * articleTitleString;
    NSString * locale;
}

-(id)initWithWikipediaArticaleTitle:(NSString *)titleString withLocale:(NSString *)locale;

@end
