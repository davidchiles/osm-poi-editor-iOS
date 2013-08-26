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

@interface OPETagEditViewController ()

@end

@implementation OPETagEditViewController

@synthesize delegate = _delegate,osmKey = _osmKey,currentOsmValue = _currentOsmValue;
@synthesize managedOptional,element;

-(id)initWithOsmKey:(NSString *)newOsmKey delegate:(id<OPETagEditViewControllerDelegate>)newDelegate
{
    if ((self = [super init])) {
        self.osmKey = newOsmKey;
        self.delegate = newDelegate;
    }
    return self;
    
}
-(id)initWithOsmKey:(NSString *)newOsmKey currentValue:(NSString *)newCurrentValue delegate:(id<OPETagEditViewControllerDelegate>)newDelegate
{
    if ((self = [super init])) {
        self.osmKey = newOsmKey;
        self.delegate = newDelegate;
        self.currentOsmValue = newCurrentValue;
    }
    return self;
    
}

+(OPETagEditViewController *)viewControllerWithOsmKey:(NSString *)osmKey andType:(OPEOptionalType)type delegate:(id<OPETagEditViewControllerDelegate>)delegate
{
    OPETagEditViewController * viewController = nil;
    if (type == OPEOptionalTypeList) {
        viewController = [[OPETagValueList alloc] initWithOsmKey:osmKey delegate:delegate];
    }
    else if ([osmKey isEqualToString:@"wikipedia"])
    {
        OPEWikipediaEditViewController * wView = [[OPEWikipediaEditViewController alloc] initWithOsmKey:osmKey delegate:delegate];
        wView.showRecent = NO;
        viewController = wView;
    }
    else if ([@[@"addr:street",@"addr:postcode",@"addr:city",@"addr:state",@"addr:province"]containsObject:osmKey]) {
        OPERecentlyUsedViewController * rView = [[OPERecent_NearbyViewController alloc] initWithOsmKey:osmKey delegate:delegate];
        rView.showRecent = YES;
        viewController = rView;
    }
    else if ([@[@"addr:housenumber",@"addr:country",@"website"]containsObject:osmKey] || type == OPEOptionalTypeNumber || type == OPEOptionalTypeLabel) {
        OPERecentlyUsedViewController * rView = [[OPERecentlyUsedViewController alloc] initWithOsmKey:osmKey delegate:delegate];
        rView.showRecent = [osmKey isEqualToString:@"addr:country"];
        if (type == OPEOptionalTypeNumber) {
            rView.textField.keyboardType = UIKeyboardTypeNumberPad;
        }
        viewController = rView;
    }
    else if ([@[@"phone",@"fax"] containsObject:osmKey])
    {
        OPERecentlyUsedViewController * rView = [[OPEPhoneEditViewController alloc] initWithOsmKey:osmKey delegate:delegate];
        rView.showRecent = NO;
        viewController = rView;
    }
    else if ([osmKey isEqualToString:@"email"])
    {
        OPERecentlyUsedViewController * rView = [[OPERecentlyUsedViewController alloc] initWithOsmKey:osmKey delegate:delegate];
        rView.showRecent = NO;
        rView.textField.keyboardType = UIKeyboardTypeEmailAddress;
        viewController = rView;
        
    }
    else if ([@[@"name",@"source",@"note"] containsObject:osmKey])
    {
        OPERecentlyUsedViewController * rView = [[OPERecentlyUsedViewController alloc] initWithOsmKey:osmKey delegate:delegate];
        rView.showRecent = NO;
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
