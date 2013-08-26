//
//  OPETextEdit.m
//  OSM POI Editor
//
//  Created by David Chiles on 2/13/12.
//  Copyright (c) 2011 David Chiles. All rights reserved.
//
//  This file is part of POI+.
//
//  POI+ is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  POI+ is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with POI+.  If not, see <http://www.gnu.org/licenses/>.

#import "OPETextEdit.h"
#import <QuartzCore/QuartzCore.h>
#import "OPEConstants.h"

@implementation OPETextEdit

@synthesize osmValue;
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
    //self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    [self.view setBackgroundColor:[UIColor colorWithRed:215.0/255.0 green:217.0/255.0 blue:223.0/255.0 alpha:1.0]];
    //self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    //[self.view addSubview:[[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStyleGrouped]];
    
    osmKeysStoreRecent = [NSSet setWithObjects:@"addr:country",@"addr:city",@"addr:postcode",@"addr:state",@"addr:province",@"addr:street", nil];
    
    
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithTitle: @"Done" style:  UIBarButtonItemStyleDone target: self action: @selector(saveButtonPressed)];
   
    [[self navigationItem] setRightBarButtonItem:saveButton];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancelButtonPressed)];
    
    
    
    if ([type isEqualToString:kTypeLabel] || [type isEqualToString:kTypeNumber] || [type isEqualToString:kTypePhone] || [type isEqualToString:kTypeUrl] || [type isEqualToString:kTypeEmail]) {
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
        else if([osmKey isEqualToString:@"addr:housenumber"] || [osmKey isEqualToString:@"addr:postcode"])
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
        else if([type isEqualToString:kTypeEmail])
        {
            self.textField.keyboardType = UIKeyboardTypeEmailAddress;
            self.textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
            self.textField.autocorrectionType = UITextAutocorrectionTypeNo;

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
    
    
    //Setup recenty used tags
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    //Recently used Tags
    if ([prefs objectForKey:osmKey]) {
        NSArray * recentArray = [NSArray arrayWithArray:[prefs objectForKey:osmKey]];
        NSLog(@"Recently Used: %@",recentArray);
        
        recentControl = [[UISegmentedControl alloc] initWithItems:recentArray];
        recentControl.frame = CGRectMake(0, 0, 300, 150);
        //recentControl.segmentedControlStyle = UISegmentedControlStylePlain;
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

- (void) viewDidAppear:(BOOL)animated
{
    textField.text = osmValue;
    if(textField)
    {
        [textField becomeFirstResponder];

    }
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void) saveButtonPressed
{
    NSString * newOsmValue;
    if(self.textField)
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
    
    
    [self saveNewOsmKey:osmKey andValue:newOsmValue];
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)saveNewOsmKey:(NSString *)oKey andValue:(NSString *)value
{
    [delegate newOsmKey:oKey value:value];
    
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
    if (self.textField)
    {
        self.textField.text = [sender titleForSegmentAtIndex: [sender selectedSegmentIndex]];
    }
    
}

-(void) cancelButtonPressed
{
    [self.navigationController popViewControllerAnimated:YES];
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
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifierText];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifierText];
        }
        textField.frame = CGRectMake(10, 9, cell.contentView.frame.size.width-10.0, cell.contentView.frame.size.height-9.0);
        textField.adjustsFontSizeToFitWidth = YES;
        textField.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [cell.contentView addSubview:textField];
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
