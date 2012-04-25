//
//  OPETextEdit.m
//  OSM POI Editor
//
//  Created by David Chiles on 2/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "OPETextEdit.h"
#import <QuartzCore/QuartzCore.h>
#import "OPEConstants.h"
#import "OPEPhoneCell.h"

@implementation OPETextEdit

@synthesize osmValue;
@synthesize textView;
@synthesize delegate;
@synthesize osmKey;
@synthesize recentControl;
@synthesize osmKeysStoreRecent;
@synthesize type;
@synthesize textField;

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
    osmKeysStoreRecent = [NSSet setWithObjects:@"addr:country",@"addr:city",@"addr:postcode",@"addr:state",@"addr:province",@"addr:street", nil];
    
    
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithTitle: @"Done" style:  UIBarButtonItemStyleDone target: self action: @selector(saveButtonPressed)];
   
    [[self navigationItem] setRightBarButtonItem:saveButton];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancelButtonPressed)];
    
    
    
    if ([type isEqualToString:kTypeLabel] || [type isEqualToString:kTypeNumber] || [type isEqualToString:kTypePhone] || [type isEqualToString:kTypeUrl]) {
        NSLog(@"It's a label");
        self.textField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 300, 35)];
        self.textField.delegate = self;
        self.textField.font = [UIFont systemFontOfSize:24.0];
        textField.text = osmValue;
        //[self.textField setBorderStyle:UITextBorderStyleRoundedRect];
        self.textField.returnKeyType = UIReturnKeyDone;
        
        if([type isEqualToString:kTypeNumber])
        {
            self.textField.keyboardType = UIKeyboardTypeNumberPad;
        }
        else if([osmKey isEqualToString:@"addr:housenumber"])
        {
            self.textField.keyboardType = UIKeyboardTypeNamePhonePad;
            self.textField.autocorrectionType = UITextAutocorrectionTypeNo;
        }
        else if([type isEqualToString:kTypeUrl])
        {
            self.textField.keyboardType = UIKeyboardTypeURL;
            self.textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
            self.textField.autocorrectionType = UITextAutocorrectionTypeNo;
            if ([self.textField.text isEqualToString:@""] || !self.textField.text) {
                self.textField.text = @"www.";
            }
        }
        else if([type isEqualToString:kTypePhone])
        {
            self.textField.keyboardType = UIKeyboardTypeNumberPad;
            phoneTextFieldArray = [[NSMutableArray alloc]init];
            for( int i = 0; i<3; i++)
            {
                UITextField * tempText = [[UITextField alloc] init];
                tempText.keyboardType = UIKeyboardTypeNumberPad;
                [phoneTextFieldArray addObject:tempText];
            }
            [[phoneTextFieldArray objectAtIndex:0] becomeFirstResponder];
            if (osmValue) {
                [self fillPhoneNumber:osmValue];
            }
            
            
        }
        
        
        
        
        
        //[self.view addSubview:self.textField];
        [textField becomeFirstResponder];
        UITableView * tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, 460) style:UITableViewStyleGrouped];
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        tableView.scrollEnabled = NO;
        [self.view addSubview:tableView];
    }
    else if ([type isEqualToString:kTypeText]) 
    {
        textView = [[UITextView alloc] initWithFrame:CGRectMake(10, 20, 300, 150)];
        [textView setFont:[UIFont systemFontOfSize:14.0]];
        textView.returnKeyType = UIReturnKeyDone;
        self.textView.delegate = self;
        
        [[textView layer] setCornerRadius:7.0];
        textView.text = osmValue;
        
        [self.view addSubview:self.textView];
        [textView becomeFirstResponder];
        
    }
    
    
    //Setup recenty used tags
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    //Recently used Tags
    if ([prefs objectForKey:osmKey]) {
        NSArray * recentArray = [NSArray arrayWithArray:[prefs objectForKey:osmKey]];
        NSLog(@"Recently Used: %@",recentArray);
        
        recentControl = [[UISegmentedControl alloc] initWithItems:recentArray];
        recentControl.frame = CGRectMake(0, 0, 300, 150);
        recentControl.segmentedControlStyle = UISegmentedControlStylePlain;
        [recentControl addTarget:self action:@selector(didTapRecent:) forControlEvents:UIControlEventValueChanged];
        //CGRect textViewFrame = self.textView.frame;
        //textViewFrame.size.height = 160.0;
        //self.textView.frame = textViewFrame;
        [self.view addSubview:recentControl];
    }
    
    
    
    
    
    
    if ([osmKey isEqualToString:@"name"] || [osmKey isEqualToString:@"addr:city"]  || [osmKey isEqualToString:@"addr:province"]|| [osmKey isEqualToString:@"addr:street"]) {
        //self.textView.autocapitalizationType = UITextAutocapitalizationTypeWords;
        self.textField.autocapitalizationType = UITextAutocapitalizationTypeWords;
    }
    else if ([osmKey isEqualToString:@"addr:state"] || [osmKey isEqualToString:@"addr:country"]){
        //textView.autocapitalizationType = UITextAutocapitalizationTypeAllCharacters;
        self.textField.autocapitalizationType = UITextAutocapitalizationTypeAllCharacters;
    }
             
    
    
    
    //[self.view addSubview:textView];
    
    
    
    
}
-(NSArray *)breakUpPhoneNumber:(NSString *)string
{
    return [[string stringByReplacingOccurrencesOfString:@"+" withString:@""]  componentsSeparatedByString:@" "];
}

