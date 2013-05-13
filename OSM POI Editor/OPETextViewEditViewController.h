//
//  OPETextViewEditViewController.h
//  OSM POI Editor
//
//  Created by David on 3/26/13.
//
//

#import "OPETagEditViewController.h"

@interface OPETextViewEditViewController : OPETagEditViewController <UITextViewDelegate>
{
    UITextView * textView;
}
-(void)doneButtonPressed:(id)sender;

@end
