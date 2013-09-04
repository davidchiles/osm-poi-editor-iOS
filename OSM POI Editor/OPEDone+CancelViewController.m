//
//  OPEDone+CancelViewController.m
//  OSM POI Editor
//
//  Created by David on 8/29/13.
//
//

#import "OPEDone+CancelViewController.h"
#import "OPEStrings.h"

@interface OPEDone_CancelViewController ()

@end

@implementation OPEDone_CancelViewController

@synthesize cancelButton,doneButton;

-(id)initShowCancel:(BOOL)showCancel showDone:(BOOL)showDone
{
    if (self = [self init]) {
        if (showCancel) {
            self.cancelButton = [[UIBarButtonItem alloc] initWithTitle:CANCEL_STRING style:UIBarButtonItemStylePlain target:self action:@selector(cancelButtonPressed:)];
        }
        if (showDone) {
            self.doneButton = [[UIBarButtonItem alloc] initWithTitle:DONE_STRING style:  UIBarButtonItemStyleDone target: self action: @selector(doneButtonPressed:)];
        }
        
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    if (doneButton) {
        [[self navigationItem] setRightBarButtonItem:self.doneButton];
    }
    
    if (cancelButton) {
        self.navigationItem.leftBarButtonItem = self.cancelButton;
    }
    
    
}

-(void)doneButtonPressed:(id)sender
{
    NSLog(@"%@",@"Done Button Pressed");
    [self popViewController];
}
-(void)cancelButtonPressed:(id)sender
{
    NSLog(@"%@",@"Cancel Button Pressed");
    [self popViewController];
}

-(void)popViewController {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
