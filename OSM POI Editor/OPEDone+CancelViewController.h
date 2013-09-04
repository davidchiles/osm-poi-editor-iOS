//
//  OPEDone+CancelViewController.h
//  OSM POI Editor
//
//  Created by David on 8/29/13.
//
//

#import <UIKit/UIKit.h>

@interface OPEDone_CancelViewController : UIViewController

-(id)initShowCancel:(BOOL)showCancel showDone:(BOOL)showDone;

@property (nonatomic,strong) UIBarButtonItem * doneButton;
@property (nonatomic,strong) UIBarButtonItem * cancelButton;


-(void)doneButtonPressed:(id)sender;
-(void)cancelButtonPressed:(id)sender;

@end
