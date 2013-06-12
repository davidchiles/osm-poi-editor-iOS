//
//  OPEWikipediaEditViewController.h
//  OSM POI Editor
//
//  Created by David on 6/11/13.
//
//

#import "OPERecentlyUsedViewController.h"
#import "OPEWikipediaManager.h"
#import "BButton.h"

@interface OPEWikipediaEditViewController : OPERecentlyUsedViewController <UITextFieldDelegate>
{
    OPEWikipediaManager * wikipediaManager;
    NSArray * wikipediaResultsArray;
    NSMutableArray * supportedWikipedialanguges;
}

@property (nonatomic,strong) BButton * languageButton;
@property (nonatomic,strong) NSString * locale;

@end
