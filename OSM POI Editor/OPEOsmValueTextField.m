//
//  OPEOsmValueTextField.m
//  OSM POI Editor
//
//  Created by David on 3/25/13.
//
//

#import "OPEOsmValueTextField.h"

@implementation OPEOsmValueTextField

-(id)initWithFrame:(CGRect)frame withOsmKey:(NSString *)osmKey andValue:(NSString *)value;
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.font = [UIFont systemFontOfSize:24.0];
        self.returnKeyType = UIReturnKeyDone;
        
        if ([osmKey isEqualToString:@"name"] || [osmKey isEqualToString:@"addr:city"]  || [osmKey isEqualToString:@"addr:province"]|| [osmKey isEqualToString:@"addr:street"]) {
            self.autocapitalizationType = UITextAutocapitalizationTypeWords;
        }
        else if ([osmKey isEqualToString:@"addr:state"] || [osmKey isEqualToString:@"addr:country"]){
            self.autocapitalizationType = UITextAutocapitalizationTypeAllCharacters;
        }
        
        
        
        if ([osmKey isEqualToString:@"phone"]) {
            self.keyboardType = UIKeyboardTypeNumberPad;
        }
        else if([osmKey isEqualToString:@"addr:housenumber"] || [osmKey isEqualToString:@"addr:postcode"])
        {
            self.keyboardType = UIKeyboardTypeNamePhonePad;
            self.autocorrectionType = UITextAutocorrectionTypeNo;
        }
        else if([osmKey isEqualToString:@"website"])
        {
            self.keyboardType = UIKeyboardTypeURL;
            self.autocapitalizationType = UITextAutocapitalizationTypeNone;
            self.autocorrectionType = UITextAutocorrectionTypeNo;
            if (![value length]) {
                self.text = @"www.";
            }
        }
        else if([osmKey isEqualToString:@"email"])
        {
            self.keyboardType = UIKeyboardTypeEmailAddress;
            self.autocapitalizationType = UITextAutocapitalizationTypeNone;
            self.autocorrectionType = UITextAutocorrectionTypeNo;
        }
        
        if ([value length]) {
            self.text = value;
        }
        
        
    }
    return self;
}

@end
