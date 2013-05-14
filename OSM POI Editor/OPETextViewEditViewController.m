//
//  OPETextViewEditViewController.m
//  OSM POI Editor
//
//  Created by David on 3/26/13.
//
//

#import "OPETextViewEditViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface OPETextViewEditViewController ()

@end

@implementation OPETextViewEditViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor colorWithRed:215.0/255.0 green:217.0/255.0 blue:223.0/255.0 alpha:1.0]];
	textView = [[UITextView alloc] initWithFrame:CGRectMake(10, 20, 300, 150)];
    [textView setFont:[UIFont systemFontOfSize:14.0]];
    textView.returnKeyType = UIReturnKeyDone;
    textView.delegate = self;
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle: @"Done" style:  UIBarButtonItemStyleDone target: self action: @selector(doneButtonPressed:)];
    [[self navigationItem] setRightBarButtonItem:doneButton];
    
    if ([self.osmKey isEqualToString:@"name"]) {
        textView.autocapitalizationType = UITextAutocapitalizationTypeWords;
    }
    
    [[textView layer] setCornerRadius:7.0];
    textView.text = self.currentOsmValue;
    
    [self.view addSubview:textView];
    [textView becomeFirstResponder];
}

- (BOOL) textView:(UITextView *)tView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqual:@"\n"])
    {
        [self doneButtonPressed:tView];
        return NO;
    }
    return YES;
}
-(void)doneButtonPressed:(id)sender
{
    NSString * newValue = [self newOsmValue];
    if ([newValue length]) {
        [self saveNewValue:newValue];
    }
    [self.navigationController popViewControllerAnimated:YES];
    
}
-(void) saveNewValue:(NSString *)value
{
    [self.delegate newOsmKey:self.osmKey value:value];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSString *)newOsmValue{
    return [textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

@end
