//
//  OPETagEditViewController.m
//  OSM POI Editor
//
//  Created by David on 3/25/13.
//
//

#import "OPETagEditViewController.h"
#import "OPERecent+NearbyViewController.h"
#import "OPERecentlyUsedViewController.h"
#import "OPEPhoneEditViewController.h"
#import "OPEConstants.h"
#import "OPETagValueList.h"
#import "OPEWikipediaEditViewController.h"
#import "OPEOpeningHoursEditViewController.h"

@interface OPETagEditViewController ()

@end

@implementation OPETagEditViewController

@synthesize osmKey = _osmKey,currentOsmValue = _currentOsmValue;
@synthesize managedOptional,completionBlock;

-(id)initWithOsmKey:(NSString *)newOsmKey value:(NSString *)newOsmValue withCompletionBlock:(newTagBlock)newCompletionBlock
{
    if (self = [self initShowCancel:YES showDone:self.showDoneButton]) {
        self.osmKey = newOsmKey;
        self.currentOsmValue = [newOsmValue copy];
        self.completionBlock = newCompletionBlock;
    }
    return self;
}

-(BOOL)showDoneButton
{
    return YES;
}
-(void)doneButtonPressed:(id)sender
{
    if (completionBlock) {
        completionBlock(self.osmKey,self.currentOsmValue);
    }
    [super doneButtonPressed:sender];
}

-(NSString *)currentOsmValue
{
    return [_currentOsmValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

+(OPETagEditViewController *)viewControllerWithOsmKey:(NSString *)osmKey currentOsmValue:(NSString *)osmValue andType:(OPEOptionalType)type withCompletionBlock:(newTagBlock)newCompletionBlock
{
    OPETagEditViewController * viewController = nil;
    if (type == OPEOptionalTypeList) {
        viewController = [[OPETagValueList alloc] initWithOsmKey:osmKey value:osmValue withCompletionBlock:newCompletionBlock];
    }
    else if ([osmKey isEqualToString:@"wikipedia"])
    {
        OPEWikipediaEditViewController * wView = [[OPEWikipediaEditViewController alloc] initWithOsmKey:osmKey value:osmValue withCompletionBlock:newCompletionBlock];
        wView.showRecent = NO;
        viewController = wView;
    }
    else if ([@[@"addr:street",@"addr:postcode",@"addr:city",@"addr:state",@"addr:province"]containsObject:osmKey]) {
        OPERecentlyUsedViewController * rView = [[OPERecent_NearbyViewController alloc] initWithOsmKey:osmKey value:osmValue withCompletionBlock:newCompletionBlock];
        rView.showRecent = YES;
        viewController = rView;
    }
    else if ([@[@"addr:housenumber",@"addr:country",@"website"]containsObject:osmKey] || type == OPEOptionalTypeNumber || type == OPEOptionalTypeLabel) {
        OPERecentlyUsedViewController * rView = [[OPERecentlyUsedViewController alloc] initWithOsmKey:osmKey value:osmValue withCompletionBlock:newCompletionBlock];
        rView.showRecent = [osmKey isEqualToString:@"addr:country"];
        if (type == OPEOptionalTypeNumber) {
            rView.textField.keyboardType = UIKeyboardTypeNumberPad;
        }
        viewController = rView;
    }
    else if ([@[@"phone",@"fax"] containsObject:osmKey])
    {
        OPEPhoneEditViewController * rView = [[OPEPhoneEditViewController alloc] initWithOsmKey:osmKey value:osmValue withCompletionBlock:newCompletionBlock];
        viewController = rView;
    }
    else if ([osmKey isEqualToString:@"email"])
    {
        OPERecentlyUsedViewController * rView = [[OPERecentlyUsedViewController alloc] initWithOsmKey:osmKey value:osmValue withCompletionBlock:newCompletionBlock];
        rView.showRecent = NO;
        rView.textField.keyboardType = UIKeyboardTypeEmailAddress;
        viewController = rView;
        
    }
    else if ([@[@"name",@"source",@"note"] containsObject:osmKey])
    {
        OPERecentlyUsedViewController * rView = [[OPERecentlyUsedViewController alloc] initWithOsmKey:osmKey value:osmValue withCompletionBlock:newCompletionBlock];
        rView.showRecent = NO;
        viewController = rView;
    }
    else if (type == OPEOptionalTypeHours)
    {
        OPEOpeningHoursEditViewController * rView = [[OPEOpeningHoursEditViewController alloc] initWithOsmKey:osmKey value:osmValue withCompletionBlock:newCompletionBlock];
        viewController = rView;
    }
    
    
    return viewController;
}

+(NSString *)sectionFootnoteForOsmKey:(NSString *)osmKey
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
    else if([osmKey isEqualToString:@"phone"])
    {
        string = @"US and Canada country code is 1";
    }

    else {
        string = @"";
    }
    return string;
}

@end
