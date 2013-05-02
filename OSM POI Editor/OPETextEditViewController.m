//
//  OPETextEditViewController.m
//  OSM POI Editor
//
//  Created by David on 3/25/13.
//
//

#import "OPETextEditViewController.h"
#import "OPEManagedOsmTag.h"

@interface OPETextEditViewController ()

@end

@implementation OPETextEditViewController
@synthesize textField;

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle: @"Done" style:  UIBarButtonItemStyleDone target: self action: @selector(doneButtonPressed:)];
    
    [[self navigationItem] setRightBarButtonItem:doneButton];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancelButtonPressed:)];
    
}

-(void)doneButtonPressed:(id)sender
{
    NSString * newValue = [self newOsmValue];
    if ([newValue length]) {
        [self saveNewValue:newValue];
    }
    [self.navigationController popViewControllerAnimated:YES];
    
}
-(void)cancelButtonPressed:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void) saveNewValue:(NSString *)value
{
    [self.delegate newOsmKey:self.osmKey value:value];
}

-(NSString *)newOsmValue
{
    return [self.textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

@end
