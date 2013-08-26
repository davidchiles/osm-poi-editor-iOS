//
//  OPEPhoneEditViewController.m
//  OSM POI Editor
//
//  Created by David on 3/26/13.
//
//

#import "OPEPhoneEditViewController.h"
#import "OPEStrings.h"

@interface OPEPhoneEditViewController ()

@end

@implementation OPEPhoneEditViewController

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
        phoneCell = [[OPEPhoneCell alloc] initWithTextWidth:maxLabelLength reuseIdentifier:CellIdentifierText];
        phoneCell.delegate = self;
    }
    phoneCell.textField.text = @"";
    if (indexPath.row == 0) {
        phoneCell.leftLabel.text = COUNTRY_CODE_STRING;
        phoneCell.maxTextFieldLength = 3;
        if (self.phoneNumber.countryCode) {
            phoneCell.textField.text = [NSString stringWithFormat:@"%lld",self.phoneNumber.countryCode];
        }
    }
    else if (indexPath.row == 1) {
        phoneCell.leftLabel.text = AREA_CODE_STRING;
        if (self.phoneNumber.areaCode) {
            phoneCell.textField.text = [NSString stringWithFormat:@"%lld",self.phoneNumber.areaCode];
        }
    }
    else if (indexPath.row == 2) {
        phoneCell.leftLabel.text = LOCAL_NUMBER_STRING;
        if (self.phoneNumber.localNumber) {
            phoneCell.textField.text = [NSString stringWithFormat:@"%lld",self.phoneNumber.localNumber];
        }
    }
    
    return phoneCell;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    maxLabelLength = [self getWidth];
    if (self.currentOsmValue) {
        self.phoneNumber = [OPEOSMTagConverter phoneNumberWithOsmValue:self.currentOsmValue];
    }
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self selectTextFieldAtRow:0];
}

-(void)selectTextFieldAtRow:(NSUInteger)row
{
    UITableView * tableView = (UITableView *)[self.view viewWithTag:kTableViewTag];
    OPEPhoneCell * phoneCell = (OPEPhoneCell *)[tableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:row inSection:0]];
    [phoneCell.textField becomeFirstResponder];
}

-(NSString *)newOsmValue
{
    NSString * newOsmValueString = [OPEOSMTagConverter osmStringWithPhoneNumber:self.phoneNumber];
    if ([newOsmValueString length]) {
        return newOsmValueString;
    }
    return self.currentOsmValue;
}

-(float)getWidth;
{
    __block CGFloat maxWidth = 0.0;
    
    NSArray * textArray = @[AREA_CODE_STRING,COUNTRY_CODE_STRING,LOCAL_NUMBER_STRING];
    
    [textArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSString * text = (NSString *)obj;
        UIFont * font =[UIFont systemFontOfSize:[UIFont systemFontSize]];
        CGFloat currentWidth = [text sizeWithAttributes:@{NSFontAttributeName:font}].width;
        maxWidth = MAX(maxWidth, currentWidth);
    }];
    
    return maxWidth;
    
}

-(void)newValue:(NSString *)value forCell:(UITableViewCell *)tableViewCell
{
    UITableView * tableView = (UITableView *)[self.view viewWithTag:kTableViewTag];
    NSIndexPath * indexPath = [tableView indexPathForCell:tableViewCell];
    int64_t num = [value longLongValue];
    phoneNumber newPhoneNumber = self.phoneNumber;
    if (indexPath.row == 0) {
        newPhoneNumber.countryCode = num;
    }
    else if (indexPath.row == 1) {
        newPhoneNumber.areaCode = num;
    }
    else if (indexPath.row == 2) {
        newPhoneNumber.localNumber = num;
    }
    self.phoneNumber = newPhoneNumber;
}

@end
