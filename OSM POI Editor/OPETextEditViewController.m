//
//  OPETextEditViewController.m
//  OSM POI Editor
//
//  Created by David on 3/25/13.
//
//

#import "OPETextEditViewController.h"
#import "OPEOsmTag.h"

@interface OPETextEditViewController ()

@end

@implementation OPETextEditViewController
@synthesize textField;

-(id)init
{
    if (self = [super init]) {
        self.textField = [[OPEOsmValueTextField alloc] initWithFrame:CGRectMake(0, 0, 300, 35) withOsmKey:self.osmKey andValue:self.currentOsmValue];
        self.textField.delegate = self;
    }
    return self;
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    self.textField.text = self.currentOsmValue;
}

-(BOOL)textField:(UITextField *)tField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    self.currentOsmValue = [tField.text stringByReplacingCharactersInRange:range withString:string];
    return YES;
}

@end
