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

@interface OPETagEditViewController ()

@end

@implementation OPETagEditViewController

@synthesize delegate = _delegate,osmKey = _osmKey,currentOsmValue = _currentOsmValue;

-(id)initWithOsmKey:(NSString *)newOsmKey delegate:(id<OPETagEditViewControllerDelegate>)newDelegate
{
    if ((self = [super self])) {
        self.osmKey = newOsmKey;
        self.delegate = newDelegate;
    }
    return self;
    
}
-(id)initWithOsmKey:(NSString *)newOsmKey currentValue:(NSString *)newCurrentValue delegate:(id<OPETagEditViewControllerDelegate>)newDelegate
{
    if ((self = [super self])) {
        self.osmKey = newOsmKey;
        self.delegate = newDelegate;
        self.currentOsmValue = newCurrentValue;
    }
    return self;
    
}

+(OPETagEditViewController *)viewControllerWithOsmKey:(NSString *)osmKey delegate:(id<OPETagEditViewControllerDelegate>)delegate
{
    OPETagEditViewController * viewController = nil;
    if ([@[@"addr:street",@"addr:postcode",@"addr:city",@"addr:state",@"addr:province"]containsObject:osmKey]) {
        viewController = [[OPERecent_NearbyViewController alloc] initWithOsmKey:osmKey delegate:delegate];
    }
    
    return viewController;
}

@end
