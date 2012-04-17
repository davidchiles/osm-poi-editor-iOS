//
//  OPETextEdit.m
//  OSM POI Editor
//
//  Created by David Chiles on 2/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "OPETextEdit.h"
#import <QuartzCore/QuartzCore.h>

@implementation OPETextEdit

@synthesize osmValue;
@synthesize textView;
@synthesize delegate;
@synthesize osmKey;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithTitle: @"Done" style:  UIBarButtonItemStyleDone target: self action: @selector(saveButtonPressed)];
   
    [[self navigationItem] setRightBarButtonItem:saveButton];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancelButtonPressed)];
    
    [[textView layer] setCornerRadius:7.0];
    textView.text = osmValue;
    
    if ([osmKey isEqualToString:@"name"] || [osmKey isEqualToString:@"addr:city"]  || [osmKey isEqualToString:@"addr:province"]|| [osmKey isEqualToString:@"addr:street"]) {
        textView.autocapitalizationType = UITextAutocapitalizationTypeWords;
    }
    else if ([osmKey isEqualToString:@"addr:state"] || [osmKey isEqualToString:@"addr:country"]){
        textView.autocapitalizationType = UITextAutocapitalizationTypeAllCharacters;
    }
             
    textView.returnKeyType = UIReturnKeyDone;
    textView.delegate = self;
    [textView becomeFirstResponder];
    
    
    
    
}

- (void) viewDidAppear:(BOOL)animated
{
    textView.text = osmValue;
    [textView becomeFirstResponder];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void) viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void) saveButtonPressed
{
    textView.text = [textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    [[self delegate] newTag:[[NSDictionary alloc] initWithObjectsAndKeys:osmKey,@"osmKey",textView.text,@"osmValue", nil]];
    [self.navigationController popViewControllerAnimated:YES];
}

-(void) cancelButtonPressed
{
    [self.navigationController popViewControllerAnimated:YES];
}
- (BOOL) textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqual:@"\n"])
    {
        [self saveButtonPressed];
        return NO;
    }
        
    
    return YES;
    
}

@end
