//
//  OPENameEditView.m
//  OSM POI Editor
//
//  Created by David on 3/27/13.
//
//

#import "OPENameEditView.h"

@implementation OPENameEditView

@synthesize typeLabel,textField,saveButton;
@synthesize delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        CGRect userFrame = CGRectMake(0, 22, frame.size.width, frame.size.height-22);
        UIView * userView = [[UIView alloc] initWithFrame:userFrame];
        saveButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [saveButton setTitle:@"Save" forState:UIControlStateNormal];
        saveButton.frame = CGRectMake(userFrame.size.width-53.0, 0, 50, userFrame.size.height);
        saveButton.enabled = NO;
        [saveButton addTarget:self action:@selector(saveButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        textField = [[UITextField alloc] initWithFrame:CGRectMake(2, 0 , userFrame.size.width - 60, userFrame.size.height-3)];
        textField.autocapitalizationType = UITextAutocapitalizationTypeWords;
        textField.autocorrectionType = UITextAutocorrectionTypeNo;
        textField.returnKeyType = UIReturnKeyDone;
        textField.delegate = self;
        textField.placeholder  = @"Ex Main Street, River Trail";
        //textField.borderStyle = UITextBorderStyleLine;
        
        self.backgroundColor = [UIColor whiteColor];
        
        [userView addSubview:saveButton];
        [userView addSubview:textField];
        
        [self addSubview: userView];
    }
    return self;
}

-(id)initWithFrame:(CGRect)frame andType:(NSString *)typeString
{
    self = [self initWithFrame:frame];
    if (self) {
        typeLabel = [[UILabel alloc] initWithFrame:CGRectMake(2, 2, frame.size.width - 6, 20)];
        typeLabel.text = typeString;
        typeLabel.numberOfLines = 1;
        typeLabel.minimumFontSize = 8.;
        typeLabel.adjustsFontSizeToFitWidth = YES;
        
        [self addSubview:typeLabel];
    }
    return self;
}

-(void)saveButtonPressed:(id)sender
{
    NSString * value = [self.textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if ([value length]) {
        [delegate saveValue:value];
    }
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString * value = [self.textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if ([value length]) {
        saveButton.enabled = YES;
    }
    
    return YES;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.textField resignFirstResponder];
    
    return NO;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
