//
//  OPEDone+CancelViewController.m
//  OSM POI Editor
//
//  Created by David on 8/29/13.
//
//

#import "OPEDone+CancelViewController.h"

@interface OPEDone_CancelViewController ()

@end

@implementation OPEDone_CancelViewController

@synthesize cancelButton,doneButton;

-(id)initShowCancel:(BOOL)showCancel showDone:(BOOL)showBOOL
{
    if (self = [self init]) {
        self.doneButton = [[UIBarButtonItem alloc] initWithTitle: @"Done" style:  UIBarButtonItemStyleDone target: self action: @selector(doneButtonPressed:)];
        self.cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancelButtonPressed:)];
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
