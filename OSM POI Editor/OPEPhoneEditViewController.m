//
//  OPEPhoneEditViewController.m
//  OSM POI Editor
//
//  Created by David on 3/26/13.
//
//

#import "OPEPhoneEditViewController.h"
#import "OPEPhoneCell.h"

@interface OPEPhoneEditViewController ()

@end

@implementation OPEPhoneEditViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifierText = @"Cell_Section_1";
    
    OPEPhoneCell * phoneCell = nil;
    phoneCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifierText];
    if (!phoneCell) {
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

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.textField.keyboardType = UIKeyboardTypeNumberPad;
    phoneTextFieldArray = [[NSMutableArray alloc]init];
    for( int i = 0; i<3; i++)
    {
        UITextField * tempText = [[UITextField alloc] init];
        tempText.keyboardType = UIKeyboardTypeNumberPad;
        [phoneTextFieldArray addObject:tempText];
    }
    [[phoneTextFieldArray objectAtIndex:0] becomeFirstResponder];
    if (self.currentOsmValue) {
        [self fillPhoneNumber:self.currentOsmValue];
    }
}
-(NSArray *)breakUpPhoneNumber:(NSString *)string
{
    return [[string stringByReplacingOccurrencesOfString:@"+" withString:@""]  componentsSeparatedByString:@" "];
}

-(void) fillPhoneNumber:(NSString *)string
{
    NSArray * phoneArray = [self breakUpPhoneNumber:string];
    for(int i =0; i<3 && i<[phoneArray count]; i++)
    {
        ((UITextField *)[phoneTextFieldArray objectAtIndex:2-i]).text = [phoneArray objectAtIndex:([phoneArray count]-i-1)];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
