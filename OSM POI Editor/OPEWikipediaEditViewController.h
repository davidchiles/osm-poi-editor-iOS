//
//  OPEWikipediaEditViewController.h
//  OSM POI Editor
//
//  Created by David on 6/11/13.
//
//

#import "OPERecentlyUsedViewController.h"
#import "OPEWikipediaManager.h"

@interface OPEWikipediaEditViewController : OPERecentlyUsedViewController <UITextFieldDelegate>
{
    OPEWikipediaManager * wikipediaManager;
    NSArray * wikipediaResultsArray;
}

@end
