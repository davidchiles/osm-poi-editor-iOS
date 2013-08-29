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

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle: @"Done" style:  UIBarButtonItemStyleDone target: self action: @selector(doneButtonPressed:)];
    
    [[self navigationItem] setRightBarButtonItem:doneButton];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancelButtonPressed:)];
}

-(void)doneButtonPressed:(id)sender
{
    NSLog(@"%@",@"Done Button Pressed");
}
-(void)cancelButtonPressed:(id)sender
{
    NSLog(@"%@",@"Cancel Button Pressed");
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