-(void) fillPhoneNumber:(NSString *)string
{
    NSArray * phoneArray = [self breakUpPhoneNumber:string];
    for(int i =0; i<3 && [phoneArray count]; i++)
    {
        ((UITextField *)[phoneTextFieldArray objectAtIndex:2-i]).text = [phoneArray objectAtIndex:([phoneArray count]-i-1)];
    }
}

-(NSString *)formatPhoneNumber
{
    int cc = [[[phoneTextFieldArray objectAtIndex:0] text] intValue];
    int ac = [[[phoneTextFieldArray objectAtIndex:1] text] intValue];
    int ln = [[[phoneTextFieldArray objectAtIndex:2] text] intValue];
    return [NSString stringWithFormat:@"+%d %d %d",cc,ac,ln];
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
    NSString * newOsmValue;
    if ([type isEqualToString:kTypePhone]) {
        newOsmValue = [self formatPhoneNumber];
    }
    else if(self.textView)
    {
        textView.text = [textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        newOsmValue = textView.text;
        
        
    }
    else if(self.textField)
    {
        textField.text = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        newOsmValue = textField.text;
        
    }
    
    
    
    if ([osmKeysStoreRecent containsObject:osmKey]) {
        [self saveToRecentlyUsed:newOsmValue];
    }
    
    if ([newOsmValue isEqualToString:@"www."]) {
        newOsmValue = @"";
    }
    
    [[self delegate] newTag:[[NSDictionary alloc] initWithObjectsAndKeys:osmKey,@"osmKey",newOsmValue,@"osmValue", nil]];
    [self.navigationController popViewControllerAnimated:YES];
}

-(void) saveToRecentlyUsed:(NSString *) newValue
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    if (![newValue isEqualToString:@""])
    {
        if ([prefs objectForKey:osmKey]) {
            NSMutableArray * recent = [NSMutableArray arrayWithArray:[prefs objectForKey:osmKey]];
            [recent removeObject:newValue];
            NSMutableArray * newRecentArray = [NSMutableArray arrayWithObjects:newValue, nil];
            int limit = 3;
            if ([self.osmKey isEqualToString:@"addr:city"]) {
                limit = 2;
            }
            else if([self.osmKey isEqualToString:@"addr:street"]){
                limit = 1;
            }
            for (int i =0; i<[recent count] && i<limit-1; i++)
            {
                [newRecentArray addObject:[recent objectAtIndex:i]];
            }
            [prefs setObject:newRecentArray forKey:osmKey];
        }
        else {
            NSArray * newRecentArray = [NSArray arrayWithObjects:newValue, nil];
            [prefs setObject:newRecentArray forKey:osmKey];
        }
        [prefs synchronize];
    }
    
}
-(void) didTapRecent:(UISegmentedControl *)sender
{
    NSLog(@"Selected: %d",[sender selectedSegmentIndex]);
    if( self.textView)
    {
        self.textView.text = [sender titleForSegmentAtIndex: [sender selectedSegmentIndex]];
    }
    else if (self.textField)
    {
        self.textField.text = [sender titleForSegmentAtIndex: [sender selectedSegmentIndex]];
    }
    
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
    else {
        [recentControl setSelectedSegmentIndex:UISegmentedControlNoSegment];
    }
        
    
    return YES;
}

-(BOOL) textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([string isEqual:@"\n"])
    {
        [self saveButtonPressed];
        return NO;
    }
    else {
        [recentControl setSelectedSegmentIndex:UISegmentedControlNoSegment];
    }
    
    
    return YES;
}

#pragma - tableView
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (recentControl) {
        return 2;
    }
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([type isEqualToString:kTypePhone]) {
        return 3;
    }
    return 1;
}
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if(section == 1)
    {
        return @"Recently Used...";
    }
    return @"";
}
-(NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    if(section == 0)
    {
        NSString * string = @"Example: ";
        if([osmKey isEqualToString:@"addr:state"])
        {
            string = [string stringByAppendingFormat:@"CA, PA, NY, MA ..."];
        }
        else if([osmKey isEqualToString:@"addr:country"])
        {
            string = [string stringByAppendingFormat:@"US, CA, MX, GB ..."];
        }
        else if([osmKey isEqualToString:@"addr:province"])
        {
            string = [string stringByAppendingFormat:@"British Columbia, Ontario, Quebec ..."];
        }
        else if([osmKey isEqualToString:@"addr:postcode"])
        {
            string = @"In US use 5 digit ZIP Code";
        }
        else if([osmKey isEqualToString:@"addr:housenumber"])
        {
            string = @"House or building number \nExample: 1600, 10, 221B ...";
        }
        else if([type isEqualToString:kTypePhone])
        {
            string = @"US and Canada country code is 1";
        }

        else {
            string = @"";
        }
        return string;
    }
    return @"";
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifierText = @"Cell_Section_1";
    static NSString *CellIdentifierRecent = @"Cell_Section_2";
    UITableViewCell * cell;
    
    if(indexPath.section == 0)
    {
        if ([type isEqualToString:kTypePhone]) {
            OPEPhoneCell * phoneCell;
            phoneCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifierText];
            if (phoneCell == nil) {
                phoneCell = [[OPEPhoneCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellIdentifierText];
            }
            switch (indexPath.row) {
                case 0:
                    [phoneCell setLeftText:@"Country Code"];
                    [phoneCell setTextField:[phoneTextFieldArray objectAtIndex:indexPath.row]];
                    break;
                case 1:
                    [phoneCell setLeftText:@"Area Code"];
                    [phoneCell setTextField:[phoneTextFieldArray objectAtIndex:indexPath.row]];
                    break;
                case 2:
                    [phoneCell setLeftText:@"Local Number"];
                    [phoneCell setTextField:[phoneTextFieldArray objectAtIndex:indexPath.row]];
                    break;
                default:
                    break;
            }
            return phoneCell;
            
            
        }       
        else {
            cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifierText];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifierText];
            }
            textField.frame = CGRectMake(10, 9, cell.contentView.frame.size.width-10.0, cell.contentView.frame.size.height-9.0);
            textField.adjustsFontSizeToFitWidth = YES;
            textField.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            [cell.contentView addSubview:textField];
        }
        
        

        
    }
    else if( indexPath.section == 1)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifierRecent];
		if (cell == nil) {
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifierRecent];
        }
        CGSize tempSize = cell.contentView.frame.size;
        recentControl.frame = CGRectMake(0, 0, tempSize.width, tempSize.height);
        recentControl.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [cell.contentView addSubview:recentControl];
        cell.backgroundView = [[UIView alloc] initWithFrame:CGRectZero];
        
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
    
}

@end
